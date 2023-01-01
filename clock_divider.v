module clock_divider(clk, clk_div);
    parameter n = 27;     
    input clk;   
    output [n - 1:0] clk_div;   
    
    reg [n-1:0] num;
    wire [n-1:0] next_num;
    
    always@(posedge clk)begin
    	num <= next_num;
    end
    
    assign next_num = num +1;
    // assign clk_div = num[n-1];

    assign clk_div = num;
endmodule