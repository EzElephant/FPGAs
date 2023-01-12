module special_one_pulse (
    input wire clk,
    input wire pb_in,
    output reg pb_out
);

reg[9:0] pb_in_delay;

always @(posedge clk) begin
	if (pb_in == 1 && pb_in_delay == 0) begin
		pb_out <= 1;
	end 
	else begin
		pb_out <= 0;
	end
end

always @(posedge clk) begin
	pb_in_delay <= {pb_in_delay[8:0] ,pb_in};
end

endmodule
