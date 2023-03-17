// This module will control how the data is being flowed into the FPGA. Iniitally this is a way to have
// a non pipelined version of our accelerator 

module TopLevel_control 
# (
    parameter CLOCK_SPEED = 50000000,
    parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
    parameter IMAGEY = 0,
    parameter IMAGEX = 0,
    parameter IMAGE_SIZE = IMAGEY * IMAGEX,
    parameter IMAGE_ADDR_WIDTH = 0, // clog of image size
    parameter RGB_SIZE = 8

)

(
    input logic clk, rst, 
    output logic [IMAGE_ADDR_WIDTH-1:0] WR_RAM_ADDR,
    output logic [IMAGE_ADDR_WIDTH-1:0] RD_RAM_ADDR,
    input logic done_compute, 
    output logic LD_RAM,  
    output logic RD_RAM

); 

    logic top_level_control_rst; 
    logic ram_addr_counter_en; 
	 logic counter; 
    pixel_traversal ram_counter(
        .clk(clk), .rst(top_level_control_rst),
        .counter_en(ram_addr_counter_en),
        .counter(counter)
    );

    assign WR_RAM_ADDR = counter; 
    assign RD_RAM_ADDR = counter; 

	enum logic [2:0] {
		RESET,	    // Start state
	    LD_FPGA,	// Load the FPGA with all the initial memory contents from the MCU
		COMPUTE,	// Use the FPGA to apply the algorithm to all the memory contents in the RAM
		RD_FPGA	    // Send the data back to the MCU to print
	} curr_state, next_state;

	always_ff @ (posedge clk) 
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
                    next_state = LD_FPGA;
                end
                
                LD_FPGA: begin
                    if(counter < IMAGE_SIZE - 1) 
                        next_state = COMPUTE; 
                end
                
                COMPUTE: begin
                    if(done_compute)
                        next_state = RD_FPGA; 
                end
                
                RD_FPGA: begin
                    if(counter < IMAGE_SIZE - 1)
                        next_state = LD_FPGA;
                end
            endcase
        end
	
	always_ff @ (posedge clk) begin
        top_level_control_rst = 1'b0; 
        ram_addr_counter_en = 1'b0;
        LD_RAM = 1'b0; 
        RD_RAM = 1'b0; 
		unique case (curr_state)
			RESET: begin
                top_level_control_rst = 1'b1;  
			end
			
			LD_FPGA: begin
                ram_addr_counter_en = 1'b1; 
                LD_RAM = 1'b1; 
                
			end
			
			COMPUTE: begin 

			end
			
			RD_FPGA: begin
                ram_addr_counter_en = 1'b1;
                RD_RAM = 1'b1; 
			end
		
		endcase
	end



endmodule 