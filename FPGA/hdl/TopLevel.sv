// Use saved pinouts and ensure their I/O Standards are all at 3.3-V LTTVL via Pin Planner.
module TopLevel 
# (
parameter CLOCK_SPEED = 50000000,
parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
parameter IMAGEY = 64,
parameter IMAGEX = 64,
parameter IMAGE_SIZE = IMAGEY * IMAGEX,
parameter RGB_SIZE = 8
)

(

      	///////// Clocks /////////
      	input logic MAX10_CLK1_50, 

      	///////// KEY /////////
      	input logic [1:0] KEY,

      	///////// SW /////////
      	input logic [6: 0] SW,

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
		
		// Denotes whether data on the MISO line is valid (i.e., useful to the master) //
		output logic data_valid
		
);
	// Each `received` is a byte. For this example, we have a maximum of 8 bytes ([7:0]) to receive.
	
	logic rst;
	logic [7:0] first_byte, last_byte, curr_byte;
	
	assign rst = ~(KEY[1]);

	HexDriverD hex_driver5 (SPI_CLK, HEX5[6:0]);

	
	HexDriverD hex_driver4 (SPI_MISO, HEX4[6:0]);

		
	HexDriverD hex_driver3 (SPI_MOSI, HEX3[6:0]); 


	HexDriver hex_driver2 (last_byte, HEX2[6:0]); 


	HexDriver hex_driver1 (first_byte, HEX1[6:0]);

	
	HexDriver hex_driver0 (curr_byte, HEX0[6:0]);
	logic [7:0] ram_out, color_out;
	mem_block #(
			.CLOCK_SPEED(50000000),
			.PIXEL_COUNTER(50000000 / CLOCK_SPEED),
			.IMAGEY(64),
			.IMAGEX(64),
			.IMAGE_SIZE(IMAGEY * IMAGEX),
			.RGB_SIZE(8)
	) memory (
		.clk(MAX10_CLK1_50), 
		.wr_en(1'b1), 
		.data_in(8'b11111111), 
		.data_out(ram_out), 
		.address(7'b1111111)
	);

	SPI_control SPI_control(
		.clk(MAX10_CLK1_50),
		.rst(rst),
		.SPI_CLK(SPI_CLK),
		.SPI_MISO(SPI_MISO),
		.SPI_MOSI(SPI_MOSI),
		.SPI_CS(SPI_CS),
		.first_byte(first_byte),
		.last_byte(last_byte),
		.curr_byte(curr_byte)
	); 

	pixel_algorithm_unit gray(
	.clk(MAX10_CLK1_50), 
	.rst(rst), 
    .color(ram_out),
    .color_out(color_out)
);


endmodule 