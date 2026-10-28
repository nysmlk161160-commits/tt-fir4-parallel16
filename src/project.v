`default_nettype none
module tt_um_fir4_parallel16 (
    input wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire ena,
    input wire clk,
    input wire rst_n
);
    reg [7:0] sample_lo;
    reg [7:0] coeff_lo;
    reg [1:0] coeff_addr;
    reg strobe_d;
    wire fire = ena && uio_in[7] && !strobe_d;
    wire sample_wr = fire && (uio_in[2:0] == 3'd1);
    wire coeff_wr = fire && (uio_in[2:0] == 3'd4);
    wire signed [15:0] sample_data = {ui_in, sample_lo};
    wire signed [15:0] coeff_data = {ui_in, coeff_lo};
    wire signed [15:0] data_out;
    wire out_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_lo <= 8'd0;
            coeff_lo <= 8'd0;
            coeff_addr <= 2'd0;
            strobe_d <= 1'b0;
        end else begin
            strobe_d <= uio_in[7];
            if (fire) begin
                case (uio_in[2:0])
                    3'd0: sample_lo <= ui_in;
                    3'd2: coeff_addr <= ui_in[1:0];
                    3'd3: coeff_lo <= ui_in;
                    default: begin end
                endcase
            end
        end
    end

    fir_4tap core (
        .clk(clk),
        .rst_n(rst_n),
        .sample_wr(sample_wr),
        .sample_data(sample_data),
        .coeff_wr(coeff_wr),
        .coeff_addr(coeff_addr),
        .coeff_data(coeff_data),
        .data_out(data_out),
        .out_valid(out_valid)
    );
    assign uo_out = uio_in[3] ? data_out[15:8] : data_out[7:0];
    assign uio_out = {7'b0,out_valid};
    assign uio_oe = 8'h01;
    wire unused = &{uio_in[6:4],ena,ui_in[7:2],1'b0};
endmodule
`default_nettype wire
