`timescale 1ns / 1ps

module arb_cell (
    input  wire clk,
    input  wire rst_n,
    // Interface to Children
    input  wire req_l,
    input  wire req_r,
    output wire gnt_l,
    output wire gnt_r,
    // Interface to Parent
    output wire req_up,
    input  wire gnt_dn
);
    reg p_bit; // 0: Left has priority, 1: Right has priority

    // Upward Request: If either child wants it, tell the parent
    assign req_up = req_l | req_r;

    // Downward Grant: Decide based on request availability AND priority bit
    // If Left requests and (Right isn't requesting OR Left has priority)
    assign gnt_l = gnt_dn & (req_l && (!req_r  p_bit == 1'b0));
    assign gnt_r = gnt_dn & (req_r && (!req_l  p_bit == 1'b1));

    // Priority Update: Only flip if a grant actually passed through this node
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_bit <= 1'b0;
        end else if (gnt_l) begin
            p_bit <= 1'b1; // Next time, give Right a chance
        end else if (gnt_r) begin
            p_bit <= 1'b0; // Next time, give Left a chance
        end
    end
endmodule
