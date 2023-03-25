// UIUC ECE 445 Senior Design
// RTL by : Gally Huang

import states::*;
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

        output logic MCU_RX_RDY,
        output states::state_t state, next_state,
        output logic [RGB_SIZE - 1: 0] sram_out_test,
        output logic [RGB_SIZE - 1: 0] sram_out_stream

    ); 
    // closest pixel to old pixel - some wire 
    logic [(RGB_SIZE * 2) - 1:0] png_data_color_closest; 

    // quant_error - reg 
    logic [(RGB_SIZE *2) - 1:0] png_data_color_buffer_q_error; 
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
//     state 1 old <= q_a                                                   store_old_P                        rden_a = 1'b1  wren_a = 1'b0; 
//     state 2 sram[x][y] <= closest_pixel(q_a)                             compare_and_store_N                rden_a = 1'b0  wren_a = 1'b1;              
//     state 2 quant_error <= old - closest_pixel(q_a)                      compare_and_store_N                rden_a = 1'bX  wren_a = 1'bX;            
//     state 3 sram[x + 1][y] <= sram[x + 1][y] + ((quant_error >> 4) * 7)
//     state 4 sram[x - 1][y + 1] <= sram[x - 1][y + 1] + ((quant_error >> 4) * 3)
//     state 5 sram[x][y + 1] <= sram[x][y + 1] + ((quant_error >> 4) * 5)
//     state 6 sram[x + 1][y + 1] <= sram[x + 1][y + 1] + (quant_error >> 4)   

// cc1 assert rden_a to sram to get q_a @ cc2 


// cc2 use q_a to combinationally find closest_pixel rd_en must be deasserted 
// cc2 at the same time can also find quant error which will be updated @ cc3
// cc2 sram[x][y] will be updated @ next clock cycle (fine since it is never used again)

// cc3 need to poll for sramE & sramSW; sramE rdy @ qa cc4, sramSW rdy qb @cc5  
// cc4 need to write into sramE       ; rdy @ cc5, doesn't matter though 

// cc5 need to write into sramSW      ; rdy @ cc6, doesn't matter though 
// cc5 need to poll for sramS & sramSE; sramS rdy @ qa cc5, sramSE rdy qb @cc7
// cc6 need to write into sramS & sramSE rdy @ cc1, doesn't matter tho


