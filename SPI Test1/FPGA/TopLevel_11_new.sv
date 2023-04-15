// Use saved pinouts and ensure their I/O Standards are all at 3.3-V LTTVL via Pin Planner.
// Storing `n` bytes takes 8 * (n + 1) clock cycles (+ another 1 if uploading to MCU when MCU is in [Startup] state)
// https://www.fpga4fun.com/SPI2.html... copyrighted to  KNJN LLC
// CDC oversampling (100 MHz FPGA domain, 20 MHz SPI domain)
module TopLevel_11_new (


      	///////// Clocks /////////
      	input logic MAX10_CLK1_50, 

      	///////// KEY /////////
      	input logic [1:0] KEY,

      	///////// SW /////////
      	input logic [9 : 0] SW,

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
		input logic startup_flag,
		
		input logic [5:0] upper_addr,
		
		// Denotes whether data on the MISO line is valid (i.e., useful to the master) //
		output logic request
);
	logic rst;
	
	assign rst = ~(KEY[1]);

	
	HexDriverDot hex_driver5 (q_b[7:4], HEX5[6:0], iterator, HEX5[7]);

	
	HexDriver hex_driver4 (q_b[3:0], HEX4[6:0]);

		
	HexDriver hex_driver3 (byte_data_sent, HEX3[6:0]); 


	HexDriver hex_driver2 (idx_ptr2, HEX2[6:0]); 


	HexDriverDot hex_driver1 (sample_addr, HEX1[6:0], ~clk_div, HEX1[7]);

	
	HexDriverDot hex_driver0 (shift_addr, HEX0[6:0], ~clk_div, HEX0[7]);
	
	logic [3:0] addrs;
	assign addrs = (clk_div == 1'b1) ? sample_addr : shift_addr;
	logic [3:0] idx_ptrs;
	assign idx_ptrs = (clk_div == 1'b1) ? idx_ptr : idx_ptr2;
	
	logic [15:0] address_a = 16'h0, address_b = 16'h0;
	logic [7:0] data_a, data_b;
	logic rden_a;
	logic rden_b;
	logic wren_a;
	logic wren_b;
	logic [7:0] q_a, q_b;
	logic rep;
	
	assign LED[0] = read_on[0];
	assign LED[1] = write_on[0];
	assign LED[2] = write_on[1];
	assign LED[3] = rden_b;
	assign LED[4] = wren_b;
	assign LED[5] = rden_a;
	assign LED[6] = wren_a;
	assign LED[7] = terminal;
	assign LED[8] = rep;
	assign LED[9] = upper_addr[5];


	mem_block pixel_sram(
        // inputs
        .address_a(address_ptr), 
        .address_b(query_addr), 
        .clock(MAX10_CLK1_50),
        .data_a(byte_data_received), .data_b(data_b),
        .rden_a(rden_a), .rden_b(rden_b),
        .wren_a(wren_a), .wren_b(wren_b), 
        
        // outputs 
        .q_a(q_a), .q_b(q_b) 
   );
	
	logic CLK_100, CLK_150, CLK_200;
	
	pll	pll_inst (
		.inclk0 (MAX10_CLK1_50),
		.c0 (CLK_100),
		.c1 (CLK_150),
		.c2 (CLK_200)
	);
	
	
	logic [15:0] query_addr;
	assign query_addr = {upper_addr[5], upper_addr[4], upper_addr[3], upper_addr[2], upper_addr[1], upper_addr[0], SW[9], SW[8], SW[7], SW[6], SW[5], SW[4], SW[3], SW[2], SW[1], SW[0]};
	
	logic [15:0] sample_addr = '1, shift_addr = '1, fn_address_ptr, address_b_ptr, address_ptr;

	
	logic [7:0] byte_data_received;
	logic [7:0] byte_data_sent = 8'b01010101;
	logic [2:0] idx_ptr;
	logic [1:0] write_on = 2'b01, read_on = 2'b00;
	
	
	logic wren_a_reg;
	logic repeat_flag = 0;
	logic terminal;
	assign wren_a = (write_on[1] == 1'b0) ? wren_a_reg : 0;
	
	always_ff @ (posedge SPI_CLK)
	begin: DATA_SAMPLE
		rden_b <= 1;

		if (SPI_CS == 0 && write_on[0] == 1) begin
			repeat_flag <= 0;
			shift_addr <= '1;
			idx_ptr2 <= 0;
			byte_data_received <= {byte_data_received[6:0], SPI_MOSI};
			idx_ptr <= idx_ptr + 1;
			
			if (idx_ptr == 0) begin
				sample_addr <= sample_addr + 1;
				wren_a_reg <= 0;
			end
			else if (idx_ptr == 7) begin
				wren_a_reg <= 1;
				if (sample_addr == '1) begin
					write_on[0] <= 0;
				end
			end
			else begin
				wren_a_reg <= 0;
			end
		end
		else begin
			//wren_a_reg <= 1;
			//shift_addr <= '1;
			//idx_ptr2 <= '0;
		end
		
		if (SPI_CS == 0 && read_on[0] == 1) begin
			sample_addr <= '1;
			idx_ptr <= 0;
			rden_a <= 1;
			idx_ptr2 <= idx_ptr2 + 1;
			if (idx_ptr2 == 0) begin
				shift_addr <= shift_addr + 1;
			end
			
			if (idx_ptr2 == 7) begin
				byte_data_sent <= q_a;
				if (shift_addr == '0 && repeat_flag == 1) begin
					write_on[0] <= 1;
				end
				if (shift_addr > '0) begin
					repeat_flag <= 1;
				end
			end
			else begin
				byte_data_sent <= {byte_data_sent[6:0], 1'b0};
			end
			
			
			SPI_MISO <= byte_data_sent[7];
		end
		else begin
			//sample_addr <= '1;
			//idx_ptr <= '0;
			SPI_MISO <= byte_data_sent[7];
		end
	end
	
	logic [2:0] idx_ptr2 = 3'h0;
	assign address_ptr = (write_on[0] == 1'b0 && write_on[1] == 1'b1 && wren_a == 1'b0) ? shift_addr : sample_addr;
	
	assign request = read_on[0];
	
	//assign SPI_MISO = byte_data_sent[7];
	
	assign address_b_ptr = (write_on[0] == 1'b0 && read_on[0] == 1'b0 && ~rst) ? fn_address_ptr : query_addr;
	logic [7:0] new_byte;
	logic [5:0] ctr;
	logic fn;
	logic fn_trigger;
	assign fn_trigger = ~(KEY[0]);
	
	// Your blackbox algorithm on memory must start at read_en[0] == 1'b0
	// It must set read_on[0] == 1'b1 when done...
	always_ff @ (posedge MAX10_CLK1_50)
	begin: FAKE_FN
		if (write_on[0] == 1'b1) begin
			ctr <= 6'h0;
			wren_b <= 1'b0;
			fn <= 1'b0;
			write_on[1] <= 0;
			read_on[0] <= 0;
			fn_address_ptr <= '0;
		end
		else if (write_on[0] == 1'b0 && write_on[1] == 1'b0) begin
			write_on[1] <= 1'b1;
		end
		else if (read_on[0] == 1'b0 && ~fn) begin
			if (fn_trigger) begin
				fn <= 1'b1;
			end
		end
		else if (read_on[0] == 1'b0) begin
			if (fn_address_ptr == '1) begin
				read_on[0] <= 1'b1;
				wren_b <= 1'b0;
				fn <= 1'b0;
			end
			else begin
				//data_b <= (q_b > 64) ? q_b + 1 : q_b;
				//wren_b <= 1'b1;
			
				if (ctr == 5'b11111) begin
					fn_address_ptr <= fn_address_ptr + 1;
				end
			
				ctr <= ctr + 1;
			end
		end
		else begin
			wren_b <= 1'b0;
		end
	end



    logic clk_div, spi_clk_div;
	logic [24:0] clk_div_ctr;
	
	// Random clock divider to check if FPGA works and hexadecimal displays are mapped correctly (2nd to right display).
	always_ff @ (posedge MAX10_CLK1_50)
	begin: CLOCK_DIVIDER
		if (clk_div_ctr == 25'h0) begin
			clk_div <= ~clk_div;
		end
		clk_div_ctr <= clk_div_ctr + 1'b1;
	end
	
    logic [2:0] iterator;
	always_ff @ (posedge clk_div)
	begin: ITERATE
		iterator <= iterator + 1'b1;
	end
	
endmodule 