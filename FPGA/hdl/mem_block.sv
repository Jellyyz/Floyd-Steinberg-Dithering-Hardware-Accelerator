module basic_ram
# (
    parameter CLOCK_SPEED = 50000000,
    parameter PIXEL_COUNTER = 50000000 / CLOCK_SPEED,
    parameter IMAGEY = 64,
    parameter IMAGEX = 64,
    parameter IMAGE_SIZE = IMAGEY * IMAGEX,
    parameter RGB_SIZE = 8

)




(
    input logic clk,
    input logic wr_en,
    input logic [(RGB_SIZE - 1):0] data_in,
    output logic [(RGB_SIZE - 1):0] data_out,
    input logic [$clog2(IMAGE_SIZE):0] address
);
    reg [(RGB_SIZE - 1):0] mem [(IMAGE_SIZE- 1):0] /* synthesis ramstyle = M9K */;
    // To initialize the RAM, Quartus supports initialization
    // which normal RAMs and synthesis do not support.
    initial begin
        for(int i = 0; i <= (IMAGE_SIZE- 1); i++) begin 
            mem[i] = 8'h0;
        end 
    end
    always @(posedge clk) begin
        if (wr_en == 1'b1) begin
            mem[address] <= data_in; // write
        end
        data_out <= mem[address]; // read
    end
endmodule