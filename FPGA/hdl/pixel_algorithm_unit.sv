// UIUC ECE 445 Senior Design
// RTL by : Gally Huang

module pixel_algorithm_unit
    # (
        parameter CLOCK_SPEED = 50000000,
        parameter IMAGEY = 64,
        parameter IMAGEX = 64,
        parameter IMAGE_SIZE = IMAGEY * IMAGEX,
        parameter IMAGEYlog2 = $clog2(IMAGEY), 
        parameter IMAGEXlog2 = $clog2(IMAGEX),
        parameter IMAGE_ADDR_WIDTH = $clog2(IMAGE_SIZE),
        parameter RGB_SIZE = 8,
        parameter ADJ_PIXELS = 4
    ) 
    
    (
        // 64 * 64 image = 4096 addressing for 8 bit data 
        // CLk - Rst Interface
        // 50 mhz clock  
        input logic clk, rst, 
        input logic [RGB_SIZE - 1:0] external_SPI_data,
        input logic MCU_TX_RDY, 

        output logic MCU_RX_RDY


    ); 
    
    // contains the old pixel - reg 
    logic [RGB_SIZE - 1:0] png_data_color_buffer_old; 

    // closest pixel to old pixel - some wire 
    logic [RGB_SIZE - 1:0] png_data_color_closest; 

    // quant_error - reg 
    logic [15:0] png_data_color_buffer_q_error; 
