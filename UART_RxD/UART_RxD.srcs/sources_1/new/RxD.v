`timescale 1ns / 1ps

module RxD (
    input  wire       clk,  // baud rate
    input  wire       en,
    input  wire       in,   // rx
    output reg  [7:0] out,  // received data
    output reg        done, // end on transaction
    output reg        busy, // transaction is in process
    output reg        err   // error while receiving data
);
    // states of state machine
    reg [1:0] RESET = 2'b00;
    reg [1:0] IDLE = 2'b01;
    reg [1:0] DATA_BITS = 2'b10;
    reg [1:0] STOP_BIT = 2'b11;

    reg [1:0] state;
    reg [2:0] bitIdx = 3'b0; // for 8-bit data
    reg [1:0] inputSw = 2'b11; // shift reg for input signal state
    reg [3:0] clockCount = 4'b0; // count clocks for 16x oversample
    reg [7:0] receivedData = 8'b0; // temporary storage for input data
    
    initial begin
    state <= 3'b0;
    end
    
    always @(posedge clk) begin
    
    inputSw <= {inputSw[0], in}; // Bit shift occurs every clock shift
    
    if(!en) state <= RESET;
    case(state)
    RESET : begin
    out <= 8'b0;
    done <= 1'b0;
    busy <= 1'b0;
    err <= 1'b0;
    bitIdx <= 3'b0;
    clockCount <= 4'b0;
    receivedData <= 8'b0;
    if(en & in) state <= IDLE;
    end
    
    IDLE : begin
    // Searching for the Start Bit
    if(clockCount == 8'b11111111) begin 
    out <= 8'b0;
    done <= 8'b0;
    busy <= 1'b1;
    err <= 1'b0;
    receivedData <= 8'b0;
    end
    else if( clockCount <= 8'b11111111 && !(inputSw[0] & inputSw[1]) ) begin
    if(inputSw[0] & inputSw[1]) begin
    state <= RESET;
    err <= 1'b1;
    end
    clockCount = clockCount + 1'b1;
    end
    end
    
    STOPBIT : begin
    if(clockCount == 8'b11111111) begin
    out <= recievedData;
    state <= IDLE;
    done <= 1'b1;
    err <= 1'b0;
    clockCount <= 4'b0;
    recievedData <= 0;
    end
    else if(clockCount < 8'b11111111 ) begin 
    if(!(inputSw[0]||inputSw[1])) begin
    err <= 1'b0;
    state <= RESET;
    end
    clockCount = clockCount + 1;
    end
    end
    endcase
    end
    
    
    
    
    
    

    initial begin
        out <= 8'b0;
        err <= 1'b0;
        done <= 1'b0;
        busy <= 1'b0;
    end

    always @(posedge clk) begin
        inputSw = { inputSw[0], in };

        if (!en) begin
            state = RESET;
        end

        case (state)
            RESET: begin
                out <= 8'b0;
                err <= 1'b0;
                done <= 1'b0;
                busy <= 1'b0;
                bitIdx <= 3'b0;
                clockCount <= 4'b0;
                receivedData <= 8'b0;
                if (en) begin
                    state <= IDLE;
                end
            end

            IDLE: begin // Assuming the start bit is always low;
                done <= 1'b0;
                if (&clockCount) begin
                    state <= DATA_BITS;
                    out <= 8'b0;
                    bitIdx <= 3'b0;
                    clockCount <= 4'b0;
                    receivedData <= 8'b0;
                    busy <= 1'b1;
                    err <= 1'b0;
                end else if (!(&inputSw) || |clockCount) begin // The clockCount increments only when the start bit is detected. If not the system still remains in the Idle state
                    // Check bit to make sure it's still low
                    if (&inputSw) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                    clockCount <= clockCount + 4'b1;
                end
            end

            // Wait 8 full cycles to receive serial data
            DATA_BITS: begin
                if (&clockCount) begin // save one bit of received data
                                clockCount <= 4'b0;
                                receivedData[bitIdx] <= inputSw[0];
                                if (&bitIdx) begin
                                    bitIdx <= 3'b0;
                                    state <= STOP_BIT;
                                end else begin
                                    bitIdx <= bitIdx + 3'b1;
                                end
                            end else begin
                                clockCount <= clockCount + 4'b1;
                            end
            end

            /*
            * Baud clock may not be running at exactly the same rate as the
            * transmitter. Next start bit is allowed on at least half of stop bit.
            */
            STOP_BIT: begin
                if (&clockCount || clockCount >=4'd8) begin 
                    state <= IDLE;
                    done <= 1'b1;
                    busy <= 1'b0;
                    out <= receivedData;
                    clockCount <= 4'b0;
                end else begin // As the state itself start at the rising edge of the Stop Bit
                    clockCount <= clockCount + 1;
                    // Check bit to make sure it's still high
                    if (!(|inputSw)) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                end
            end

            default: state <= IDLE;
        endcase
    end

endmodule
