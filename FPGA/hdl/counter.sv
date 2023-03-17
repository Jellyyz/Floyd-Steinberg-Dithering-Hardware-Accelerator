module counter(

    input logic clk

);

    logic [31:0] counter;
    always_ff @(posedge clk)begin 
        counter <= counter + 1'b1; 
    end 


endmodule