// wikipedia formula :     
// for each y from top to bottom do
//     for each x from left to right do
//state 1            oldpixel := pixels[x][y] 
//state 2  -no need? // newpixel := find_closest_palette_color(oldpixel)
//state 2            pixels[x][y] := newpixel
//state 2            quant_error := oldpixel - newpixel
//state 3            pixels[x + 1][y    ] := pixels[x + 1][y    ] + quant_error × 7 / 16
//state 3            pixels[x - 1][y + 1] := pixels[x - 1][y + 1] + quant_error × 3 / 16
//state 3            pixels[x    ][y + 1] := pixels[x    ][y + 1] + quant_error × 5 / 16
//state 3            pixels[x + 1][y + 1] := pixels[x + 1][y + 1] + quant_error × 1 / 16



 
// adapted version for our hardware 
// for i until image size
//     state 1 old <= sram[x][y]                                            store_old_P                        rden_a = 1'b1  wren_a = 1'b0; 
//     state 2 sram[x][y] <= closest_pixel(old)                             compare_and_store_N                rden_a = 1'b0  wren_a = 1'b1;              
//     state 2 quant_error <= old - closest_pixel(old)                      compare_and_store_N                rden_a = 1'bX  wren_a = 1'bX;            
//     state 3 sram[x + 1][y] <= sram[x + 1][y] + ((quant_error >> 4) * 7)
//     state 4 sram[x - 1][y + 1] <= sram[x - 1][y + 1] + ((quant_error >> 4) * 3)
//     state 5 sram[x][y + 1] <= sram[x][y + 1] + ((quant_error >> 4) * 5)
//     state 6 sram[x + 1][y + 1] <= sram[x + 1][y + 1] + (quant_error >> 4)    
// on state 3 read srame and store into sram at e
// on state 4 read sramsw and and store into sram at se
// on state 5 read srams and and store into sram at s
// on state 6 read sramse and and store into sram at sw
// on state 6 [x][y] must ++
// on state 1 store sram pixel_traversal into old, also store sramse buffer into sram again 
// repeat 

    // control signals 
    logic reset_dithering;
    logic store_old_p;
    logic compare_and_store_n;

    logic [3:0] compute_fin;
    logic [IMAGE_ADDR_WIDTH - 1:0] png_idx;
    
    // used by the SRAM 
    logic [15:0] address_a, address_b; // @TODO: maybe change to be parameterizable? 
    logic [RGB_SIZE - 1:0] data_a, data_b, q_a, q_b;
    logic rden_a, rden_b; 
    logic wren_a, wren_b; 

    logic read_en_a, read_en_b; 
    logic write_en_a, write_en_b; 

    logic valid_png_idx;

    mem_block pixel_sram(
        // inputs
        .address_a(address_a), 
        .address_b(address_b), 
        .clock(clk), 
        .data_a(data_a), .data_b(data_b),
        .rden_a(read_en_a), .rden_b(read_en_b),
        .wren_a(write_en_a), .wren_b(write_en_b), 
        
        // outputs 
        .q_a(q_a), .q_b(q_b) 
    );
    dithering_loop_control #(
		.CLOCK_SPEED(CLOCK_SPEED),
		.IMAGEX(IMAGEX), .IMAGEY(IMAGEY), 
		.IMAGE_SIZE(IMAGE_SIZE),
		.IMAGEXlog2(IMAGEXlog2), .IMAGEYlog2(IMAGEYlog2),
		.IMAGE_ADDR_WIDTH(IMAGE_ADDR_WIDTH), 
		.RGB_SIZE(RGB_SIZE), 
		.ADJ_PIXELS(ADJ_PIXELS)
	)
    control0(

        // CLk - Rst Interface
        .clk(clk), .rst(rst),
        .MCU_TX_RDY(MCU_TX_RDY), 

        // control signals 
        .rden_a(rden_a), .rden_b(rden_b),
        .wren_a(wren_a), .wren_b(wren_b), 
        .MCU_RX_RDY(MCU_RX_RDY),

        .reset_dithering(reset_dithering), 
        .store_old_p(store_old_p),
        .compare_and_store_n(compare_and_store_n),  
        .compute_fin(compute_fin),
        .png_idx(png_idx) 
    ); 

    logic last_row_idx_chk; 
    logic last_col_idx_chk; 
    logic first_col_idx_chk;


    logic [RGB_SIZE - 1:0] png_quant_div_16;
    assign png_quant_div_16 = png_data_color_buffer_q_error >> 4; 
    assign png_data_color_closest = (png_data_color_buffer_old >= 128) ? 8'b11111111 : 8'h0; 

    always_comb begin: VALID_PNG_IDX
        // 1 is valid else 0 
        last_row_idx_chk = (png_idx < (IMAGE_SIZE - IMAGEX)); 
        last_col_idx_chk = ((png_idx + 1) % IMAGEX == 0);
        first_col_idx_chk = (png_idx % IMAGEX == 0);

        unique case(compute_fin)
            4'b0001:begin // east
                valid_png_idx = last_col_idx_chk; 
            end 
            4'b0010:begin // southwest 
                valid_png_idx = first_col_idx_chk & last_row_idx_chk; 
            end 
            4'b0100:begin // south
                valid_png_idx = last_row_idx_chk;           
            end 
            4'b1000:begin // southeast
                valid_png_idx = last_col_idx_chk & last_row_idx_chk;  
            end
            default:begin // if not computing still should be less than image size
                valid_png_idx = png_idx < IMAGE_SIZE;
            end 

        endcase 
    
    
    end 

    always_comb begin: ADDR_A_MUX
        unique case(compute_fin)
            4'b0001:begin // east
                address_a = png_idx + 1'b1;
            end 
            4'b0010:begin // southwest 
                address_a = png_idx + (IMAGEX - 1'b1);
            end 
            4'b0100:begin // south
                address_a = png_idx + (IMAGEX);             
            end 
            4'b1000:begin // southeast
                address_a = png_idx + (IMAGEX + 1'b1); 
            end
            default:begin // if not computing just use base addr 
                address_a = png_idx; 
            end 

        endcase 


    end 

    always_comb begin: ADDR_B 
        address_b = '0;
    end 

    // ~~~~~~~~~~~~~~~ DATA THAT IS BEING WRITTEN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_comb begin: DATA_A 
        if(compare_and_store_n) begin 
            data_a = png_data_color_closest; 
        end 
        else if(compute_fin[0]) begin 
            data_a = q_a + (png_quant_div_16 * 3'b111); 
        end 
        else if(compute_fin[1]) begin 
            data_a = q_a + ((png_quant_div_16) * 2'b11); 
        end 
        else if(compute_fin[2]) begin 
            data_a = q_a + ((png_quant_div_16) * 3'b101); 
        end 
        else if(compute_fin[3]) begin 
            data_a = q_a + (png_quant_div_16); 
        end
        else begin 
            data_a = external_SPI_data;
        end 
    end 

    always_comb begin: DATA_B 
        data_b = '0;
    end 


    always_comb begin: SRAM_DATA_ACCESS_SAFETY_LOCK
        // if pixels are not valid then block writes and reads
        write_en_a = wren_a && valid_png_idx;
        write_en_b = wren_b && valid_png_idx; 
        read_en_a = 1'b1 && valid_png_idx; 
        read_en_b = rden_b && valid_png_idx;  
    end 




    // temporarily store the 4 adjacent sram data into here 
    logic [RGB_SIZE - 1:0] png_data_color_buffer [ADJ_PIXELS];



    // the correct "new" RGB value of the png_data (wire connecting to the register unit)
    logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_e;
    logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_sw;
    logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_s;
    logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_se;

    // temp values that have the correct current indexing for the pixel counter 
    // logic [IMAGE_SIZE:0] pixel_sweeper_e; 
    // logic [IMAGE_SIZE:0] pixel_sweeper_sw; 
    // logic [IMAGE_SIZE:0] pixel_sweeper_s; 
    // logic [IMAGE_SIZE:0] pixel_sweeper_se; 


 
   

    always_ff @(posedge clk or posedge rst) begin : OLD_PIXEL_REG

        if(rst) begin 
            png_data_color_buffer_old <= '0; 
        end 
        else if(store_old_p) begin 
            png_data_color_buffer_old <= q_a;
        end 
    end

    always_ff @(posedge clk or posedge rst) begin : QUANT_ERROR_REG

        if(rst) begin 
            png_data_color_buffer_q_error <= '0; 
        end 
        else begin 
            // if(png_data_color_buffer_old < png_data_color_closest) begin 
            //     png_data_color_buffer_q_error <= (png_data_color_closest - png_data_color_buffer_old);
            // end 
            // else begin 
                png_data_color_buffer_q_error <= (png_data_color_buffer_old - png_data_color_closest);
            // end
        end 

    end 

    //  x x x x
    //  x x x x
    //  x x x x
    //  x x x x
    //  x x x x
    //  x x x x
    //  x x x x
    //  x * 7 x
    //  3 5 1 x

    //   (1/16)
    // * = color[x] 
    // 7 = color[x + 1]  // e
    // 3 = color[x + IMAGEX - 1] // sw 
    // 5 = color[x + IMAGEX] // s 
    // 1 = color[x + IMAGEX + 1]  // se


endmodule 