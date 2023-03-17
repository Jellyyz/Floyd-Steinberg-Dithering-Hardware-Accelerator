// module mem_block
// # (
//     parameter CLOCK_SPEED = 50000000,
//     parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
//     parameter IMAGEY = 0,
//     parameter IMAGEX = 0,
//     parameter IMAGE_SIZE = IMAGEY * IMAGEX,
//     parameter IMAGE_ADDR_WIDTH = 0, // clog of image size
//     parameter RGB_SIZE = 8

// )

// (
//     input logic clk, 
//     input logic wr_en, rd_en, 
//     input logic [(RGB_SIZE - 1):0] data_in,
//     input logic [(IMAGE_ADDR_WIDTH - 1):0] rd_addr,
//     input logic [(IMAGE_ADDR_WIDTH - 1):0] wr_addr,

//     output logic [(RGB_SIZE - 1):0] data_out
// );

//     logic [(RGB_SIZE - 1):0] ram[(IMAGE_SIZE- 1):0]; /* synthesis ramstyle = "no_rw_check, M9K" */
//     initial begin :INIT_M9KVAL
//        integer i;
//        for(i = 0; i < IMAGE_SIZE; i++)begin 
//             ram[i] = 8'h0; 
//        end 
//     end 

//     always_ff @(posedge clk) begin
//         if (wr_en) begin
//             ram[wr_addr] <= data_in; // write
//         end
//         else if (rd_en) begin 
//             data_out <= ram[rd_addr]; // read
//         end 
//     end

// endmodule


// // // Quartus Prime Verilog Template
// // // Simple Dual Port RAM with separate read/write addresses and
// // // single read/write clock

// // module mem_block

// // #(
// //     parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6,
// //         parameter CLOCK_SPEED = 50000000,
// //     parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
// //     parameter IMAGEY = 16,
// //     parameter IMAGEX = 16,
// //     parameter IMAGE_SIZE = IMAGEY * IMAGEX,
// //     parameter IMAGE_ADDR_WIDTH = 0, // clog of image size
// //     parameter RGB_SIZE = 8

    
    
    
// //     )
// // (
// // 	input [(DATA_WIDTH-1):0] data_in,
// // 	input [(ADDR_WIDTH-1):0] rd_addr, wr_addr,
// // 	input wr_en, clk,
// // 	output logic [(DATA_WIDTH-1):0] data_out
// // );

// // 	// Declare the RAM variable
// // 	logic [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

// // 	always @ (posedge clk)
// // 	begin
// // 		// Write
// // 		if (wr_en)
// // 			ram[wr_addr] <= data_in;

// // 		// Read (if read_addr == write_addr, return OLD data).	To return
// // 		// NEW data, use = (blocking write) rather than <= (non-blocking write)
// // 		// in the write assignment.	 NOTE: NEW data may require extra bypass
// // 		// logic around the RAM.
// // 		data_out <= ram[rd_addr];
// // 	end

// // endmodule





// // Quartus Prime Verilog Template
// // Simple Dual Port RAM with separate read/write addresses and
// // separate read/write clocks

// // module simple_dual_port_ram_dual_clock
// // #(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
// // (
// // 	input [(DATA_WIDTH-1):0] data,
// // 	input [(ADDR_WIDTH-1):0] read_addr, write_addr,
// // 	input we, read_clock, write_clock,
// // 	output logic [(DATA_WIDTH-1):0] q
// // );
	
// // 	// Declare the RAM variable
// // 	logic [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	
// // 	always @ (posedge write_clock)
// // 	begin
// // 		// Write
// // 		if (we)
// // 			ram[write_addr] <= data;
// // 	end
	
// // 	always @ (posedge read_clock)
// // 	begin
// // 		// Read 
// // 		q <= ram[read_addr];
// // 	end
	
// // endmodule
