// Use saved pinouts and ensure their I/O Standards are all at 3.3-V LTTVL via Pin Planner.
module TestSPI (


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
	logic clk_div;
	logic [25:0] clk_div_ctr;
	
	// Each `received` is a byte. For this example, we have a maximum of 8 bytes ([7:0]) to receive.
	
	logic rst;
	
	// `shifts` = number of shifts in current SPI transfer (0 - 8)
	// `ptr` = pointer to array (to current byte to be transferred)
	logic [7:0] received [7:0];
	logic [2:0] received_shifts = 3'h0;
	logic [2:0] received_ptr = 3'h0;
	
	logic [7:0] sent;
	logic [2:0] sent_shifts = 3'h0;
	logic [2:0] sent_ptr = 3'h0;
	
	assign rst = ~(KEY[1]);

	//HexDriverD hex_driver5 (SPI_CLK, HEX5[6:0]);

	
	//HexDriverD hex_driver4 (SPI_MISO, HEX4[6:0]);

		
	//HexDriverD hex_driver3 (SPI_MOSI, HEX3[6:0]); 


	//HexDriverD hex_driver2 (SPI_CS, HEX2[6:0]); 


	//HexDriver hex_driver1 (sent, HEX1[6:0]);
	
	
	HexDriverD hex_driver5 (SPI_CLK, HEX5[6:0]);

	
	HexDriverD hex_driver4 (SPI_MISO, HEX4[6:0]);

		
	HexDriverD hex_driver3 (SPI_MOSI, HEX3[6:0]); 


	HexDriver hex_driver2 (received[7], HEX2[6:0]); 


	HexDriver hex_driver1 (received[0], HEX1[6:0]);

	
	HexDriver hex_driver0 (received[received_ptr], HEX0[6:0]);
	
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
			received_ptr <= 3'h0;
		end
		else if (SPI_CS == 1'b0) begin
			received[received_ptr] <= {received[received_ptr][6:0], SPI_MOSI};
			if (received_shifts == 3'h7) begin
				received_shifts <= 3'h0;
				received_ptr <= received_ptr + 1'b1;
			end
			else begin
				received_shifts <= received_shifts + 1'b1;
			end
		end
	end
	
	// Sending data loop 
	/*always_ff @ (posedge SPI_CLK)
	begin: SEND_BYTE
		if (SPI_CS == 1'b1) begin
			SPI_MISO <= 1'bZ;
		end
		else begin
			if (data_valid == 1'b0) begin
				SPI_MISO <= 1'bZ;
			end
			else begin
				SPI_MISO <= sent[7 - sent_shifts];
				sent_shifts <= sent_shifts + 1'b1;
				if (sent_shifts == 4'h8) begin
					sent_shifts <= 4'h0;
				end
			end
		end
	end*/
	
	//always_ff @ (posedge SPI_CS) begin
		// data_valid : writeable
	//end

	// Processing loop
	// Assume random process function f(b) = b ^ 8'b01010101
endmodule 