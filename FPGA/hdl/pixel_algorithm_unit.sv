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
    logic [RGB_SIZE - 1:0] png_data_color_closest; 

    // quant_error - reg 
    logic [RGB_SIZE - 1:0] png_data_color_buffer_q_error; 
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
//     state 1 old <= q_a                                                   store_old_p                        rden_a = 1'b0  rden_b = 1'b0; 
//     state 2 sram[x][y] <= closest_pixel(q_a)                             compare_and_store_n                wren_a = 1'b1  wren_b = 1'b0;              
//     state 2 quant_error <= old - closest_pixel(q_a)                      compare_and_store_n                XXXXXXXXXXXXXXXXXXXXXXXXXXXX;            
//     state 3 sram[x + 1][y] <= sram[x + 1][y] + ((quant_error >> 4) * 7)
//     state 4 sram[x - 1][y + 1] <= sram[x - 1][y + 1] + ((quant_error >> 4) * 3)
//     state 5 sram[x][y + 1] <= sram[x][y + 1] + ((quant_error >> 4) * 5)
//     state 6 sram[x + 1][y + 1] <= sram[x + 1][y + 1] + (quant_error >> 4)   

// my implementation of the algorithm  
// cc1 assert rden_b to sram to get q_b @ cc2             store_old_p  q_b <= sram @ address sram         rden_a = 1'b0 rden_b = 1'b1                 
// cc2 use q_a to combinationally find closest_pixel      com&str_en   dataA <= closest_pixel(q_b)        wren_a = 1'b1 wren_b = 1'b0
// cc2 find quant error which will be updated @ cc3       ...          quant <= q_b - closest(q_b)        xxxxxx
// cc2 sram[x][y] will be updated @ next clock cycle      ...           

