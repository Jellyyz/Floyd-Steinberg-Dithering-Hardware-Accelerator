module top(
    // CLk - Rst Interface
    // 50 mhz clock  
    input logic clk, rst 
    input logic [7:0] red, green, blue 

); 


// 64 * 64 image = 4096 addressing for 8 bit data 
parameter IMAGEY = 64; 
parameter IMAGEX = 64; 
parameter IMAGE_SIZE = IMAGE_SIZE; 
logic [7:0] png_data_red_buffer [(IMAGE_SIZE):0];
logic [7:0] png_data_green_buffer [(IMAGE_SIZE):0];
logic [7:0] png_data_blue_buffer [(IMAGE_SIZE):0];
parameter CLOCK_SPEED = 50000000; 
parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED; 


always_ff @(posedge clk or posedge rst) begin 
    if(rst)
        png_data_red_buffer <= '0; 
    else
        for(i = 0; i < 4096; i++)
            png_data_red_buffer[i] <= 8'b10101010; 
end 
logic [31:0] counter; 
logic one_s; 

always_ff @(posedge clk or posedge rst) begin : COUNTER_ONE_S
    if(rst)begin 
        counter <= '0; 
    end 
    else if (counter > 32'd50000000)begin 
        counter <= '0; 
    end 

    else begin 
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
logic [15:0] pixel_sweeper; 
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

always_ff @(posedge clk or posedge rst)begin 

    if(rst)begin 
        
    end 
    else begin 
    
    end 

end 

logic [15:0] pixel_sweeper_r; 
logic [15:0] pixel_sweeper_sw; 
logic [15:0] pixel_sweeper_s; 
logic [15:0] pixel_sweeper_se; 

always_comb begin 
    pixel_sweeper_r = pixel_sweeper + 15'd1; 
    pixel_sweeper_se = pixel_sweeper + 15'd63; 
    pixel_sweeper_s = pixel_sweeper + 15'd64; 
    pixel_sweeper_sw = pixel_sweeper + 15'd65; 
    
    if(pixel_sweeper_r[5:0] == 6'b000000)
        (png_data_red_buffer[pixel_sweeper_r] >> 4) * 7;
    if(pixel_sweeper_sw <= IMAGE_SIZE)
        (png_data_red_buffer[pixel_sweeper_se] >> 4) * 3; 
    if(pixel_sweeper_s <= IMAGE_SIZE)
        (png_data_red_buffer[pixel_sweeper_s] >> 4) * 5; 
    if(pixel_sweeper_se <= IMAGE_SIZE)
        (png_data_red_buffer[pixel_sweeper_sw] >> 4); 

    

end 

//  x x x x
//  x x x x
//  x x x x
//  x x x x
//  x x x x
//  x x x x
//  x x x x
//  x * 7 x
//  3 5 1 x

//   (1/16)
// * = color[x] 
// 7 = color[x + 1]  // r
// 3 = color[x + 63] // sw 
// 5 = color[x + 64] // s 
// 1 = color[x + 65]  // se


endmodule 