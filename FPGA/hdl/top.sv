module top
# (
parameter CLOCK_SPEED = 50000000,
parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
parameter IMAGEY = 64,
parameter IMAGEX = 64,
parameter IMAGE_SIZE = IMAGEY * IMAGEX,
parameter RGB_SIZE = 8)

(


      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

    //   ///////// LEDR /////////
    //   output   [ 9: 0]   LEDR,

    //   ///////// HEX /////////
       output   [ 7: 0]   HEX0,
       output   [ 7: 0]   HEX1,
       output   [ 7: 0]   HEX2,
       output   [ 7: 0]   HEX3,
       output   [ 7: 0]   HEX4,
       output   [ 7: 0]   HEX5,

       output test

    //   ///////// SDRAM /////////
    //   output             DRAM_CLK,
    //   output             DRAM_CKE,
    //   output   [12: 0]   DRAM_ADDR,
    //   output   [ 1: 0]   DRAM_BA,
    //   inout    [15: 0]   DRAM_DQ,
    //   output             DRAM_LDQM,
    //   output             DRAM_UDQM,
    //   output             DRAM_CS_N,
    //   output             DRAM_WE_N,
    //   output             DRAM_CAS_N,
    //   output             DRAM_RAS_N,

    //   ///////// VGA /////////
    //   output             VGA_HS,
    //   output             VGA_VS,
    //   output   [ 3: 0]   VGA_R,
    //   output   [ 3: 0]   VGA_G,
    //   output   [ 3: 0]   VGA_B,


    //   ///////// ARDUINO /////////
    //   inout    [15: 0]   ARDUINO_IO,
    //   inout              ARDUINO_RESET_N 
 
);
   logic [IMAGE_SIZE:0] color_r_out;
   logic [IMAGE_SIZE:0] color_g_out;
   logic [IMAGE_SIZE:0] color_b_out;
 assign test = color_r_out[0] + color_g_out[0] + color_b_out[0];
pixel_algorithm_unit red(
	.clk(MAX10_CLK1_50), .rst(KEY[0]), 
    .color(8'b10100000),
    .color_out(color_r_out)
);

pixel_algorithm_unit green(
	.clk(MAX10_CLK1_50), .rst(KEY[0]), 
    .color(8'b10100000),
    .color_out(color_g_out)
);

pixel_algorithm_unit blue(
	.clk(MAX10_CLK1_50), .rst(KEY[0]), 
    .color(8'b10100000),
    .color_out(color_b_out)
);

	
	//Assign LED for debug
	//....
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver5 (4'b1111, HEX5[6:0]);
	assign HEX5[7] = 1'b1;
	
	HexDriver hex_driver4 (4'b1111, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
		
	HexDriver hex_driver3 (4'b1111, HEX3[6:0]); 
	assign HEX3[7] = 1'b1;

	HexDriver hex_driver2 (4'b1111, HEX2[6:0]); 
	assign HEX2[7] = 1'b1;

	HexDriver hex_driver1 (4'b1111, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (4'b1111, HEX0[6:0]);
	assign HEX0[7] = 1'b1;

endmodule 