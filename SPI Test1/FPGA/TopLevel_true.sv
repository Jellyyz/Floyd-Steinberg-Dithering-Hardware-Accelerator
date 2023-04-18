// Use saved pinouts and ensure their I/O Standards are all at 3.3-V LTTVL via Pin Planner.
// COPYRIGHT 2023
// 
// Top Level HDL of Group 29 ECE445 SP23
package states; // declaration of all states 
    typedef enum logic [3:0]{
        RESET, 
        WAIT_FOR_MCU,
        WAIT_FOR_MCU_STALL, 

        S2_CC1, 
        S2_CC2,
        S3_CC3, 
        S3_CC4,
        S3_CC5, 
        S3_CC6, 

        S4_CC1

    } state_t; 
endpackage 

import states::*;
module TopLevel_true
# (
	parameter CLOCK_SPEED = 50000000,
	parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
	parameter IMAGEY = 256,
	parameter IMAGEX = 256,
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

		///////// General Arduino /////
		input logic true_rst, 
		output logic request_flag,

        output states::state_t state, next_state,
        output logic [RGB_SIZE - 1: 0] sram_out_test
		
);
	// Each `received` is a byte. For this example, we have a maximum of 8 bytes ([7:0]) to receive.
	
	logic rst;
	logic [7:0] first_byte, last_byte, curr_byte;
	logic [IMAGE_ADDR_WIDTH - 1:0] WR_RAM_ADDR, RD_RAM_ADDR;
	assign rst = ~(KEY[1]);
	
	assign SPI_MISO = 1'bZ; 

	logic LD_RAM, RD_RAM; 
	logic done_compute; 

	HexDriver hex_driver5 (data_b_out[7:4], HEX5[6:0]);
	HexDriver hex_driver4 (data_b_out[3:0], HEX4[6:0]);
	HexDriver hex_driver3 (state, HEX3[6:0]); 
	HexDriver hex_driver2 (lower_sample_addr[7:4], HEX2[6:0]);
	HexDriver hex_driver1 (lower_sample_addr[3:0], HEX1[6:0]);
	HexDriverD hex_driver0 (4'b1111, HEX0[6:0]);

	logic [(RGB_SIZE - 1):0] ram_out, color_out;
	logic [9:0] query_addr;
	assign query_addr = {SW[9], SW[8], SW[7], SW[6], SW[5], SW[4], SW[3], SW[2], SW[1], SW[0]};
	logic [7:0] data_b_out;
	logic query_flag;
	assign query_flag = ~(KEY[0]);
	logic [7:0] lower_sample_addr;

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

		// output
		.next_state(next_state),
		.state(state),
		.sram_out_test(sram_out_test),

		// @NEW (SPI)
		.SPI_CLK(SPI_CLK),
		.SPI_MOSI(SPI_MOSI),
		.SPI_MISO(SPI_MISO),
		.SPI_CS(SPI_CS),
		.true_rst(true_rst),
		.request_flag(request_flag),

		// debug
		.query_addr(query_addr),
		.query_flag(query_flag),
		.data_b_out(data_b_out),
		.read_on_led(LED[0]),
		.write_on_0_led(LED[1]),
		.write_on_1_led(LED[2]),
		.await_led(LED[3]),

		.lower_sample_addr(lower_sample_addr)
	);
	assign LED[4] = query_flag;
	assign LED[5] = 1'b1;
	assign LED[6] = 1'b0;



endmodule 