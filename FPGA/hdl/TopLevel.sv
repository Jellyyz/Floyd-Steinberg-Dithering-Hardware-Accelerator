// Use saved pinouts and ensure their I/O Standards are all at 3.3-V LTTVL via Pin Planner.
// COPYRIGHT 2023
// 
// Top Level HDL of Group 29 ECE445 SP23

module TopLevel 
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
) 
(

      	///////// Clocks /////////
      	input logic MAX10_CLK1_50, 

      	///////// KEY /////////
      	input logic [1:0] KEY,

      	///////// SW /////////
      	input logic [9: 0] SW,

    	/////////// LED /////////
      	output logic [ 9: 0] LED,

    	/////////// HEX /////////
       	output logic [6:0] HEX0,
       	output logic [6:0] HEX1,
       	output logic [6:0] HEX2,
       	output logic [6:0] HEX3,
       	output logic [6:0] HEX4,
       	output logic [6:0] HEX5,

		////////// SPI /////////
		input logic SPI_CLK,
		input logic SPI_MOSI,		
		output logic SPI_MISO,
		input logic SPI_CS,

		input logic [RGB_SIZE - 1:0] external_SPI_data,

		///////// General Arduino /////
		input logic MCU_TX_RDY, 

		output logic MCU_RX_RDY,


		// Denotes whether data on the MISO line is valid (i.e., useful to the master) //
		output logic data_valid
		
);
	// Each `received` is a byte. For this example, we have a maximum of 8 bytes ([7:0]) to receive.
	
	logic rst;
	logic [7:0] first_byte, last_byte, curr_byte;
	logic [IMAGE_ADDR_WIDTH - 1:0] WR_RAM_ADDR, RD_RAM_ADDR;
	assign rst = ~(KEY[1]);
	assign LED = 10'h0; 
	assign data_valid = 1'b0; 
	assign SPI_MISO = 1'bZ; 


	logic LD_RAM, RD_RAM; 
	logic done_compute; 

	HexDriverD hex_driver5 (4'b1111, HEX5[6:0]);
	HexDriverD hex_driver4 (4'b1111, HEX4[6:0]);
	HexDriverD hex_driver3 (4'b1111, HEX3[6:0]); 
	HexDriver hex_driver2 (4'b1111, HEX2[6:0]);
	HexDriver hex_driver1 (4'b1111, HEX1[6:0]);
	HexDriver hex_driver0 (4'b1111, HEX0[6:0]);

	logic [(RGB_SIZE - 1):0] ram_out, color_out;

	
	pixel_algorithm_unit #(
		.CLOCK_SPEED(CLOCK_SPEED),
		.IMAGEX(IMAGEX), .IMAGEY(IMAGEY), 
		.IMAGE_SIZE(IMAGE_SIZE),
		.IMAGEXlog2(IMAGEXlog2), .IMAGEYlog2(IMAGEYlog2),
		.IMAGE_ADDR_WIDTH(IMAGE_ADDR_WIDTH), 
		.RGB_SIZE(RGB_SIZE), 
		.ADJ_PIXELS(ADJ_PIXELS)
	)
	gray(
		// input 
		.clk(MAX10_CLK1_50), 
		.rst(rst),
		.external_SPI_data(external_SPI_data),
		.MCU_TX_RDY(MCU_TX_RDY), 

		// output 
		.MCU_RX_RDY(MCU_RX_RDY)

	);
	
	// SPI_control SPI_control(
	// 	// input 
	// 	.clk(MAX10_CLK1_50), .rst(rst),
		
	// 	// output
	// 	.SPI_CLK(SPI_CLK),
	// 	.SPI_MISO(SPI_MISO),
	// 	.SPI_MOSI(SPI_MOSI),
	// 	.SPI_CS(SPI_CS),
	// 	.first_byte(first_byte),
	// 	.last_byte(last_byte),
	// 	.curr_byte(curr_byte)
	// ); 



endmodule 