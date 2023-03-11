// Digital hexdriver:
/* ...displays a dash on bottom if In0 = LOW
 * ...displays a dash on top if 	  In0 = HIGH
 */
module HexDriverOverload (
    input	[3:0] In0,
	output logic	[6:0] Out0);
		
    always_comb
    begin
        unique case(In0)
            4'b0000	:	Out0 = 7'b1110111; // LOW
            4'b0001	:	Out0 = 7'b1111110; // HIGH
            default	:	Out0 = 7'bX;
        endcase
    end
endmodule