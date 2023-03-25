module pixel_traversal

# (
	parameter CLOCK_SPEED = 50000000,
	parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
	parameter IMAGEY = 64,
	parameter IMAGEX = 64,
	parameter IMAGE_SIZE = IMAGEY * IMAGEX,
	parameter IMAGEYlog2 = $clog2(IMAGEY), 
	parameter IMAGEXlog2 = $clog2(IMAGEX),
	parameter IMAGE_ADDR_WIDTH = $clog2(IMAGE_SIZE),
	parameter RGB_SIZE = 8,
	parameter ADJ_PIXELS = 4
) 
(
    input logic clk, rst, 
    input logic counter_en, 
	input logic load_state, 
    output logic [IMAGE_ADDR_WIDTH - 1:0] counter
); 



always_ff @(posedge clk) begin : COUNTER_ONE_S
    if(rst)begin 
        counter <= '0; 
    end 
	else if(load_state) begin 
		counter <= counter + 2'b10;                 
	end 
    else if(counter_en) begin 
        counter <= counter + 1'b1;                 
    end 
end 


endmodule 