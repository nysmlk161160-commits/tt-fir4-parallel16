`default_nettype none
module fir_4tap (
    input wire clk,
    input wire rst_n,
    input wire sample_wr,
    input wire signed [15:0] sample_data,
    input wire coeff_wr,
    input wire [1:0] coeff_addr,
    input wire signed [15:0] coeff_data,
    output reg signed [15:0] data_out,
    output reg out_valid
);
    reg signed [15:0] delay [0:2];
    reg signed [15:0] coeff [0:3];
    wire signed [31:0] p0 = sample_data * coeff[0];
    wire signed [31:0] p1 = delay[0] * coeff[1];
    wire signed [31:0] p2 = delay[1] * coeff[2];
    wire signed [31:0] p3 = delay[2] * coeff[3];
    wire signed [33:0] sum = {{2{p0[31]}},p0} + {{2{p1[31]}},p1}
                            + {{2{p2[31]}},p2} + {{2{p3[31]}},p3};
    wire signed [33:0] scaled = sum >>> 15;
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i=0; i<3; i=i+1) delay[i] <= 16'sd0;
            for (i=0; i<4; i=i+1) coeff[i] <= 16'sd0;
            data_out <= 16'sd0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= sample_wr;
            if (coeff_wr) coeff[coeff_addr] <= coeff_data;
            if (sample_wr) begin
                delay[2] <= delay[1];
                delay[1] <= delay[0];
                delay[0] <= sample_data;
                data_out <= scaled[15:0];
            end
        end
    end
endmodule
`default_nettype wire
