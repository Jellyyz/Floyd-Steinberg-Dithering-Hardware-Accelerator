// This state machine helps drive the pixel accelerator in lieu of a pipelined design 
import states::*;
module dithering_loop_control 
# (
	parameter CLOCK_SPEED = 50000000,
	parameter IMAGEY = 256,
	parameter IMAGEX = 256,
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

    output logic rden_a, rden_b, 
    output logic wren_a, wren_b, 
    output logic store_old_p,
    output logic compare_and_store_n, 
    output logic [4:0] compute_fin, 
    output logic [IMAGE_ADDR_WIDTH - 1:0] png_idx,
    output states::state_t state, next_state, 
    output logic store_sram, 
    output logic load_sram,
    output logic full_png_idx,
    input logic write_on_0,
    output logic write_on_1,
    output logic read_on
); 

logic png_counter_en; 
logic [IMAGE_ADDR_WIDTH - 1:0] pixel_sweeper; 
logic pixel_traversal_rst; 
logic dither_rst;
logic full_png_rst; 
logic good;

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
            full_png_idx <= '0; 
        end 
        else begin
            full_png_idx <= (png_idx == (IMAGE_SIZE - 1) && ~compute_fin[4]);    
        end 
    end 
    always_ff @ (posedge clk) begin : FULL_PNG_RST
        if(rst) begin 
            full_png_rst <= '0;
        end 
        else begin
            full_png_rst <= compute_fin[3] && full_png_idx; 
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
                if(write_on_0 == 1'b0)begin 
                    next_state = WAIT_FOR_MCU_STALL; 
                end 
            end
            WAIT_FOR_MCU_STALL:begin
                if (stall == 3)
                    next_state = S2_CC1;
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
                next_state = S3_CC7; 
            end     
            S3_CC7:begin 
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
				if (write_on_0 == 1)
                next_state = RESET;
            end 
				default:begin 
					; 
				end 
        endcase 
    end  

    logic [25:0] stall;
    always_ff @ (posedge clk) begin
        if (state == WAIT_FOR_MCU_STALL) 
            stall <= stall + 1;
    end

    logic dummy;
    always_comb begin : state_condition 
        store_old_p = '0; 
        compare_and_store_n = '0; 
        compute_fin = '0;
        load_sram = '0;
        store_sram = '0; 
        dither_rst = '0;
        //read_on = 0;
        //good = 0;
        unique case(state)
            RESET: begin  
                dither_rst = 1'b1;
            end 
            WAIT_FOR_MCU:begin 
                // wait for a signal from the user

            end 
            WAIT_FOR_MCU_STALL:begin 

            end 
            S2_CC1:begin 
                store_old_p = 1'b1;
            end 
            S2_CC2:begin 
                compare_and_store_n = 1'b1; 
            end
            S3_CC3:begin 
                compute_fin = 5'b00001;
            end 
            S3_CC4:begin 
                compute_fin = 5'b00010;
            end 
            S3_CC5:begin 
                compute_fin = 5'b00100;
            end
            S3_CC6:begin 
                compute_fin = 5'b01000;
            end 
            S3_CC7:begin 
                compute_fin = 5'b10000; 
            end 
            S4_CC1:begin 
                //read_on = 1'b1;
            end  
            default:begin
                ; 
            end 

        endcase 
    end
  
    always_comb begin
        /*
        wren_a = compute_fin[3] || compute_fin[2] || compute_fin[1] || compare_and_store_n || store_old_p && (png_idx != 0); 
        wren_b = 1'b0; 
        rden_a = 1'b0; 
        rden_b = store_old_p || (compute_fin != '0);*/
        
        
        pixel_traversal_rst = full_png_rst;
        png_counter_en = ~dither_rst && ~full_png_rst && ~full_png_idx && compute_fin[4];   
        
    end 

    // @NEW


    /*
    always_ff @ (posedge clk) begin : FAKE_FN_BLACKBOX
        unique case (state)
            RESET: begin
                write_on_1 <= 1'b0;
            end 
            WAIT_FOR_MCU: begin 
                if (write_on_0 == 1'b1) begin
                    write_on_1 <= 1'b0;
                end
            end 
            WAIT_FOR_MCU_STALL: begin
                write_on_1 <= 1'b1;
            end
            S4_CC1:begin 
            end  
			default:begin
				; 
			end 


        endcase
    end*/

    always_ff @ (posedge clk) begin
        if (write_on_0 == 1'b1) begin
            read_on <= 1'b0;
		end
        else if (read_on == 1'b0) begin
            if (state == S4_CC1) begin
                read_on <= 1'b1;
            end
            
        end
    end


// use pixel_traversal module in order to keep track of where we are in the image 
pixel_traversal pixel_traversal(

    .clk(clk), .rst(pixel_traversal_rst || rst), 
    .counter_en(png_counter_en), .counter(png_idx)

);




endmodule 