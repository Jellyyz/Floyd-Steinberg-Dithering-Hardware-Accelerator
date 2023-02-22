// UIUC ECE 445 Senior Design
// RTL by : Gally Huang

module pixel_algorithm_unit(
    // 64 * 64 image = 4096 addressing for 8 bit data 

    parameter CLOCK_SPEED = 50000000; 
    parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED; 
    parameter IMAGEY = 64; 
    parameter IMAGEX = 64; 
    parameter IMAGE_SIZE = IMAGE_SIZE; 
    parameter RGB_SIZE = 8; 

    // CLk - Rst Interface
    // 50 mhz clock  
    input logic clk, rst 
    input logic [RGB_SIZE - 1:0] color

); 

// wikipedia formula : 
// for each y from top to bottom do
//     for each x from left to right do
//state 1            oldpixel := pixels[x][y] 
//state 2  -no need? newpixel := find_closest_palette_color(oldpixel)
//state 2            pixels[x][y] := newpixel
//state 2            quant_error := oldpixel - newpixel
//state 3            pixels[x + 1][y    ] := pixels[x + 1][y    ] + quant_error × 7 / 16
//state 3            pixels[x - 1][y + 1] := pixels[x - 1][y + 1] + quant_error × 3 / 16
//state 3            pixels[x    ][y + 1] := pixels[x    ][y + 1] + quant_error × 5 / 16
//state 3            pixels[x + 1][y + 1] := pixels[x + 1][y + 1] + quant_error × 1 / 16
logic reset_dithering;
logic store_old_p;
logic compare_and_store_n;
logic compute_fin;
logic [15:0] pixel_sweeper; 

dithering_loop_control control0(

    // CLk - Rst Interface
    .clk(clk), .rst(rst)

    // control singals 
    .reset_dithering(reset_dithering), 
    .store_old_p(store_old_p),
    .compare_and_store_n(compare_and_store_n),  
    .compute_fin(compute_fin)
); 

pixel_traversal pix_trav0(
    .clk(clk), .rst(rst), 
    .pixel_sweeper(pixel_sweeper)
); 

logic [RGB_SIZE - 1:0] png_data_color_buffer [(IMAGE_SIZE):0];

// contains the old pixel 
logic [RGB_SIZE - 1:0] png_data_color_buffer_old; 

// closest pixel to old pixel
logic [RGB_SIZE - 1:0] png_data_color_closest;

// quant_error
logic [RGB_SIZE - 1:0] png_data_color_buffer_q_error; 

// the correct "new" RGB value of the png_data (wire connecting to the register unit)
logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_r;
logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_sw;
logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_s;
logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_se;

// temp values that have the correct current indexing for the pixel counter 
logic [15:0] pixel_sweeper_r; 
logic [15:0] pixel_sweeper_sw; 
logic [15:0] pixel_sweeper_s; 
logic [15:0] pixel_sweeper_se; 


always_ff @(posedge clk or posedge rst) begin : PNG_color_REG
    if(rst) begin
        for(i = 0; i < 4096; i++) begin 
            png_data_color_buffer[i] <= 8'b10101010; 
        end
    end 
    else begin
        if (compare_and_store_n) begin 
            png_data_color_buffer[pixel_sweeper] <= png_data_color_closest;
        end 
        else if(compute_fin) begin 

            png_data_color_buffer[pixel_sweeper_r] <= png_data_color_buffer_sweeped_r;
            png_data_color_buffer[pixel_sweeper_sw] <= png_data_color_buffer_sweeped_sw;
            png_data_color_buffer[pixel_sweeper_s] <= png_data_color_buffer_sweeped_s;
            png_data_color_buffer[pixel_sweeper_se] <= png_data_color_buffer_sweeped_se;
            
        end 
    end 
        
end 

always_ff @(posedge clk or posedge rst) begin : OLD_PIXEL

    if(rst) begin 
        png_data_color_buffer_old <= '0; 
    end 
    else if(store_old_p) begin 
        png_data_color_buffer_old <= png_data_color_buffer[pixel_sweeper];
    end 
end


always_ff @(posedge clk or posedge rst)begin : QUANT_ERROR_CALC

    if(rst) begin 
        png_data_color_buffer_q_error <= '0; 
    end 
    else begin 
        png_data_color_buffer_q_error <= (png_data_color_buffer_old - png_data_color_closest)
    end 

end 

always_comb begin 
    pixel_sweeper_r = pixel_sweeper + 15'd1; 
    pixel_sweeper_se = pixel_sweeper + 15'd63; 
    pixel_sweeper_s = pixel_sweeper + 15'd64; 
    pixel_sweeper_sw = pixel_sweeper + 15'd65; 
    // account for going out of bounds
    if(pixel_sweeper_r[5:0] == 6'b000000)
        png_data_color_buffer_sweeped_r = png_data_color_buffer[pixel_sweeper_r] + (png_data_color_closest >> 4) * 7;
    if(pixel_sweeper_sw <= IMAGE_SIZE)
        png_data_color_buffer_sweeped_sw = png_data_color_buffer[pixel_sweeper_se] + (png_data_color_closest >> 4) * 3; 
    if(pixel_sweeper_s <= IMAGE_SIZE)
        png_data_color_buffer_sweeped_s = png_data_color_buffer[pixel_sweeper_s] + (png_data_color_closest >> 4) * 5; 
    if(pixel_sweeper_se <= IMAGE_SIZE)
        png_data_color_buffer_sweeped_se = png_data_color_buffer[pixel_sweeper_sw] + (png_data_color_closest >> 4); 

end 

always_comb begin: CLOSEST_AND_QUANT_CALC

    png_data_color_closest = (png_data_color_buffer_old >= 128) ? 8'b11111111 : 8'h0; 

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