`timescale 1ns/1ps

module tb_tree_arbiter;
    parameter N = 8;
    reg clk;
    reg rst_n;
    reg [N-1:0] req;
    wire [N-1:0] gnt;

    // Instantiate the Arbiter
    tree_arbiter #(.N(N)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .gnt(gnt)
    );

    // Clock Generation
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        // --- Initialization ---
        req = 0;
        rst_n = 0;
        #45 rst_n = 1; // Release reset
        
        $display("Starting Test Scenarios...");

        // --- Scenario 1: All Persistent Requesters ---
        // Expect: Grants should rotate 0 -> 1 -> 2 ... -> 7 -> 0
        $display("Scenario 1: All Requesters Active");
        req = 8'b11111111; 
        repeat (16) @(posedge clk);
        
        // --- Scenario 2: Sparse Contention ---
        // Expect: Only R0 and R7 should alternate. Nodes 1-6 ignored.
        $display("Scenario 2: Sparse Contention (R0 and R7)");
        req = 8'b10000001; 
        repeat (8) @(posedge clk);

        // --- Scenario 3: Transient vs Persistent ---
        // R0 is persistent. R4 blips for only 1 cycle.
        $display("Scenario 3: Transient R4 during Persistent R0");
        req = 8'b00000001; // R0 is already holding
        repeat (2) @(posedge clk);
        
        req = 8'b00010001; // R4 hits suddenly
        @(posedge clk);    // R4 should win here or next cycle
        req = 8'b00000001; // R4 drops immediately
        
        repeat (5) @(posedge clk);

        $display("Testing Complete.");
        $finish;
    end

    // Monitor Output
    initial begin
        $monitor("Time: %0t | Req: %b | Gnt: %b", $time, req, gnt);
    end

endmodule
