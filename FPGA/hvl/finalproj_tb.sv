`timescale 10ns/1ns 
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
logic [IMAGE_ADDR_WIDTH - 1:0] i = '0; 

initial begin 
    clk = 1; 
    SPI_CLK = 1;
    forever begin
        #1; 
        clk = ~clk; 
        SPI_CLK = ~SPI_CLK; 
    end 

end 




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
    .data_valid(data_valid)    




); 


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
        external_SPI_data = $urandom; 
        $display("Inserting %h at addr %h.", external_SPI_data, i); 
        #2; 
    end


end 



endmodule 


