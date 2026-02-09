module tree_arbiter #(parameter N = 8) (
    input  wire clk,
    input  wire rst_n,
    input  wire [N-1:0] req,
    output wire [N-1:0] gnt
);
    // For N=8, we need 7 internal nodes. 
    // We will use a flat array and index them carefully.
    // Index 0 is the Root.
    // Children of node i are (2*i + 1) and (2*i + 2).
    
    wire [N-2:0] node_req;
    wire [N-2:0] node_gnt;

    // The Root (Index 0) always gets a grant if it asks
    assign node_gnt[0] = node_req[0];

    genvar i;
    generate
        for (i = 0; i < N-1; i = i + 1) begin : gen_nodes
            
            // Logic for Internal Nodes vs Leaf Nodes
            wire l_req, r_req, l_gnt, r_gnt;

            if (i >= (N/2) - 1) begin : leaf_connection
                // These nodes connect directly to the input 'req' and output 'gnt'
                // Mapping: Node 3->req[0,1], Node 4->req[2,3], Node 5->req[4,5], Node 6->req[6,7]
                assign l_req = req[2*(i-(N/2-1))];
                assign r_req = req[2*(i-(N/2-1))+1];
                assign gnt[2*(i-(N/2-1))]   = l_gnt;
                assign gnt[2*(i-(N/2-1))+1] = r_gnt;
            end else begin : internal_connection
                // These nodes connect to other arb_cells below them
                assign l_req = node_req[2*i + 1];
                assign r_req = node_req[2*i + 2];
                assign node_gnt[2*i + 1] = l_gnt;
                assign node_gnt[2*i + 2] = r_gnt;
            end

            arb_cell cell_inst (
                .clk(clk),
                .rst_n(rst_n),
                .req_l(l_req),
                .req_r(r_req),
                .gnt_l(l_gnt),
                .gnt_r(r_gnt),
                .req_up(node_req[i]),
                .gnt_dn(node_gnt[i])
            );
        end
    endgenerate
endmodule
