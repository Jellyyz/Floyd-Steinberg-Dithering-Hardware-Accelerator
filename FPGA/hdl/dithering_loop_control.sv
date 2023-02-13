module dithering_loop_control(
    input logic clk, rst, 

    output logic reset_dithering, 
    output logic store_old_p,
    output logic compare_and_store_n, 
    output logic calc_quant, 
    output logic compute_fin

); 
    // declaration of all states 
    enum logic [4:0]{
        RESET, 
        WAIT,
        STORE_OLD_P, 
        COMPARE_AND_STORE_NEW,
        CALC_QUANT_ERROR, 
        COMPUTE_FINAL

    } State, next_state; 

    always_ff @ (posedge clk or posedge rst)begin 
        if(rst)begin 
            state <= RESET
        end 
        else begin 
            state <= next_state; 
        end 

    end 

    always_comb : next_state_condition 
    begin 
        unique case(state)
            RESET: begin 
                next_state = WAIT;
            end 
            WAIT:begin 
                if(algorithm_trigger)begin 
                    next_state = STORE_OLD_P; 
                end 
                else begin 
                    next_state = WAIT; 
                end 
            end 
            STORE_OLD_P:begin 
                next_state = COMPARE_AND_STORE_NEW; 
            end 
            COMPARE_AND_STORE_NEW:begin 
                next_state = CALC_QUANT_ERROR; 
            end
            CALC_QUANT_ERROR:begin 
                next_state = COMPUTE_FINAL; 
            end 
            COMPUTE_FINAL:begin 
                next_state = WAIT; 
            end 

        endcase 
    
    end 

    always_comb : state_condition 
    begin

        unique case(state)
            RESET: begin 

            end 
            WAIT:begin 
                // wait for a signal from the user
            end 
            STORE_OLD_P:begin 
            
            end 
            COMPARE_AND_STORE_NEW:begin 
            
            end
            CALC_QUANT_ERROR:begin 
            
            end 
            COMPUTE_FINAL:begin 
                
            end 

        endcase 
    end 

endmodule 