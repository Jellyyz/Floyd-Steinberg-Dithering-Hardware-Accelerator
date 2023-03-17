// UIUC ECE 445 Senior Design
// RTL by : Gally Huang

module pixel_algorithm_unit
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
	parameter IMAGESIZElog2idx = ($clog2(IMAGE_SIZE) - 1),
	parameter ADJ_PIXELS = 4
) 
 
(
    // 64 * 64 image = 4096 addressing for 8 bit data 
    // CLk - Rst Interface
    // 50 mhz clock  
    input logic clk, rst, 
    input logic [RGB_SIZE - 1:0] color,
    input logic LD_RAM, RD_RAM, 
    input logic [IMAGE_ADDR_WIDTH - 1:0] WR_RAM_ADDR, RD_RAM_ADDR,
    output logic [RGB_SIZE - 1:0] color_out,
    output logic done_compute 
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




// adapted version for our hardware 
// for i until image size
//     state 1 old <= sram[x][y]
//     state 2 sram[x][y] <= closest_pixel 
//     state 2 quant_error <= old - closest_pixel 
//     state 3 sram[x + 1][y] <= sram[x + 1][y] + ((quant_error >> 4) * 7)
//     state 4 sram[x - 1][y + 1] <= sram[x - 1][y + 1] + ((quant_error >> 4) * 3)
//     state 5 sram[x][y + 1] <= sram[x][y + 1] + ((quant_error >> 4) * 5)
//     state 6 sram[x + 1][y + 1] <= sram[x + 1][y + 1] + (quant_error >> 4)    
// on state 3 read srame and store into buffer
// on state 4 read sramsw and store into buffer, also store srame buffer into sram again 
// on state 5 read srams and store into buffer, also store sramw buffer into sram again 
// on state 6 read sramse and store into buffer, also store srams buffer into sram again 
// on state 6 [x][y] must ++
// on state 1 store sram pixel_traversal into old, also store sramse buffer into sram again 
// repeat 
    logic reset_dithering;
    logic store_old_p;
    logic compare_and_store_n;

    logic [3:0] compute_fin;
    logic [IMAGESIZElog2idx:0] pixel_sweeper;
    logic [RGB_SIZE - 1:0] ram_out; 
	logic [IMAGE_ADDR_WIDTH - 1:0] ram_rd_addr, ram_wr_addr;
    assign done_compute = compute_fin; 

    mem_block pixel_sram(
        // inputs
        .address_a(), 
        .address_b(), 
        .clock(), 
        .data_a(), .data_b(),
        .rden_a(), .rden_b(),
        .wren_a(), .wren_b(), 
        
        // outputs 
        .q_a(), .q_b() 
    );
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
    // temporarily store the 4 adjacent sram data into here 
    logic [RGB_SIZE - 1:0] png_data_color_buffer [ADJ_PIXELS];

    // contains the old pixel - reg 
    logic [RGB_SIZE - 1:0] png_data_color_buffer_old; 

    // closest pixel to old pixel - some wire 
    logic [RGB_SIZE - 1:0] png_data_color_closest; 

    // quant_error - reg 
    logic [RGB_SIZE - 1:0] png_data_color_buffer_q_error; 

    // the correct "new" RGB value of the png_data (wire connecting to the register unit)
    logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_e;
    logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_sw;
    logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_s;
    logic [RGB_SIZE - 1:0] png_data_color_buffer_sweeped_se;

    // temp values that have the correct current indexing for the pixel counter 
    logic [IMAGE_SIZE:0] pixel_sweeper_e; 
    logic [IMAGE_SIZE:0] pixel_sweeper_sw; 
    logic [IMAGE_SIZE:0] pixel_sweeper_s; 
    logic [IMAGE_SIZE:0] pixel_sweeper_se; 

    always_comb begin: PIXEL_SWEEPER_CALC
        pixel_sweeper_e = pixel_sweeper + 1'b1; 
        pixel_sweeper_sw = pixel_sweeper + (IMAGEY - 1); 
        pixel_sweeper_s = pixel_sweeper + (IMAGEY); 
        pixel_sweeper_se = pixel_sweeper + (IMAGEY + 1); 
    end 
    always_comb begin: READ_RAM_ADDR_AND_DATA_OUT
        if(store_old_p || compare_and_store_n)begin 
            ram_rd_addr = pixel_sweeper;
        end    
    end
    always_comb begin: WRITE_RAM_ADDR_AND_DATA_IN 
        unique case(compute_fin)
            4'b0001:begin 
                ram_rd_addr = pixel_sweeper_e; 
            end 
            4'b0010:begin 
                ram_rd_addr = pixel_sweeper_sw; 
            end
            4'b0100:begin 
                ram_rd_addr = pixel_sweeper_s; 
            end
            4'b1000:begin 
                ram_rd_addr = pixel_sweeper_se;
            end 
            4'b0000:begin 
                ram_rd_addr = pixel_sweeper; 
            end 
        endcase 
    end  
    always_ff @(posedge clk or posedge rst) begin : OLD_PIXEL_REG

        if(rst) begin 
            png_data_color_buffer_old <= '0; 
        end 
        else if(store_old_p) begin 
            png_data_color_buffer_old <= ram_out;
        end 
    end

    always_ff @(posedge clk or posedge rst) begin : QUANT_ERROR_REG

        if(rst) begin 
            png_data_color_buffer_q_error <= '0; 
        end 
        else begin 
            png_data_color_buffer_q_error <= (png_data_color_buffer_old - png_data_color_closest);
        end 

    end 

    logic [RGB_SIZE - 1:0] png_quant_div_16; 

    always_comb begin : COMPUTE_PIXELS
        
        // " logic [x] name [y];" you index it this way "name[y][x]"
   

        png_quant_div_16 = png_data_color_buffer_q_error >> 4; 
        // account for going out of bounds
        if(pixel_sweeper_e != (IMAGEX - 1'b1)) begin 
            png_data_color_buffer_sweeped_e = png_data_color_buffer[pixel_sweeper_e][(RGB_SIZE-1):0] + ((png_quant_div_16) * 3'b111);
        end 
        // Left cnd: True if pixel_sweeper not on bottom row
        if (pixel_sweeper < (IMAGE_SIZE - IMAGEY)) begin
            // SW : Can do it if pixel_sweeper not on leftmost column (modulo IMAGEX != 0)
            if (pixel_sweeper != '0) begin
                png_data_color_buffer_sweeped_sw = png_data_color_buffer[pixel_sweeper_se][(RGB_SIZE-1):0] + ((png_quant_div_16) * 2'b11); 
            end
            // S : Can do it if got inside this loop 
            png_data_color_buffer_sweeped_s = png_data_color_buffer[pixel_sweeper_s] + ((png_quant_div_16) * 3'b101); 
            // SE : Can do it if pixel_sweeper not on rightmost column (modulo IMAGEX != IMAGEX - 1)
            if (pixel_sweeper != (IMAGEX - 1'b1)) begin
                png_data_color_buffer_sweeped_se = png_data_color_buffer[pixel_sweeper_sw][(RGB_SIZE-1):0] + (png_quant_div_16); 
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