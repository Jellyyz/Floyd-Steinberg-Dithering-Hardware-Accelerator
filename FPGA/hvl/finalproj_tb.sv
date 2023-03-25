`timescale 10ns/1ns

import states::*; 
module finalproj_tb
# (
	parameter CLOCK_SPEED = 50000000,
	parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
	parameter IMAGEY = 16,
	parameter IMAGEX = 16,
	parameter IMAGE_SIZE = IMAGEY * IMAGEX,
	parameter IMAGEYlog2 = $clog2(IMAGEY), 
	parameter IMAGEXlog2 = $clog2(IMAGEX),
	parameter IMAGE_ADDR_WIDTH = $clog2(IMAGE_SIZE),
	parameter RGB_SIZE = 8,
	parameter IMAGESIZElog2idx = ($clog2(IMAGE_SIZE) - 1),
	parameter ADJ_PIXELS = 4
) ();

logic clk;
logic SPI_CLK;
logic SPI_CS = 1'bZ, SPI_MISO = 1'bZ, SPI_MOSI = 1'bZ; 
logic [1:0] KEY; 
logic [9:0] SW, LED; 
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
logic data_valid = 1'b0; 
logic MCU_RX_RDY = 1'b0; 
logic MCU_TX_RDY = 1'b0; 
logic [RGB_SIZE - 1:0] external_SPI_data = '0; 
logic [RGB_SIZE - 1:0] test_vector_sram [IMAGE_SIZE]; 
logic [IMAGE_ADDR_WIDTH - 1:0] i = '0; 
logic [IMAGE_ADDR_WIDTH - 1:0] m = '0; 
logic [IMAGE_ADDR_WIDTH - 1:0] n = '0; 

//  logic [x] name [y];" you index it this way "name[y][x]

logic [RGB_SIZE - 1:0] old_pixel; 
logic [RGB_SIZE - 1:0] quant_error; 
logic [RGB_SIZE - 1:0] new_closest; 
states::state_t state, next_state;
logic [RGB_SIZE - 1: 0] sram_out_test;

initial begin 
    clk = 1; 
    SPI_CLK = 1;
    forever begin
        #1; 
        clk = ~clk; 
        SPI_CLK = ~SPI_CLK; 
    end 

end 

function [7:0] closest_pixel(input logic [RGB_SIZE - 1:0] pixel_in);
    begin 
        closest_pixel = (pixel_in >= 8'd128) ? 8'hFF: '0; 
    end 
endfunction

// 6 = [1][2]
// 6 = [x * imagex + y] 1 * 4 + 2 = 6
// 0 1 2 3             
// 4 5 6 7             
// 8 9 10 11           
// 12 13 14 15         

// 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
// m is y 
// n is x 


task run_algor(input logic [IMAGE_ADDR_WIDTH - 1:0] m, input logic [IMAGE_ADDR_WIDTH - 1:0] n);
    old_pixel = test_vector_sram[m * IMAGEY + n];
    new_closest = closest_pixel(old_pixel); 
    test_vector_sram[m * IMAGEY + n] = closest_pixel(old_pixel); 
    quant_error = old_pixel - new_closest; 

    if(n < IMAGEX)begin 
        // east 
        test_vector_sram[m * IMAGEY + (n + 1)] = test_vector_sram[m * IMAGEY + (n + 1)] + (quant_error * 7/16);
    end 
    if(m < IMAGEY - 1 && n != 0)begin 
        // southwest
        test_vector_sram[(m + 1) * IMAGEY + (n - 1)] = test_vector_sram[(m + 1) * IMAGEY + (n - 1)] + (quant_error * 3/16); 
    end 
    if(m < IMAGEY - 1)begin 
        // south
        test_vector_sram[(m + 1) * IMAGEY + n] = test_vector_sram[(m + 1) * IMAGEY + n] + (quant_error * 5/16); 
    end 
    if(n < IMAGEX && m < IMAGEY - 1)begin
        // southeast  
        test_vector_sram[(m + 1) * IMAGEY + (n + 1)] = test_vector_sram[(m + 1) * IMAGEY + (n + 1)] + (quant_error * 1/16);  
    end 

endtask



TopLevel #(
		.CLOCK_SPEED(CLOCK_SPEED),
		.PIXEL_COUNTER(PIXEL_COUNTER), 
		.IMAGEX(IMAGEX), .IMAGEY(IMAGEY), 
		.IMAGE_SIZE(IMAGE_SIZE),
		.IMAGEXlog2(IMAGEXlog2), .IMAGEYlog2(IMAGEYlog2),
		.IMAGE_ADDR_WIDTH(IMAGE_ADDR_WIDTH), 
		.RGB_SIZE(RGB_SIZE), 
		.ADJ_PIXELS(ADJ_PIXELS)
	)
    toplevel(
    // input 
    .MAX10_CLK1_50(clk), 
    .KEY(KEY),
    .SW(SW),
    .SPI_CLK(SPI_CLK),
    .SPI_MOSI(SPI_MOSI), 
    .SPI_CS(SPI_CS), 
    .MCU_TX_RDY(MCU_TX_RDY),  
    .external_SPI_data(external_SPI_data), 

    // output 
    .MCU_RX_RDY(MCU_RX_RDY),
    .LED(LED), 
    .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
    .SPI_MISO(SPI_MISO), 
    .data_valid(data_valid),    
    .state(state),
    .next_state(next_state),
    .sram_out_test(sram_out_test)



); 
integer error_count = 0; 

logic [RGB_SIZE - 1:0] temp; 
initial begin: TEST_VECTORS
    // immediately assert a reset signal
    KEY = 2'b01; 
    #2; 
    KEY = 2'b11; 
    #10;
    MCU_TX_RDY <= 1'b1; 
    #2; 
    MCU_TX_RDY <= 1'b0; 
    // begin loading sram with data 
    for(i = 0; i < 'hFF - 1'h1; i++)begin  // change depending on image size
        temp = $urandom; 
        external_SPI_data = temp;
        test_vector_sram[i][RGB_SIZE - 1:0] = temp;
        // $display("Inserting %h at addr %h.", external_SPI_data, i); 
        #2; 
    end    
    #100;
    for(m = 0; m < IMAGEY; m++)begin 
        for(n = 0; n < IMAGEX; n++)begin 
            #1;
            run_algor(m, n); 
        end
    end 
    @(state == S4_CC1); 
    $display("Starting comprehensive tests @.", $time);
    #9;
    for(i = 0; i < 'hFF - 1'h1; i++)begin  // change depending on image size
        assert(sram_out_test == test_vector_sram[i][RGB_SIZE - 1:0])
        else begin 
            $error("Found data mismatch in index %h between expected %h and actual %h.", i, test_vector_sram[i], sram_out_test);
            error_count++; 
        end 
        #2;
        if(error_count > 4)begin 
            $error("too much errors.");
            $stop();
        end
    end   



    
end 



endmodule 