// cc3 need to poll for sramE; sramE rdy @cc4             compute 0    q_b   <= sramE @ address sramE     rden_a = 1'b0 rden_b = 1'b1
// cc4 sramE is ready, write into sramE;                  compute 1    dataA <= sramE @ address sramE     wren_a = 1'b1 wren_b = 1'b0 
// cc4 need to poll for sramSW; sramSW rdy @ cc5          ...          q_b   <= sramSW @ address sramSW   rden_a = 1'b0 rden_b = 1'b1 
// cc5 sramSW is ready, write into sramSW;                compute 2    dataA <= sramSW @ address sramSW   wren_a = 1'b1 wren_b = 1'b0    
// cc5 need to poll for sramS; sramS rdy @ cc6            ...          q_b   <= sramS @ address sramS     rden_a = 1'b0 rden_b = 1'b1  
// cc6 sramS is ready, write into sramS;                  compute 3    dataA <= sramS @ address sramS     wren_a = 1'b1 wren_b = 1'b0 
// cc6 need to poll for sramSE; sramSE rdy @ cc7          ...          q_b   <= sramSE @ address sramSE   rden_a = 1'b0 rden_b = 1'b1 
// cc7 is a shared state with q_a1
// cc7 sramSE is ready, write into sramSE;                store_old_p  dataA <= sramSE @ address sramSE   wren_a = 1'b1 wren_b = 1'b0
// cc7 need to read from sram also.                       ...          old_pixel <= q_b @ address sram    rden_a = 1'b0 rden_b = 1'b1 
// cc7 is same as cc1
    // can immediately go from cc5 to cc1 or s3 
    // control signals 
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

    logic valid_png_idxA;
    logic valid_png_idxB;
    logic load_sram;
    logic store_sram;
    logic full_png_idx;

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

        .store_old_p(store_old_p),
        .compare_and_store_n(compare_and_store_n),  
        .compute_fin(compute_fin),
        .png_idx(png_idx),
        .state(state), 
        .next_state(next_state),
        .load_sram(load_sram), 
        .store_sram(store_sram),
        .full_png_idx(full_png_idx)


    ); 

    logic last_row_idx_chk; 
    logic last_col_idx_chk; 
    logic first_col_idx_chk;
    logic png_idx_base_con; 

    logic [RGB_SIZE - 1:0] png_quant_div_16;
    assign png_quant_div_16 = png_data_color_buffer_q_error >> 4; 
    assign png_data_color_closest = (q_b >= 128) ? 16'hFFFF : 16'h0; 

    always_comb begin: VALID_PNG_IDX
        // 1 is valid else 0 
        last_row_idx_chk = (png_idx < (IMAGE_SIZE - IMAGEX)); 
        last_col_idx_chk = ((png_idx + 1) % IMAGEX != 0);
        first_col_idx_chk = (png_idx % IMAGEX != 0);
        png_idx_base_con = png_idx < IMAGE_SIZE; 
        
        if(store_old_p) begin 
            valid_png_idxA = last_row_idx_chk && last_col_idx_chk;           // writing sramSE 
            valid_png_idxB = png_idx_base_con;                               // reading sram
        end 
        else if(compare_and_store_n) begin 
            valid_png_idxA = png_idx_base_con;                               // writing sram
            valid_png_idxB = png_idx_base_con;                               // reading XXXX
        end 
        else begin 
            unique case(compute_fin)
                4'b0001:begin 
                    valid_png_idxA = png_idx_base_con;                       // reading XXXX
                    valid_png_idxB = last_col_idx_chk;                       // reading sramE 
                end 
                4'b0010:begin 
                    valid_png_idxA = last_col_idx_chk;                       // writing sramE
                    valid_png_idxB = last_row_idx_chk && first_col_idx_chk;  // reading sramSW
                end 
                4'b0100:begin 
                    valid_png_idxA = last_row_idx_chk && first_col_idx_chk;  // writing sramSW
                    valid_png_idxB = last_row_idx_chk;                       // reading sramS 
                end 
                4'b1000:begin 
                    valid_png_idxA = last_row_idx_chk;      // writing sramS
                    valid_png_idxB = last_row_idx_chk && last_col_idx_chk;  // reading sramSE
                end 
                default:begin 
                    valid_png_idxA = png_idx_base_con; // writing XXXX
                    valid_png_idxB = png_idx_base_con; // reading XXXX
                end                
            endcase 

        end 
        
    
    
    end 

    always_comb begin: ADDR_A_AND_B_MUX
        
        if(store_old_p) begin 
            address_a = png_idx + (IMAGEX + 1); // writing sramSE 
            address_b = png_idx;                // reading sram
        end 
        else if(compare_and_store_n) begin 
            address_a = png_idx;                // writing sram
            address_b = png_idx;                // reading XXXX
        end 
        else begin 
            unique case(compute_fin)
                4'b0001:begin 
                    address_a = png_idx;                // reading XXXX
                    address_b = png_idx + 1;            // reading sramE 
                end 
                4'b0010:begin 
                    address_a = png_idx + 1;            // writing sramE
                    address_b = png_idx +(IMAGEX - 1);  // reading sramSW
                end 
                4'b0100:begin 
                    address_a = png_idx +(IMAGEX - 1);  // writing sramSW
                    address_b = png_idx +(IMAGEX);      // reading sramS 
                end 
                4'b1000:begin 
                    address_a = png_idx +(IMAGEX);      // writing sramS
                    address_b = png_idx + (IMAGEX + 1); // reading sramSE
                end 
                default:begin 
                    address_a = png_idx; // writing XXXX
                    address_b = png_idx; // reading XXXX
                end                
            endcase 

        end 

    end 
    // ~~~~~~~~~~~~~~~ ADJ PXL CALC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    logic [8:0] png_data_east; 
    logic [8:0] png_data_southwest; 
    logic [8:0] png_data_south; 
    logic [8:0] png_data_southeast; 
    assign png_data_east = q_b + ((png_quant_div_16) * 3'b111);
    assign png_data_southwest = q_b + ((png_quant_div_16) * 2'b11);
    assign png_data_south = q_b + ((png_quant_div_16) * 3'b101);
    assign png_data_southeast = q_b + png_quant_div_16;
       // ~~~~~~~~~~~~~~~ DATA THAT IS BEING WRITTEN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_comb begin: DATA_A_AND_B 
        // w sramse
        if(store_old_p) begin 
            data_a = png_data_southeast;
            data_b = 8'h0; 
        end 
        // need to store the closest pixel back into the sram 
        else if(compare_and_store_n) begin 
            data_a = png_data_color_closest[7:0];              
            data_b = 8'h0; 
        end 
        // w xxxx 
        else if(compute_fin[0]) begin   
            data_a = 8'h0;     
            data_b = 8'h0; 
        end 
        // w srame
        else if(compute_fin[1]) begin 

            data_a = png_data_east;
            
            data_b = 8'h0; 
        end 
        // w xxxx
        else if(compute_fin[2]) begin 
            
          
            data_a = png_data_south;
          

            data_b = 8'h0;  
        end 
        // w xxxx 
        else if(compute_fin[3]) begin 
            
           
            data_a = png_data_southwest;
          

            data_b = 8'h0; 
        end
        // write into sram
        else begin
            data_a = external_SPI_data; 
            data_b = 8'h0;  
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
            png_data_color_buffer_q_error <= q_b + (~(png_data_color_closest) + 1'b1); 
        end 

    end 
    
    assign sram_out_test = q_b; 
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