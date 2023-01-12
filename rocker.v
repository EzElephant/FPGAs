module rocker1 (
    input wire clk,
	input wire clk_div,
    input wire rst,
    input wire MISO,
    output wire SS,
    output wire MOSI,
    output wire SCLK,
    output reg left,
    output reg right,
    output reg up,
    output reg down,
    output reg click,
    output reg down_click
);
parameter IDLE = 0;
parameter SMALL_WAIT = 1;
parameter SMALL_CONT = 2;
parameter BIG_WAIT = 3;
parameter BIG_CONT = 4;

// Signal to send/receive data to/from PmodJSTK
wire sndRec;
// Data read from PmodJSTK
wire [39:0] jstkData;

reg next_left, next_right, next_up, next_down;
reg [2:0] lr_state, next_lr_state, ud_state, next_ud_state;
reg [9:0] x, y, pre_x, pre_y;
reg [29:0] lr_counter, lr_next_counter, ud_counter, ud_next_counter;

ClkDiv_5Hz genSndRec(.CLK(clk), .RST(rst), .CLKOUT(sndRec));
PmodJSTK PmodJSTK_Int(
				.CLK(clk),
				.RST(rst),
				.sndRec(sndRec),
				.DIN(0), // for LED use
				.MISO(MISO),
				.SS(SS),
				.SCLK(SCLK),
				.MOSI(MOSI),
				.DOUT(jstkData)
                );

always @(*) begin
    click = jstkData[0];
    down_click = jstkData[1];
    x = {jstkData[9:8], jstkData[23:16]};
    y = {jstkData[25:24], jstkData[39:32]};
end


always @(posedge clk) begin
    pre_x <= x;
    pre_y <= y;
    if (rst) begin
        lr_state <= IDLE;
        ud_state <= IDLE;
        left <= 0;
        right <= 0;
        up <= 0;
        down <= 0;
        lr_counter <= 0;
        ud_counter <= 0;
    end
    else begin
        lr_state <= next_lr_state;
        ud_state <= next_ud_state;
        left <= next_left;
        right <= next_right;
        up <= next_up;
        down <= next_down;
        lr_counter <= lr_next_counter;
        ud_counter <= ud_next_counter;
    end
end

always @(*) begin
    next_lr_state = lr_state;
    next_left = 0;
    next_right = 0;
    lr_next_counter = 0;
    case (lr_state)
        IDLE: begin
            if (x > 750) begin
                next_lr_state = BIG_WAIT;
                next_right = 1;
            end
            else if (x < 300) begin
                next_lr_state = SMALL_WAIT;
                next_left = 1;
            end
        end
        BIG_WAIT: begin
            lr_next_counter = lr_counter + 1;
            if (x <= 750)
                next_lr_state = IDLE;
            else if (lr_counter == 50000000) begin
                next_lr_state = BIG_CONT;
                lr_next_counter = 0;
            end
        end
        BIG_CONT: begin
			lr_next_counter = lr_counter + 1;
            if (x <= 750)
                next_lr_state = IDLE;
            else if (lr_counter == 20000000) begin
                next_right = 1;
                lr_next_counter = 0;
            end
        end
        SMALL_WAIT: begin
            lr_next_counter = lr_counter + 1;
            if (x >= 300)
                next_lr_state = IDLE;
            else if (lr_counter == 50000000) begin
                next_lr_state = SMALL_CONT;
                lr_next_counter = 0;
            end
        end
        SMALL_CONT: begin
			lr_next_counter = lr_counter + 1;
            if (x >= 300)
                next_lr_state = IDLE;
            else if (lr_counter == 20000000) begin
                next_left = 1;
                lr_next_counter = 0;
            end
        end
    endcase
end

