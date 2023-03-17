module pixel_traversal

# (
parameter CLOCK_SPEED = 50000000,
parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
parameter IMAGEY = 64,
parameter IMAGEX = 64,
parameter IMAGE_SIZE = IMAGEY * IMAGEX,
parameter RGB_SIZE = 8)


(
    input logic clk, rst, 
    input logic counter_en, 
    output logic [31:0] counter, 
    output logic [15:0] pixel_sweeper,
    output logic one_s
); 




always_ff @(posedge clk or posedge rst) begin : COUNTER_ONE_S
    if(rst)begin 
        counter <= '0; 
    end 
    else if (counter == IMAGE_SIZE - 1) begin 
        counter <= '0; 
    end 
    else if(counter_en) begin 
        counter <= counter + 1'b1;                 
    end 
end 

always_comb begin : COUNTER_ONE_S_EN 
    if(counter == 32'd50000000)begin 
        one_s = 1'b1; 
    end 
    else begin 
        one_s = 1'b0; 
    end 
end 

always_ff @(posedge clk or posedge rst) begin : PIXEL_SWEEPER 

    if(rst) begin 
        pixel_sweeper <= '0; 
    end
    else if(pixel_sweeper > IMAGE_SIZE)begin 
        pixel_sweeper <= '0; 
    end 
    else if(one_s) begin 
        pixel_sweeper <= pixel_sweeper + 1'b1; 
    end 

end 


endmodule 