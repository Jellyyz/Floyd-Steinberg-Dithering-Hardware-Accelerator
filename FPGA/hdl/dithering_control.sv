module dithering_control(
    input logic clk, rst, 

    output logic []

); 
    // declaration of all states 
    enum logic [4:0]{
        RESET, 

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
        next_state = state; 
        unique case(state)


        endcase 
    
    end 

    always_comb : state_condition 
    begin 
        unique case(state)


        endcase 
    end 

endmodule 