always @(*) begin
    next_ud_state = ud_state;
    next_up = 0;
    next_down = 0;
    ud_next_counter = 0;
    case (ud_state)
        IDLE: begin
            if (y > 750) begin
                next_ud_state = BIG_WAIT;
                next_down = 1;
            end
            else if (y < 300) begin
                next_ud_state = SMALL_WAIT;
                next_up = 1;
            end
        end
        BIG_WAIT: begin
            ud_next_counter = ud_counter + 1;
            if (y <= 750)
                next_ud_state = IDLE;
            else if (ud_counter == 50000000) begin
                next_ud_state = BIG_CONT;
                ud_next_counter = 0;
            end
        end
        BIG_CONT: begin
			ud_next_counter = ud_counter + 1;
            if (y <= 750)
                next_ud_state = IDLE;
            else if (ud_counter == 20000000) begin
                next_down = 1;
                ud_next_counter = 0;
            end
        end
        SMALL_WAIT: begin
            ud_next_counter = ud_counter + 1;
            if (y >= 300)
                next_ud_state = IDLE;
            else if (ud_counter == 50000000) begin
                next_ud_state = SMALL_CONT;
                ud_next_counter = 0;
            end
        end
        SMALL_CONT: begin
			ud_next_counter = ud_counter + 1;
            if (y >= 300)
                next_ud_state = IDLE;
            else if (ud_counter == 20000000) begin
                next_up = 1;
                ud_next_counter = 0;
            end
        end
    endcase
end

endmodule

module rocker2 (
    input wire clk,
	input wire clk_div,
    input wire rst,
    input wire MISO,
    output wire SS,
    output wire MOSI,
    output wire SCLK,
    output reg left,
    output reg right,
    output reg up,
    output reg down,
    output reg click,
    output reg down_click
);
parameter IDLE = 0;
parameter LITTLE_SMALL = 1;
parameter SMALL = 2;
parameter LITTLE_BIG = 3;
parameter BIG = 4;

// Signal to send/receive data to/from PmodJSTK
wire sndRec;
// Data read from PmodJSTK
wire [39:0] jstkData;

reg next_left, next_right, next_up, next_down;
reg [2:0] lr_state, next_lr_state, ud_state, next_ud_state;
reg [9:0] x, y, pre_x, pre_y;
reg [29:0] lr_counter, lr_next_counter, ud_counter, ud_next_counter;

ClkDiv_5Hz genSndRec(.CLK(clk), .RST(rst), .CLKOUT(sndRec));
PmodJSTK PmodJSTK_Int(
				.CLK(clk),
				.RST(rst),
				.sndRec(sndRec),
				.DIN(0), // for LED use
				.MISO(MISO),
				.SS(SS),
				.SCLK(SCLK),
				.MOSI(MOSI),
				.DOUT(jstkData)
                );

always @(*) begin
    click = jstkData[0];
    down_click = jstkData[1];
    x = {jstkData[9:8], jstkData[23:16]};
    y = {jstkData[25:24], jstkData[39:32]};
end


always @(posedge clk_div) begin
    pre_x <= x;
    pre_y <= y;
    if (rst) begin
        lr_state <= IDLE;
        ud_state <= IDLE;
        left <= 0;
        right <= 0;
        up <= 0;
        down <= 0;
        lr_counter <= 0;
        ud_counter <= 0;
    end
    else begin
        lr_state <= next_lr_state;
        ud_state <= next_ud_state;
        left <= next_left;
        right <= next_right;
        up <= next_up;
        down <= next_down;
        lr_counter <= lr_next_counter;
        ud_counter <= ud_next_counter;
    end
end

always @(*) begin
    next_lr_state = lr_state;
    next_left = 0;
    next_right = 0;
    lr_next_counter = 0;
    case (lr_state)
        IDLE: begin
            if (x > 825) begin
                next_lr_state = BIG;
                next_right = 1;
            end
			else if (x > 625) begin
				next_lr_state = LITTLE_BIG;
                next_right = 1;
			end
            else if (x < 225) begin
                next_lr_state = SMALL;
                next_left = 1;
            end
			else if (x < 425) begin
                next_lr_state = LITTLE_SMALL;
                next_left = 1;
            end
        end
		BIG: begin
			lr_next_counter = lr_counter + 1;
			if (x <= 825)
				next_lr_state = IDLE;
			else if (lr_counter == 500000) begin
                next_right = 1;
                lr_next_counter = 0;
            end
		end
        LITTLE_BIG: begin
			lr_next_counter = lr_counter + 1;
            if (x <= 625)
                next_lr_state = IDLE;
            else if (lr_counter == 1000000) begin
                next_right = 1;
                lr_next_counter = 0;
            end
        end
        LITTLE_SMALL: begin
			lr_next_counter = lr_counter + 1;
            if (x >= 425)
                next_lr_state = IDLE;
            else if (lr_counter == 1000000) begin
                next_left = 1;
                lr_next_counter = 0;
            end
        end
		SMALL: begin
			lr_next_counter = lr_counter + 1;
            if (x >= 225)
                next_lr_state = IDLE;
            else if (lr_counter == 500000) begin
                next_left = 1;
                lr_next_counter = 0;
            end
        end
    endcase
