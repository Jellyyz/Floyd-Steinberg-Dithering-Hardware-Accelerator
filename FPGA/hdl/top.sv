module top(
    // CLk - Rst Interface 
    input logic clk, rst 
    input logic [7:0] red, green, blue 

); 

logic [31:0] png_data_red [7:0];
logic [31:0] png_data_green [7:0];
logic [31:0] png_data_blue [7:0];

always_ff @(posedge clk or posedge rst) begin 

    if(rst)
        png_data_red <= '0; 
    else

end 

endmodule 