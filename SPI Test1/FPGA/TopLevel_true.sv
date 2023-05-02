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
		S3_CC7,
		S3_CC8,

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
       	output logic [7:0] HEX0,
       	output logic [7:0] HEX1,
       	output logic [7:0] HEX2,
       	output logic [7:0] HEX3,
       	output logic [7:0] HEX4,
       	output logic [7:0] HEX5,

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

	logic LD_RAM, RD_RAM; 
	logic done_compute; 
	
	logic [(RGB_SIZE - 1):0] ram_out, color_out;
	logic [9:0] query_addr;
	assign query_addr = {SW[9], SW[8], SW[7], SW[6], SW[5], SW[4], SW[3], SW[2], SW[1], SW[0]};
	logic [7:0] q_b_out;
	logic query_flag;
	assign query_flag = ~(KEY[0]);
	logic [7:0] lower_sample_addr;
	logic [7:0] num_gos;
	logic read_on_out;
	logic load_sram_out;
	
	logic [IMAGE_ADDR_WIDTH - 1:0] png_idx_out;

	HexDriver hex_driver5 (q_b_out[7:4], HEX5[6:0]);
	HexDriver hex_driver4 (q_b_out[3:0], HEX4[6:0]);
	//HexDriverDot hex_driver3 (true_h_out[7:4], HEX3[6:0], ~(true_h_out[8]), HEX3[7]); 
	HexDriver hex_driver2 (true_h_out[3:0], HEX2[6:0]);
	//HexDriverDot hex_driver1 (true_w_out[7:4], HEX1[6:0], ~(true_w_out[8]), HEX1[7]);
	HexDriver hex_driver0 (true_w_out[3:0], HEX0[6:0]);

	logic slow_clk = 1'b0;
	logic [1:0] cntr;

	always_ff @ (posedge MAX10_CLK1_50) begin
		if (cntr == '0) begin
			slow_clk <= ~slow_clk;
		end
		cntr <= cntr + 1;
	end
	
	logic await_out;
	logic [8:0] true_w_out, true_h_out;


	pixel_algorithm_unit2 #(
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
		.fast_clk(MAX10_CLK1_50),
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
		.q_b_out(q_b_out),
		.read_on_out(read_on_out),
		.write_on_0_led(LED[1]),
		.write_on_1_led(LED[2]),
		.await_led(LED[3]),

		.lower_sample_addr(lower_sample_addr),
		.num_gos(num_gos),
		.load_sram_out(load_sram_out),
		.png_idx_out(png_idx_out),
		.await_out(await_out),
		.true_w_out(true_w_out),
		.true_h_out(true_h_out),
		.algorithm(SW[9:0])
	);
	assign LED[0] = read_on_out;

	assign LED[4] = query_flag;
	assign LED[5] = load_sram_out;

	assign LED[9] = state[3];
	assign LED[8] = state[2];
	assign LED[7] = state[1];
	assign LED[6] = state[0];



endmodule 