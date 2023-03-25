// This state machine helps drive the pixel accelerator in lieu of a pipelined design 
import states::*;
module dithering_loop_control 
# (
	parameter CLOCK_SPEED = 50000000,
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
    input logic clk, rst, 
    input logic MCU_TX_RDY, 

    output logic MCU_RX_RDY, 
    output logic rden_a, rden_b, 
    output logic wren_a, wren_b, 
    output logic store_old_p,
    output logic compare_and_store_n, 
    output logic [3:0] compute_fin, 
    output logic [IMAGE_ADDR_WIDTH - 1:0] png_idx,
    output states::state_t state, next_state, 
    output logic store_sram, 
    output logic [1:0] load_sram,
    output logic load_sram_logic,
    output logic full_png_idx

); 

logic png_counter_en; 
logic [IMAGE_ADDR_WIDTH - 1:0] pixel_sweeper; 
logic pixel_traversal_rst; 
logic dither_rst;

    always_ff @ (posedge clk)begin 
        if(rst)begin 
            state <= RESET;
        end 
        else begin 
            state <= next_state; 
        end 

    end 

    always_ff @ (posedge clk) begin : FULL_PNG_IDX
        if(rst) begin 
            full_png_idx <= 1'b0; 
        end 
        else begin
            full_png_idx <= (png_idx == (IMAGE_SIZE - 1));    
        end 
    end 


    always_comb 
    begin : next_state_condition 
        next_state = state; 
        unique case(state)
        // this is implemented for correctness - non-pipelined implementation
            RESET: begin 
                next_state = WAIT_FOR_MCU;
            end 
            WAIT_FOR_MCU:begin 
                // the mcu sends this signal to signify that it is ready to send out some data 
                if(MCU_TX_RDY)begin 
                    next_state = S1_STORE_IMAGE_SRAM; 
                end 
            end 
            S1_STORE_IMAGE_SRAM:begin 
                // once the FPGA detects that the signal is deasserted then we can start on S2 
                if(full_png_idx)begin 
                    next_state = S2_CC1; 
                end 
            end 
            S2_CC1:begin 
                next_state = S2_CC2; 
            end 
            S2_CC2:begin 
                next_state = S3_CC3; 
            end
            S3_CC3:begin 
                next_state = S3_CC4; 
            end 
            S3_CC4:begin 
                next_state = S3_CC5;
            end   
            S3_CC5:begin 
                next_state = S3_CC6;
            end 
            S3_CC6:begin 
                // if the computation is done then we can move on to the reading back from the FPGA
                if(full_png_idx)begin 
                    next_state = S4_CC1; 
                end 
                // else continue to store new pixels
                else begin 
                    next_state = S2_CC1; 
                end 
            end 
            S4_CC1:begin  
                next_state = S4_CC2; 
            end 
            S4_CC2:begin 
                if(full_png_idx)begin 
                    next_state = WAIT_FOR_MCU; 
                end
                next_state = S4_CC1; 
            end     
        endcase 
    
    end  
    always_comb begin : state_condition 
        store_old_p = 1'b0; 
        compare_and_store_n = 1'b0; 
        compute_fin = 4'b0000;
        load_sram = 2'b00;
        store_sram = 1'b0; 
        dither_rst = 1'b0; 
        unique case(state)
            RESET: begin  
                dither_rst = 1'b1; 
            end 
            WAIT_FOR_MCU:begin 
                // wait for a signal from the user
            end 
            S1_STORE_IMAGE_SRAM:begin 
                store_sram = 1'b1; 
            end 
            S2_CC1:begin 
                store_old_p = 1'b1; 
            end 
            S2_CC2:begin 
                compare_and_store_n = 1'b1; 
            end
            S3_CC3:begin // read 
                compute_fin = 4'b0001;
            end 
            S3_CC4:begin // write 
                compute_fin = 4'b0010;
            end 
            S3_CC5:begin // read
                compute_fin = 4'b0100;
            end   
            S3_CC6:begin // write
                compute_fin = 4'b1000;
            end 
            S4_CC1:begin 
                load_sram = 2'b10; 
            end  
            S4_CC2:begin 
                load_sram = 2'b01; 
            end 

        endcase 
    end 
    always_comb begin 
        if(load_sram == 2'b01 || load_sram == 2'b10)begin 
            load_sram_logic = 1'b1; 
        end 
        else begin 
            load_sram_logic = 1'b0; 
        end
    end 
    always_comb begin 
        wren_a = ~load_sram_logic && (compare_and_store_n || store_sram && ~full_png_idx || compute_fin[3] || compute_fin[1]); 
        wren_b = ~load_sram_logic && (compute_fin[3] || compute_fin[1]); 
        rden_a = store_old_p || load_sram[0] || compute_fin[2] || compute_fin[0]; 
        rden_b = load_sram[0] || (compute_fin[2] || compute_fin[0]);
        
        
        pixel_traversal_rst = full_png_idx && (store_sram || compute_fin[3] || load_sram_logic || dither_rst );
        png_counter_en =  ~load_sram && ~full_png_idx && (store_sram || compute_fin[3]);   // enable pxl address traversal in sram  
                                                                     // s1
                                                                     // last step of s3
                                                                     // when storing back into mcu
        
    end 


// use pixel_traversal module in order to keep track of where we are in the image 
pixel_traversal pixel_traversal(

    .clk(clk), .rst(pixel_traversal_rst || rst), 
    .load_state(load_sram[1]), 
    .counter_en(png_counter_en), .counter(png_idx)

);



    always_ff @ (posedge clk) begin : MCU_RX
        if(rst) begin 
            MCU_RX_RDY <= 1'b0; 
        end 
        else if(load_sram_logic) begin
            MCU_RX_RDY <= 1'b1;    
        end 
    end 




endmodule 