module dithering_loop_control(
    input logic clk, rst, 
    input logic algorithm_trigger, 

    output logic reset_dithering, 
    output logic store_old_p,
    output logic compare_and_store_n, 
    output logic compute_fin

); 
    // declaration of all states 
    enum logic [4:0]{
        RESET, 
        WAIT,
        STORE_OLD_P, 
        COMPARE_AND_STORE_NEW,
        COMPUTE_FINAL

    } state, next_state; 

    always_ff @ (posedge clk or posedge rst)begin 
        if(rst)begin 
            state <= RESET;
        end 
        else begin 
            state <= next_state; 
        end 

    end 

    always_comb 
    begin : next_state_condition 
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
                next_state = COMPUTE_FINAL; 
            end
            COMPUTE_FINAL:begin 
                next_state = WAIT; 
            end 

        endcase 
    
    end 

    always_comb 
    begin : state_condition 
        reset_dithering = 1'b0; 
        store_old_p = 1'b0; 
        compare_and_store_n = 1'b0; 
        compute_fin = 1'b0; 
        unique case(state)
            RESET: begin 
                reset_dithering = 1'b1; 
            end 
            WAIT:begin 
                // wait for a signal from the user
            end 
            STORE_OLD_P:begin 
                store_old_p = 1'b1; 
            end 
            COMPARE_AND_STORE_NEW:begin 
                compare_and_store_n = 1'b1; 
            end
            COMPUTE_FINAL:begin 
                compute_fin = 1'b1; 
            end 

        endcase 
    end 

endmodule 