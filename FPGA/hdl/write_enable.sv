module write_enX

# (
	parameter CLOCK_SPEED = 50000000,
	parameter IMAGEY = 64,
	parameter IMAGEX = 64,
	parameter IMAGE_SIZE = IMAGEY * IMAGEX,
	parameter IMAGEYlog2 = $clog2(IMAGEY), 
	parameter IMAGEXlog2 = $clog2(IMAGEX),
	parameter IMAGE_ADDR_WIDTH = $clog2(IMAGE_SIZE),
	parameter RGB_SIZE = 8,
	parameter IMAGESIZElog2idx = ($clog2(IMAGE_SIZE) - 1),
	parameter ADJ_PIXELS = 4
) 
(

    input logic clk, rst, 
    input [IMAGE_ADDR_WIDTH - 1:0] png_idx, 
    input logic MCU_TX_RDY, 


    output logic wren_a

); 
 




endmodule 