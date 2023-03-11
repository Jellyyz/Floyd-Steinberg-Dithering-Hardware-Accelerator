// Use saved pinouts and ensure their I/O Standards are all at 3.3-V LTTVL via Pin Planner.
module TestSPI (


      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [1: 0]   KEY,

      ///////// SW /////////
      input    [6: 0]   SW,

    //   ///////// LED /////////
      output logic   [ 9: 0]   LED,

    //   ///////// HEX /////////
       output logic   [6: 0]   HEX0,
       output logic  [6: 0]   HEX1,
       output logic  [6: 0]   HEX2,
       output logic  [6: 0]   HEX3,
       output logic  [6: 0]   HEX4,
       output logic  [6: 0]   HEX5,

	//		//////// SPI /////////
   //    inout	[15: 0]		Arduino_IO
		input SPI_CLK,
		output SPI_MISO,
		input SPI_MOSI,
		input SPI_CS
		 

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
	logic clk_div;
	logic [25:0] clk_div_ctr;
	logic [7:0] received;
	logic rst;
	
	assign SPI_MISO = clk_div;
	assign rst = ~(KEY[1]);

	HexDriverOverload hex_driver5 (SPI_CLK, HEX5[6:0]);

	
	HexDriverOverload hex_driver4 (SPI_MISO, HEX4[6:0]);

		
	HexDriverOverload hex_driver3 (SPI_MOSI, HEX3[6:0]); 


	HexDriverOverload hex_driver2 (SPI_CS, HEX2[6:0]); 


	HexDriverOverload hex_driver1 (clk_div, HEX1[6:0]);

	
	HexDriver hex_driver0 (received, HEX0[6:0]);
	
	// Random clock divider to check if FPGA works and hexadecimal displays are mapped correctly (2nd to right display).
	always_ff @ (posedge MAX10_CLK1_50)
	begin: CLOCK_DIVIDER
		if (rst) begin
			clk_div <= 1'b0;
			clk_div_ctr <= 26'h0;
		end
		else if (clk_div_ctr == 26'h0) begin
			clk_div <= ~clk_div;
		end
		clk_div_ctr <= clk_div_ctr + 1'b1;
	end
	
	// Simple shift loop to store the received byte (settings: MSB_FIRST).
	always_ff @ (posedge SPI_CLK)
	begin: READ_BYTE
		if (rst) begin
			received <= 8'h0;
		end
		else if (SPI_CS == 1'b0) begin
			received <= {received[6:0], SPI_MOSI};
		end
	end

endmodule 