module sender (
    input clk,
    input rst,
    input source,
    output source_out
);

reg [2:0] counter, next_counter;
reg state, next_state;

always @(posedge clk) begin
    if (rst) begin
        state <= 0;
        counter <= 0;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        0: begin
            next_counter <= 0;
            if (source == 1)
                next_state = 1;
            else
                next_state = 0;
        end
        1: begin
            next_counter <= counter + 1;
            if (counter == 7)
                next_state = 0;
            else
                next_state = 1;
        end
    endcase
end

assign source_out = state;

endmodule