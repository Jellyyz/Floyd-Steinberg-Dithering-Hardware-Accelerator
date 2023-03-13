// UIUC ECE 445 Senior Design
// RTL by : Gally Huang

module pixel_algorithm_unit
# (
parameter CLOCK_SPEED = 50000000,
parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
parameter IMAGEY = 64, // Assume image is resized such that x, y are base2 (possible on server-side)
parameter IMAGEX = 64,
parameter IMAGE_SIZE = IMAGEY * IMAGEX,
parameter RGB_SIZE = 8, 
parameter IMAGEYlog2 = $clog2(IMAGEY), 
parameter IMAGEXlog2 = $clog2(IMAGEX) 
)
 
(
    // 64 * 64 image = 4096 addressing for 8 bit data 

  

    // CLk - Rst Interface
    // 50 mhz clock  
    input logic clk, rst, 
    input logic [RGB_SIZE - 1:0] color,
    output logic [RGB_SIZE - 1:0] color_out
); 

// wikipedia formula : 
// for each y from top to bottom do
//     for each x from left to right do
//state 1            oldpixel := pixels[x][y] 
//state 2  -no need? // newpixel := find_closest_palette_color(oldpixel)
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
    .clk(clk), .rst(rst),

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
logic [IMAGE_SIZE:0] pixel_sweeper_e; 
logic [IMAGE_SIZE:0] pixel_sweeper_sw; 
logic [IMAGE_SIZE:0] pixel_sweeper_s; 
logic [IMAGE_SIZE:0] pixel_sweeper_se; 
always_ff @(posedge clk)begin 

    color_out <=  png_data_color_buffer[pixel_sweeper];

end 

always_ff @(posedge clk or posedge rst) begin : PNG_color_REG
    if(rst) begin
	 int i; 
        for(i = 0; i < 4096; i++) begin 
            png_data_color_buffer[i] <= 8'b10101010; 
        end
    end 
    else begin
        if (compare_and_store_n) begin 
            png_data_color_buffer[pixel_sweeper] <= png_data_color_closest;
        end 
        else if(compute_fin) begin 

            png_data_color_buffer[pixel_sweeper_e] <= png_data_color_buffer_sweeped_r;
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


always_ff @(posedge clk or posedge rst) begin : QUANT_ERROR_CALC

    if(rst) begin 
        png_data_color_buffer_q_error <= '0; 
    end 
    else begin 
        png_data_color_buffer_q_error <= (png_data_color_buffer_old - png_data_color_closest);
    end 

end 
logic [RGB_SIZE - 1:0] png_mult_16; 
always_comb begin : COMPUTE_PIXELS
    


    png_data_color_buffer_sweeped_sw = '0; 
    png_data_color_buffer_sweeped_s = '0;  
    png_data_color_buffer_sweeped_se = '0;  


    pixel_sweeper_e = pixel_sweeper + 1'b1; 
    pixel_sweeper_sw = pixel_sweeper + (IMAGEY - 1); 
    pixel_sweeper_s = pixel_sweeper + (IMAGEY); 
    pixel_sweeper_se = pixel_sweeper + (IMAGEY + 1); 
    // account for going out of bounds
    if(pixel_sweeper_e[(IMAGEXlog2 - 1) : 0] != (IMAGEX - 1'b1))
        png_data_color_buffer_sweeped_r = png_data_color_buffer[pixel_sweeper_e] + (png_mult_16) * 7;
    else 
        png_data_color_buffer_sweeped_r = '0;
    
    // Left cnd: True if pixel_sweeper not on bottom row
    if (pixel_sweeper < (IMAGE_SIZE - IMAGEY)) begin
        // SW : Can do it if pixel_sweeper not on leftmost column (modulo IMAGEX != 0)
        if (pixel_sweeper[(IMAGEXlog2 - 1): 0] != '0) begin
            png_data_color_buffer_sweeped_sw = png_data_color_buffer[pixel_sweeper_se] + (png_mult_16) * 3; 
        end
        // S : Can do it if got inside this loop 
        png_data_color_buffer_sweeped_s = png_data_color_buffer[pixel_sweeper_s] + (png_mult_16) * 5; 
        // SE : Can do it if pixel_sweeper not on rightmost column (modulo IMAGEX != IMAGEX - 1)
        if (pixel_sweeper[(IMAGEXlog2 - 1): 0] != (IMAGEX - 1'b1)) begin
            png_data_color_buffer_sweeped_se = png_data_color_buffer[pixel_sweeper_sw] + (png_mult_16); 
        end
    end  
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
// 7 = color[x + 1]  // e
// 3 = color[x + 63] // sw 
// 5 = color[x + 64] // s 
// 1 = color[x + 65]  // se


endmodule 