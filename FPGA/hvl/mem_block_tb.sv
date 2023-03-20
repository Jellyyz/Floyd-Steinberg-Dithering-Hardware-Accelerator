// This test bench serves as a way for us to test how the memory cell actually works inside of the mem IP instantiated by quartus 
// Copyright ECE445 2023 
// By Gally Huang 
module mem_block_tb(); 
timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;


logic	[15:0]  addr_a = '0;
logic	[15:0]  addr_b = '0;
logic	clk = 0;
logic	[7:0]  data_a = '0;
logic	[7:0]  data_b = '0;
logic	wren_a = '0;
logic	rden_a = '0;
logic	wren_b = '0;
logic	rden_b = '0;
logic	[7:0]  q_a;
logic	[7:0]  q_b;

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 clk = ~clk;
end

initial begin: CLOCK_INITIALIZATION
    clk = 0;
end 

mem_block mem_block(

    // inputs
    .address_a(addr_a), 
    .address_b(addr_b), 
    .clock(clk), 
    .data_a(data_a), .data_b(data_b),
    .rden_a(rden_a), .rden_b(rden_b),
    .wren_a(wren_a), .wren_b(wren_b), 
    
    // outputs 
    .q_a(q_a), .q_b(q_b) 

); 



logic [31:0] i; 
logic [7:0] recieved_a, recieved_b; 

task write_memA(input [7:0] d_a, input [15:0] a_a); 

    addr_a = a_a; 
    data_a = d_a; 

endtask 

task read_memA(input [15:0] a_a, output [7:0] rx_a); 

    addr_a = a_a; 
    rx_a = q_a; 

endtask 

task write_memB(input [7:0] d_a, input [15:0] a_a); 

    addr_b = a_a; 
    data_a = d_a; 

endtask 

task read_memB(input [15:0] a_a, output [7:0] rx_a); 

    addr_b = a_a; 
    rx_a = q_a; 

endtask 

// task mosi(); 

// endtask

// task miso(); 

// endtask 



initial begin: TEST_VECTORS
        wren_a = 1'b0; 
        wren_b = 1'b0; 
        rden_a = 1'b0; 
        rden_b = 1'b0; 

#9;   

// ---------------------------- Tests to understand how basic memory works ---------------------------------
        // // I is used as an address to iterate through a 64x64 image. This fills up half of the memory.
        // for (i = 0; i < (8 * 64 * 64); i++)begin  
            // --------------- READING AND WRITING BOTH FROM A -------------------------------------
            // #1;
            // // memory writesA
            // wren_a = 1'b1;   
            // write_memA(($urandom % (2**8 - 1)), i);     
            // #1;
            // wren_a = 1'b0;
            
            // // memory readsA
            // #1;
            // rden_a = 1'b1; 
            // read_memA(i, recieved_a);
            // #1;
            // rden_a = 1'b0; 
            // ---------------  WRITING TO A AND THEN READING FROM B -------------------------------
            // #1;
            // // memory writesA
            // wren_a = 1'b1;   
            // write_memA(($urandom % (2**8 - 1)), i);     
            // #1;
            // wren_a = 1'b0;
            
            // // memory readsA
            // #1;                 // must have a clock cycle delay after writing before accessing again .
            // rden_b = 1'b1; 
            // read_memB(i, recieved_b);
            // #1;
            // rden_b = 1'b0; 


// --------------- Simulating Filling Up SRAM with Data and ITF -------------------------
        // I is used as an address to iterate through a 64x64 image. This fills up half of the memory.
        wren_a = 1'b1; 
        for (i = 0; i < (8 * 4 * 4); i++)begin  
            // Fill up SRAM through DataA
            write_memA(($urandom % (2**8 - 1)), i);  
            #2;
            
        end 
        wren_a = 1'b0; 

        #1;

        for (i = 0; i < (8 * 4 * 4); i++)begin  
            #1; 
            rden_a = 1'b1; 
            rden_b = 1'b1;
            // Read Memory from Q port A 
            read_memA(i, recieved_a); 
            // Read Memory from Q port B
            read_memB(i + 2, recieved_b);  
            #1;
            rden_a = 1'b0; 
            rden_b = 1'b0;
            
        end 

    





end 




endmodule 