end

always @(*) begin
    next_ud_state = ud_state;
    next_up = 0;
    next_down = 0;
    ud_next_counter = 0;
    case (ud_state)
        IDLE: begin
            if (y > 825) begin
                next_ud_state = BIG;
                next_down = 1;
            end
			else if (y > 625) begin
				next_ud_state = LITTLE_BIG;
                next_down = 1;
			end
            else if (y < 225) begin
                next_ud_state = SMALL;
                next_up = 1;
            end
			else if (y < 425) begin
                next_ud_state = LITTLE_SMALL;
                next_up = 1;
            end
        end
		BIG: begin
			ud_next_counter = ud_counter + 1;
			if (y <= 825)
				next_ud_state = IDLE;
			else if (ud_counter == 500000) begin
                next_down = 1;
                ud_next_counter = 0;
            end
		end
        LITTLE_BIG: begin
			ud_next_counter = ud_counter + 1;
            if (y <= 625)
                next_ud_state = IDLE;
            else if (ud_counter == 1000000) begin
                next_down = 1;
                ud_next_counter = 0;
            end
        end
        LITTLE_SMALL: begin
			ud_next_counter = ud_counter + 1;
            if (y >= 425)
                next_ud_state = IDLE;
            else if (ud_counter == 1000000) begin
                next_up = 1;
                ud_next_counter = 0;
            end
        end
		SMALL: begin
			ud_next_counter = ud_counter + 1;
            if (y >= 225)
                next_ud_state = IDLE;
            else if (ud_counter == 500000) begin
                next_up = 1;
                ud_next_counter = 0;
            end
        end
    endcase
end

endmodule

// 下面的資料是由 Digilent Reference sample code裡面的module
module PmodJSTK(
			CLK,
			RST,
			sndRec,
			DIN,
			MISO,
			SS,
			SCLK,
			MOSI,
			DOUT
    );

// ===========================================================================
// 										Port Declarations
// ===========================================================================
			input CLK;						// 100MHz onboard clock
			input RST;						// Reset
			input sndRec;					// Send receive, initializes data read/write
			input [7:0] DIN;				// Data that is to be sent to the slave
			input MISO;						// Master in slave out
			output SS;						// Slave select, active low
			output SCLK;					// Serial clock
			output MOSI;					// Master out slave in
			output [39:0] DOUT;			// All data read from the slave

// ===========================================================================
// 							  Parameters, Regsiters, and Wires
// ===========================================================================

			// Output wires and registers
			wire SS;
			wire SCLK;
			wire MOSI;
			wire [39:0] DOUT;

			wire getByte;									// Initiates a data byte transfer in SPI_Int
			wire [7:0] sndData;							// Data to be sent to Slave
			wire [7:0] RxData;							// Output data from SPI_Int
			wire BUSY;										// Handshake from SPI_Int to SPI_Ctrl
			

			// 66.67kHz Clock Divider, period 15us
			wire iSCLK;										// Internal serial clock,
																// not directly output to slave,
																// controls state machine, etc.

// ===========================================================================
// 										Implementation
// ===========================================================================

			//-----------------------------------------------
			//  	  				SPI Controller
			//-----------------------------------------------
			spiCtrl SPI_Ctrl(
					.CLK(iSCLK),
					.RST(RST),
					.sndRec(sndRec),
					.BUSY(BUSY),
					.DIN(DIN),
					.RxData(RxData),
					.SS(SS),
					.getByte(getByte),
					.sndData(sndData),
					.DOUT(DOUT)
			);

			//-----------------------------------------------
			//  	  				  SPI Mode 0
			//-----------------------------------------------
			spiMode0 SPI_Int(
					.CLK(iSCLK),
					.RST(RST),
					.sndRec(getByte),
					.DIN(sndData),
					.MISO(MISO),
					.MOSI(MOSI),
					.SCLK(SCLK),
					.BUSY(BUSY),
					.DOUT(RxData)
			);

			//-----------------------------------------------
			//  	  				SPI Controller
			//-----------------------------------------------
			ClkDiv_66_67kHz SerialClock(
					.CLK(CLK),
					.RST(RST),
					.CLKOUT(iSCLK)
			);

endmodule