// cc3 need to poll for sramE; sramE rdy @cc4             compute 0    q_b   <= sramE @ address sramE     rden_a = 1'b0 rden_b = 1'b1
// cc4 sramE is ready, write into sramE;                  compute 1    dataA <= sramE @ address sramE     wren_a = 1'b1 wren_b = 1'b0 
// cc4 need to poll for sramSW; sramSW rdy @ cc5                       q_b   <= sramSW @ address sramSW   rden_a = 1'b0 rden_b = 1'b1 
// cc5 sramSW is ready, write into sramSW;                compute 2    dataA <= sramSW @ address sramSW   wren_a = 1'b1 wren_b = 1'b0    
// cc5 need to poll for sramS; sramS rdy @ cc6                         q_b   <= sramS @ address sramS     rden_a = 1'b0 rden_b = 1'b1  
// cc6 sramS is ready, write into sramS;                  compute 3    dataA <= sramS @ address sramS     wren_a = 1'b1 wren_b = 1'b0 
// cc6 need to poll for sramSE; sramSE rdy @ cc7                       q_b   <= sramSW @ address sramSW   rden_a = 1'b0 rden_b = 1'b1 
// cc7 is a shared state with q_a1
// cc7 sramSE is ready, write into sramSE;                             dataA <= sramSW @ address sramSW   wren_a = 1'b1 wren_b = 1'b0
// cc7 need to read from sram also.                                    q_b   <= sramSW @ address sramW    rden_a = 1'b0 rden_b = 1'b1 



    // can immediately go from cc5 to cc1 or s3 
    // control signals 
    logic store_old_p;
    logic compare_and_store_n;

    logic [3:0] compute_fin;
    logic [IMAGE_ADDR_WIDTH - 1:0] png_idx;
    
    // used by the SRAM 
    logic [15:0] address; // @TODO: maybe change to be parameterizable? 
    logic [RGB_SIZE - 1:0] data, q;
    logic rden; 
    logic wren; 

    logic read_en; 
    logic write_en; 

    logic valid_png_idx;
    logic [1:0] load_sram;
    logic store_sram, load_sram_logic; 
    logic full_png_idx;

    mem_block pixel_sram(
        // inputs
        .address(address), 
        .clock(clk), .aclr(rst),
        .data(data), 
        .rden(read_en),
        .wren(write_en),
        
        // outputs 
        .q(q) 
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

        .store_old_p(store_old_p),
        .compare_and_store_n(compare_and_store_n),  
        .compute_fin(compute_fin),
        .png_idx(png_idx),
        .state(state), 
        .next_state(next_state),
        .load_sram(load_sram), .load_sram_logic(load_sram_logic),
        .store_sram(store_sram),
        .full_png_idx(full_png_idx)


    ); 

    logic last_row_idx_chk; 
    logic last_col_idx_chk; 
    logic first_col_idx_chk;


    logic [RGB_SIZE - 1:0] png_quant_div_16;
    assign png_quant_div_16 = png_data_color_buffer_q_error >> 4; 
    assign png_data_color_closest = (q_a >= 128) ? 16'hFFFF : 16'h0; 

    always_comb begin: VALID_PNG_IDX
        // 1 is valid else 0 
        last_row_idx_chk = (png_idx < (IMAGE_SIZE - IMAGEX)); 
        last_col_idx_chk = ((png_idx + 1) % IMAGEX != 0);
        first_col_idx_chk = (png_idx % IMAGEX != 0);

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
            default:begin 
                // if not computing still should be less than image size, block address B access
                // this SHOULD be accounting for loading and storing sram through first if
                valid_png_idx = png_idx < IMAGE_SIZE;
        
            end 

        endcase 
    
    
    end 

    always_comb begin: ADDR_A_AND_B_MUX
        unique case(compute_fin)
            4'b0001:begin 
                address = png_idx + 1'b1;
            end 
            4'b0010:begin
                address = png_idx + (IMAGEX - 1'b1);
            end 
            4'b0100:begin 
                address = png_idx + IMAGEX;
            end 
            4'b1000:begin
                address = png_idx + (IMAGEX + 1'b1);            
            end
            default:begin 
            // if not computing 
                address_a = png_idx; 
            end 

        endcase 


    end 

    // ~~~~~~~~~~~~~~~ DATA THAT IS BEING WRITTEN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_comb begin: DATA_A_AND_B 
        // need to store the closest pixel back into the sram 
        if(compare_and_store_n) begin 
            data = png_data_color_closest[7:0];              
        end 
        else if(compute_fin[0]) begin   
            data = 
        end 
        else if(compute_fin[1]) begin 
            data_a = q_a + ((png_quant_div_16) * 3'b111); 
            data_b = q_b + ((png_quant_div_16) * 2'b11); 
        end 
        else if(compute_fin[2]) begin 
            data_a = 'X;
            data_b = 'X; 
        end 
        else if(compute_fin[3]) begin 
            data_a = q_a + ((png_quant_div_16) * 3'b101); 
            data_b = q_b + png_quant_div_16; 
        end
        else begin 
            data_a = external_SPI_data;
            data_b = 'X; 

        end 
    end 


    always_comb begin: SRAM_DATA_ACCESS_SAFETY_LOCK
        // if pixels are not valid then block writes and reads
        write_en_a = wren_a && valid_png_idxA;
        write_en_b = wren_b && valid_png_idxB; 
        read_en_a = rden_a && valid_png_idxA; 
        read_en_b = rden_b && valid_png_idxB;  
    end 



    // temp values that have the correct current indexing for the pixel counter 
    // logic [IMAGE_SIZE:0] pixel_sweeper_e; 
    // logic [IMAGE_SIZE:0] pixel_sweeper_sw; 
    // logic [IMAGE_SIZE:0] pixel_sweeper_s; 
    // logic [IMAGE_SIZE:0] pixel_sweeper_se; 



    always_ff @(posedge clk or posedge rst) begin : QUANT_ERROR_REG

        if(rst) begin 
            png_data_color_buffer_q_error <= '0; 
        end 
        else begin 
            if(compare_and_store_n)begin 
                png_data_color_buffer_q_error <= (q_a - png_data_color_closest);
            end 
        end 

    end 
    logic [31:0] count; 
    // attempt to pipeline sram to achieve 1 read byte / cycle 
    always_ff @(posedge clk) begin: SRAM_OUT_STREAM
        if(rst)begin
            sram_out_stream <= '0;
            count <= '0;  
        end 
        else begin 
            if(load_sram[0] && ~full_png_idx) begin 
                sram_out_stream <= q_a; 
                count <= count + 1'b1; 
            end
            else if(load_sram[1] && ~full_png_idx)begin 
                sram_out_stream <= q_b; 
                count <= count + 1'b1; 
            end 
        end 
    end 

    
    assign sram_out_test = sram_out_stream; 
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