`timescale 10ns/1ns

import states::*; 
module floyd_dither_spi_control
# (
	parameter CLOCK_SPEED = 50000000,
	parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
	parameter IMAGEY = 4,
	parameter IMAGEX = 4,
	parameter IMAGE_SIZE = IMAGEY * IMAGEX,
	parameter IMAGEYlog2 = $clog2(IMAGEY), 
	parameter IMAGEXlog2 = $clog2(IMAGEX),
	parameter IMAGE_ADDR_WIDTH = $clog2(IMAGE_SIZE),
	parameter RGB_SIZE = 8,
	parameter IMAGESIZElog2idx = ($clog2(IMAGE_SIZE) - 1),
	parameter ADJ_PIXELS = 4
) ();

logic clk;
logic SPI_CLK = 1'b0;
logic SPI_CS = 1'b1, SPI_MISO = 1'bZ, SPI_MOSI = 1'bZ; 
logic [1:0] KEY; 
logic [9:0] SW, LED; 
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
logic SPI_CLK_EN = 1'b0; 

logic true_rst; 
logic request_flag; 

initial begin 
    clk = 1; 
    forever begin
        #1; 
        clk = ~clk; 
        if(SPI_CLK_EN)begin 
            SPI_CLK = ~SPI_CLK; 

        end 
    end 

end 



TopLevel_true #(
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

    .MAX10_CLK1_50(clk), 
    .KEY(KEY),
    .SW(SW),
    .SPI_CLK(SPI_CLK),
    .SPI_MOSI(SPI_MOSI), 
    .SPI_CS(SPI_CS), 
    .true_rst(true_rst),  
    .request_flag(request_flag), 


    .LED(LED), 
    .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
    .SPI_MISO(SPI_MISO), 
    .state(state),
    .next_state(next_state)

); 
logic [15:0] error_count = 0; 

logic [RGB_SIZE - 1:0] temp; 
integer i; 



initial begin: TEST_VECTORS
    // immediately assert a reset signal
    KEY = 2'b01; 
    #2; 
    KEY = 2'b11; 
    #10;

    for(i = 0; i < 16; i++)begin 
        #2;
        SPI_CLK_EN = 1'b1;      // begin to enable the SPI_CLK 
        SPI_CS = 1'b0;          // select the slave 
        SPI_MOSI = 1'b1;        // MSB send 8'b01111111
        #2; 
        SPI_MOSI = 1'b1; 
        #2; 
        SPI_MOSI = 1'b1; 
        #2; 
        SPI_MOSI = 1'b1; 
        #2; 
        SPI_MOSI = 1'b1; 
        #2; 
        SPI_MOSI = 1'b1; 
        #2; 
        SPI_MOSI = 1'b1; 
        #2; 
        SPI_MOSI = 1'b0; 
    end 
    SPI_CS = 1'b1; 
    SPI_CLK_EN = 1'b0; 
    #1;  
    @(request_flag); 

    SPI_CS = 1'b0;
    SPI_CLK_EN = 1'b1; 
    SPI_MOSI = 1'b0;
    #2; 
    SPI_MOSI = 1'b0;
    #2; 
    SPI_MOSI = 1'b1;
    #2; 
    SPI_MOSI = 1'b1;
    #2; 
    SPI_MOSI = 1'b0;
    #2; 
    SPI_MOSI = 1'b1;
    #2; 
    SPI_MOSI = 1'b1;
    #2; 
    SPI_MOSI = 1'b1;
    #2;  
    SPI_CS = 1'b1; 
    SPI_CLK_EN = 1'b0; 

    #10;

    for(i = 0; i < 64; i++)begin 
        #2; 
        SPI_CLK_EN = 1'b1;      // begin to enable the SPI_CLK 
        SPI_CS = 1'b0;          // select the slave 
        SPI_MOSI = 1'b0;        // MSB send 8'd0; 
        #2; 
        SPI_MOSI = 1'b0; 
        #2;  
        SPI_MOSI = 1'b0; 
        #2;  
        SPI_MOSI = 1'b0; 
        #2;  
        SPI_MOSI = 1'b0; 
        #2;  
        SPI_MOSI = 1'b0; 
        #2;  
        SPI_MOSI = 1'b0; 
        #2;  
        SPI_MOSI = 1'b0; 
        #2;
        SPI_CS = 1'b1; 
        SPI_CLK_EN = 1'b0; 
    end 







    
end 



endmodule 


