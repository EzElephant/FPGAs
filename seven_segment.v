module seven_segment (
    input clk_div,
    input [4:0] data0,
    input [4:0] data1,
    output reg [6:0] DISPLAY,
    output reg [3:0] DIGIT   
);

reg [4:0] show_n;
reg [1:0] show;

always @(posedge clk_div) begin
    show <= show + 1;
end

always @(*)
begin
    case (show)
        0: DIGIT = 4'b0111;
        1: DIGIT = 4'b1011;
        2: DIGIT = 4'b1101;
        3: DIGIT = 4'b1110;
    endcase
end

always @(*)
begin
    case (show)
        0: show_n = data0 / 10;
        1: show_n = data0 % 10;
        2: show_n = data1 / 10;
        3: show_n = data1 % 10;
    endcase
end

always @(*)
begin
    case (show_n)
        4'd0:  DISPLAY = 7'b100_0000;
        4'd1:  DISPLAY = 7'b111_1001;
        4'd2:  DISPLAY = 7'b010_0100;
        4'd3:  DISPLAY = 7'b011_0000;
        4'd4:  DISPLAY = 7'b001_1001;
        4'd5:  DISPLAY = 7'b001_0010;
        4'd6:  DISPLAY = 7'b000_0010;
        4'd7:  DISPLAY = 7'b111_1000;
        4'd8:  DISPLAY = 7'b000_0000;
        4'd9:  DISPLAY = 7'b001_0000;
        default: DISPLAY = 7'b0111111;
    endcase
end
    
endmodule