// Description: This component manages all data transfer requests,
//					 and manages the data bytes being sent to the PmodJSTK.
module spiCtrl(
			CLK,
			RST,
			sndRec,
			BUSY,
			DIN,
			RxData,
			SS,
			getByte,
			sndData,
			DOUT
    );

	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================

			input CLK;						// 66.67kHz onboard clock
			input RST;						// Reset
			input sndRec;					// Send receive, initializes data read/write
			input BUSY;						// If active data transfer currently in progress
			input [7:0] DIN;				// Data that is to be sent to the slave
			input [7:0] RxData;			// Last data byte received
			output SS;						// Slave select, active low
			output getByte;				// Initiates a data transfer in SPI_Int
			output [7:0] sndData;		// Data that is to be sent to the slave
			output [39:0] DOUT;			// All data read from the slave

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================

			// Output wires and registers
			reg SS = 1'b1;
			reg getByte = 1'b0;
			reg [7:0] sndData = 8'h00;
			reg [39:0] DOUT = 40'h0000000000;

			// FSM States
			parameter [2:0] Idle = 3'd0,
								 Init = 3'd1,
								 Wait = 3'd2,
								 Check = 3'd3,
								 Done = 3'd4;
			
			// Present State
			reg [2:0] pState = Idle;

			reg [2:0] byteCnt = 3'd0;					// Number bits read/written
			parameter byteEndVal = 3'd5;				// Number of bytes to send/receive
			reg [39:0] tmpSR = 40'h0000000000;		// Temporary shift register to
																// accumulate all five data bytes

	// ===========================================================================
	// 										Implementation
	// ===========================================================================

	always @(negedge CLK) begin
			if(RST == 1'b1) begin
					// Reest everything
					SS <= 1'b1;
					getByte <= 1'b0;
					sndData <= 8'h00;
					tmpSR <= 40'h0000000000;
					DOUT <= 40'h0000000000;
					byteCnt <= 3'd0;
					pState <= Idle;
			end
			else begin
					
					case(pState)

								// Idle
								Idle : begin

										SS <= 1'b1;								// Disable slave
										getByte <= 1'b0;						// Do not request data
										sndData <= 8'h00;						// Clear data to be sent
										tmpSR <= 40'h0000000000;			// Clear temporary data
										DOUT <= DOUT;							// Retain output data
										byteCnt <= 3'd0;						// Clear byte count

										// When send receive signal received begin data transmission
										if(sndRec == 1'b1) begin
											pState <= Init;
										end
										else begin
											pState <= Idle;
										end
										
								end

								// Init
								Init : begin
								
										SS <= 1'b0;								// Enable slave
										getByte <= 1'b1;						// Initialize data transfer
										sndData <= DIN;						// Store input data to be sent
										tmpSR <= tmpSR;						// Retain temporary data
										DOUT <= DOUT;							// Retain output data
										
										if(BUSY == 1'b1) begin
												pState <= Wait;
												byteCnt <= byteCnt + 1'b1;	// Count
										end
										else begin
												pState <= Init;
										end
										
								end

								// Wait
								Wait : begin

										SS <= 1'b0;								// Enable slave
										getByte <= 1'b0;						// Data request already in progress
										sndData <= sndData;					// Retain input data to send
										tmpSR <= tmpSR;						// Retain temporary data
										DOUT <= DOUT;							// Retain output data
										byteCnt <= byteCnt;					// Count
										
										// Finished reading byte so grab data
										if(BUSY == 1'b0) begin
												pState <= Check;
										end
										// Data transmission is not finished
										else begin
												pState <= Wait;
										end

								end

								// Check
								Check : begin

										SS <= 1'b0;								// Enable slave
										getByte <= 1'b0;						// Do not request data
										sndData <= sndData;					// Retain input data to send
										tmpSR <= {tmpSR[31:0], RxData};	// Store byte just read
										DOUT <= DOUT;							// Retain output data
										byteCnt <= byteCnt;					// Do not count

										// Finished reading bytes so done
										if(byteCnt == 3'd5) begin
												pState <= Done;
										end
										// Have not sent/received enough bytes
										else begin
												pState <= Init;
										end
								end

								// Done
								Done : begin

										SS <= 1'b1;							// Disable slave
										getByte <= 1'b0;					// Do not request data
										sndData <= 8'h00;					// Clear input
										tmpSR <= tmpSR;					// Retain temporary data
										DOUT[39:0] <= tmpSR[39:0];		// Update output data
										byteCnt <= byteCnt;				// Do not count
										
										// Wait for external sndRec signal to be de-asserted
										if(sndRec == 1'b0) begin
												pState <= Idle;
										end
										else begin
												pState <= Done;
										end

								end

								// Default State
								default : pState <= Idle;
						endcase
			end
	end

endmodule

// 簡單來說 下面這個module會幫忙跟搖桿溝通
// Description: This module provides the interface for sending and receiving data
//					 to and from the PmodJSTK, SPI mode 0 is used for communication.  The
//					 master (Nexys3) reads the data on the MISO input on rising edges, the
//					 slave (PmodJSTK) reads the data on the MOSI output on rising edges.
//					 Output data to the slave is changed on falling edges, and input data
//					 from the slave changes on falling edges.
//
//					 To initialize a data transfer between the master and the slave simply
//					 assert the sndRec input.  While the data transfer is in progress the
//					 BUSY output is asserted to indicate to other componenets that a data
//					 transfer is in progress.  Data to send to the slave is input on the 
//					 DIN input, and data read from the slave is output on the DOUT output.
//
//					 Once a sndRec signal has been received a byte of data will be sent
//					 to the PmodJSTK, and a byte will be read from the PmodJSTK.  The
//					 data that is sent comes from the DIN input. Received data is output
//					 on the DOUT output.
module spiMode0(
    CLK,
    RST,
    sndRec,
    DIN,
    MISO,
    MOSI,
    SCLK,
	 BUSY,
    DOUT
    );


	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================

			input CLK;						// 66.67kHz serial clock
			input RST;						// Reset
			input sndRec;					// Send receive, initializes data read/write
			input [7:0] DIN;				// Byte that is to be sent to the slave
			input MISO;						// Master input slave output
			output MOSI;					// Master out slave in
			output SCLK;					// Serial clock
			output BUSY;					// Busy if sending/receiving data
			output [7:0] DOUT;			// Current data byte read from the slave

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
			wire MOSI;
			wire SCLK;
			wire [7:0] DOUT;
			reg BUSY;

			// FSM States
			parameter [1:0] Idle = 2'd0,
								 Init = 2'd1,
								 RxTx = 2'd2,
								 Done = 2'd3;

			reg [4:0] bitCount;							// Number bits read/written
			reg [7:0] rSR = 8'h00;						// Read shift register
			reg [7:0] wSR = 8'h00;						// Write shift register
			reg [1:0] pState = Idle;					// Present state

			reg CE = 0;										// Clock enable, controls serial
																// clock signal sent to slave
	
	 
	// ===========================================================================
	// 										Implementation
	// ===========================================================================

			// Serial clock output, allow if clock enable asserted
			assign SCLK = (CE == 1'b1) ? CLK : 1'b0;
			// Master out slave in, value always stored in MSB of write shift register
			assign MOSI = wSR[7];
			// Connect data output bus to read shift register
			assign DOUT = rSR;
	
			//-------------------------------------
			//			 Write Shift Register
			// 	slave reads on rising edges,
			// change output data on falling edges
			//-------------------------------------
			always @(negedge CLK) begin
					if(RST == 1'b1) begin
							wSR <= 8'h00;
					end
					else begin
							// Enable shift during RxTx state only
							case(pState)
									Idle : begin
											wSR <= DIN;
									end
									
									Init : begin
											wSR <= wSR;
									end
									
									RxTx : begin
											if(CE == 1'b1) begin
													wSR <= {wSR[6:0], 1'b0};
											end
									end
									
									Done : begin
											wSR <= wSR;
									end
							endcase
					end
			end




			//-------------------------------------
			//			 Read Shift Register
			// 	master reads on rising edges,
			// slave changes data on falling edges
			//-------------------------------------
			always @(posedge CLK) begin
					if(RST == 1'b1) begin
							rSR <= 8'h00;
					end
					else begin
							// Enable shift during RxTx state only
							case(pState)
									Idle : begin
											rSR <= rSR;
									end
									
									Init : begin
											rSR <= rSR;
									end
									
									RxTx : begin
											if(CE == 1'b1) begin
													rSR <= {rSR[6:0], MISO};
											end
									end
									
									Done : begin
											rSR <= rSR;
									end
							endcase
					end
			end



			
			//------------------------------
			//		   SPI Mode 0 FSM
			//------------------------------
			always @(negedge CLK) begin
			
					// Reset button pressed
					if(RST == 1'b1) begin
							CE <= 1'b0;				// Disable serial clock
							BUSY <= 1'b0;			// Not busy in Idle state
							bitCount <= 4'h0;		// Clear #bits read/written
							pState <= Idle;		// Go back to Idle state
					end
					else begin
							
							case (pState)
							
								// Idle
								Idle : begin

										CE <= 1'b0;				// Disable serial clock
										BUSY <= 1'b0;			// Not busy in Idle state
										bitCount <= 4'd0;		// Clear #bits read/written
										

										// When send receive signal received begin data transmission
										if(sndRec == 1'b1) begin
											pState <= Init;
										end
										else begin
											pState <= Idle;
										end
										
								end

								// Init
								Init : begin
								
										BUSY <= 1'b1;			// Output a busy signal
										bitCount <= 4'h0;		// Have not read/written anything yet
										CE <= 1'b0;				// Disable serial clock
										
										pState <= RxTx;		// Next state receive transmit
										
								end

								// RxTx
								RxTx : begin

										BUSY <= 1'b1;						// Output busy signal
										bitCount <= bitCount + 1'b1;	// Begin counting bits received/written
										
										// Have written all bits to slave so prevent another falling edge
										if(bitCount >= 4'd8) begin
												CE <= 1'b0;
										end
										// Have not written all data, normal operation
										else begin
												CE <= 1'b1;
										end
										
										// Read last bit so data transmission is finished
										if(bitCount == 4'd8) begin
												pState <= Done;
										end
										// Data transmission is not finished
										else begin
												pState <= RxTx;
										end

								end

								// Done
								Done : begin

										CE <= 1'b0;			// Disable serial clock
										BUSY <= 1'b1;		// Still busy
										bitCount <= 4'd0;	// Clear #bits read/written
										
										pState <= Idle;

								end

								// Default State
								default : pState <= Idle;
								
							endcase
					end
			end

endmodule

// 66.67kHz clock divider
module ClkDiv_66_67kHz(
    CLK,											// 100MHz onbaord clock
    RST,											// Reset
    CLKOUT										// New clock output
    );

// ===========================================================================
// 										Port Declarations
// ===========================================================================
	input CLK;
	input RST;
	output CLKOUT;

// ===========================================================================
// 							  Parameters, Regsiters, and Wires
// ===========================================================================
	// Output register
	reg CLKOUT = 1'b1;

	// Value to toggle output clock at
	parameter cntEndVal = 10'b1011101110;
	// Current count
	reg [9:0] clkCount = 10'b0000000000;

// ===========================================================================
// 										Implementation
// ===========================================================================

	//----------------------------------------------
	//						Serial Clock
	//			66.67kHz Clock Divider, period 15us
	//----------------------------------------------
	always @(posedge CLK) begin

			// Reset clock
			if(RST == 1'b1) begin
					CLKOUT <= 1'b0;
					clkCount <= 10'b0000000000;
			end
			// Count/toggle normally
			else begin

					if(clkCount == cntEndVal) begin
							CLKOUT <= ~CLKOUT;
							clkCount <= 10'b0000000000;
					end
					else begin
							clkCount <= clkCount + 1'b1;
					end

			end

	end

endmodule

// 5Hz clock divider
module ClkDiv_5Hz(
    CLK,											// 100MHz onbaord clock
    RST,											// Reset
    CLKOUT										// New clock output
    );

// ===========================================================================
// 										Port Declarations
// ===========================================================================
	input CLK;
	input RST;
	output CLKOUT;

// ===========================================================================
// 							  Parameters, Regsiters, and Wires
// ===========================================================================
	
	// Output register
	reg CLKOUT;
	
	// Value to toggle output clock at
	parameter cntEndVal = 24'h989680;
	// Current count
	reg [23:0] clkCount = 24'h000000;
	

// ===========================================================================
// 										Implementation
// ===========================================================================

	//-------------------------------------------------
	//	5Hz Clock Divider Generates Send/Receive signal
	//-------------------------------------------------
	always @(posedge CLK) begin

			// Reset clock
			if(RST == 1'b1) begin
					CLKOUT <= 1'b0;
					clkCount <= 24'h000000;
			end
			else begin

					if(clkCount == cntEndVal) begin
							CLKOUT <= ~CLKOUT;
							clkCount <= 24'h000000;
					end
					else begin
							clkCount <= clkCount + 1'b1;
					end

			end

	end

endmodule