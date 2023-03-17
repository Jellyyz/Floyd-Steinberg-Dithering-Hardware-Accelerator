module SPI_control(
	input logic clk, rst, 
	input logic SPI_CLK,
	output logic SPI_MISO,
	input logic SPI_MOSI,		
	input logic SPI_CS,  
	output logic [7:0] curr_byte,
	output logic [7:0] first_byte,
	output logic [7:0] last_byte
); 

	// `shifts` = number of shifts in current SPI transfer (0 - 8)
	// `ptr` = pointer to array (to current byte to be transferred)
	logic [7:0] received [7:0];
	logic [3:0] received_shifts = 4'h0;
	logic [6:0] received_ptr = 7'h0;
	
	logic [7:0] sent;
	logic [3:0] sent_shifts = 4'h0;
	logic [6:0] sent_ptr = 7'h0;

	assign curr_byte = received[received_ptr];
	assign first_byte = received[0];
	assign last_byte = received[7];

	enum logic [2:0] {
		RESET,	// Start state
		LOAD,	// Store bit to memory
		SHIFT,	// Shift memory
		DONE	// Finished storing byte
	} curr_state, next_state;

	always_ff @ (posedge SPI_CLK) 
	begin: STATE_TRANSITION
		if (rst) begin
			curr_state <= RESET;
		end
		else begin
			curr_state <= next_state;
		end
	end
	
	always_comb
	begin: STATE_CONTROL

	next_state = curr_state; 
	
		unique case (curr_state)
			RESET: begin
				next_state = LOAD;
			end
			
			LOAD: begin
				if (SPI_CS == 1'b1) begin
					next_state = RESET;
				end

				if (received_shifts == 4'h8) begin
					next_state = DONE;
				end
				else begin
					next_state = SHIFT;
				end
			end
			
			SHIFT: begin
				next_state = LOAD;
			end
			
			DONE: begin
				if (received_shifts == 4'h0) begin
					next_state = LOAD;
				end
				else begin
					next_state = DONE;
				end
			end
		endcase
	end
	
	always_ff @ (posedge SPI_CLK) begin
		unique case (curr_state)
			RESET: begin
				received_shifts <= '0;
				received_ptr <= '0;
				SPI_MISO <= 1'bZ;
			end
			
			LOAD: begin
				if (SPI_CS == 1'b0) begin
					received[received_ptr] <= {received[received_ptr][6:0], SPI_MOSI};
				end
				SPI_MISO <= 1'bZ; // Assume no MISO active for now
			end
			
			SHIFT: begin
				received_shifts <= received_shifts + 1'b1;
				SPI_MISO <= 1'bZ;
			end
			
			DONE: begin
				received_ptr <= received_ptr + 1'b1;
				received_shifts <= 4'h0;
			end
		
		endcase
	end



endmodule