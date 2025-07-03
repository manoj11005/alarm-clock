module Alarm_clock(
    input reset,                // Reset signal
    input clk,                  // System clock
    input [1:0] H_in1,          // Hour input (tens place)
    input [3:0] H_in0,          // Hour input (units place)
    input [3:0] M_in1,          // Minute input (tens place)
    input [3:0] M_in0,          // Minute input (units place)
    input LD_time,              // Load time signal
    input LD_alarm,             // Load alarm signal
    input STOP_al,              // Stop alarm signal
    input AL_ON,                // Alarm on signal
    output reg Alarm,           // Alarm output
    output [1:0] H_out1,        // Hour output (tens place)
    output [3:0] H_out0,        // Hour output (units place)
    output [3:0] M_out1,        // Minute output (tens place)
    output [3:0] M_out0,        // Minute output (units place)
    output [3:0] S_out1,        // Second output (tens place)
    output [3:0] S_out0         // Second output (units place)
);

    // Registers for internal state
    reg clk_1s;                 // 1-second clock signal
    reg [3:0] tmp_1s;           // Temporary counter for 1-second clock signal
    reg [5:0] tmp_hour, tmp_minute, tmp_second;  // Temporary registers for current time
    reg [1:0] c_hour1, a_hour1; // Current and alarm hour (tens place)
    reg [3:0] c_hour0, a_hour0; // Current and alarm hour (units place)
    reg [3:0] c_min1, a_min1;   // Current and alarm minute (tens place)
    reg [3:0] c_min0, a_min0;   // Current and alarm minute (units place)
    reg [3:0] c_sec1, a_sec1;   // Current and alarm second (tens place)
    reg [3:0] c_sec0, a_sec0;   // Current and alarm second (units place)

    // Function to calculate the tens place of a number
    function [3:0] mod_10;
        input [5:0] number;
        begin
            mod_10 = (number >= 50) ? 5 : 
                     ((number >= 40) ? 4 : 
                     ((number >= 30) ? 3 : 
                     ((number >= 20) ? 2 : 
                     ((number >= 10) ? 1 : 0))));
        end
    endfunction

    // Always block to handle reset and load signals
    always @(posedge clk_1s or posedge reset)
    begin
        if (reset) begin
            // Reset alarm and current time
            a_hour1 <= 2'b00;
            a_hour0 <= 4'b0000;
            a_min1 <= 4'b0000;
            a_min0 <= 4'b0000;
            a_sec1 <= 4'b0000;
            a_sec0 <= 4'b0000;
            tmp_hour <= H_in1 * 10 + H_in0;
            tmp_minute <= M_in1 * 10 + M_in0;
            tmp_second <= 0;
        end 
        else begin
            if (LD_alarm) begin
                // Load alarm time
                a_hour1 <= H_in1;
                a_hour0 <= H_in0;
                a_min1 <= M_in1;
                a_min0 <= M_in0;
                a_sec1 <= 4'b0000;
                a_sec0 <= 4'b0000;
            end 
            if (LD_time) begin 
                // Load current time
                tmp_hour <= H_in1 * 10 + H_in0;
                tmp_minute <= M_in1 * 10 + M_in0;
                tmp_second <= 0;
            end 
            else begin  
                // Increment seconds
                tmp_second <= tmp_second + 1;
                if (tmp_second >= 59) begin
                    tmp_minute <= tmp_minute + 1;
                    tmp_second <= 0;
                    if (tmp_minute >= 59) begin
                        tmp_minute <= 0;
                        tmp_hour <= tmp_hour + 1;
                        if (tmp_hour >= 23) begin
                            tmp_hour <= 0;
                        end
                    end 
                end
            end 
        end 
    end 

    // Always block to generate 1-second clock signal from system clock
    always @(posedge clk or posedge reset)
    begin
        if (reset) begin
            tmp_1s <= 0;
            clk_1s <= 0;
        end
        else begin
            tmp_1s <= tmp_1s + 1;
            if (tmp_1s <= 5) 
                clk_1s <= 0;
            else if (tmp_1s >= 10) begin
                clk_1s <= 1;
                tmp_1s <= 0;
            end
            else
                clk_1s <= 1;
        end
    end

    // Always block to calculate the current time's tens and units place
    always @(*)
    begin
        if (tmp_hour >= 20) begin
            c_hour1 = 2;
        end
        else begin
            if (tmp_hour >= 10) 
                c_hour1 = 1;
            else
                c_hour1 = 0;
        end
        c_hour0 = tmp_hour - c_hour1 * 10; 
        c_min1 = mod_10(tmp_minute); 
        c_min0 = tmp_minute - c_min1 * 10;
        c_sec1 = mod_10(tmp_second);
        c_sec0 = tmp_second - c_sec1 * 10; 
    end

    // Always block to handle the alarm functionality
    always @(posedge clk_1s or posedge reset)
    begin
        if (reset) 
            Alarm <= 0; 
        else begin
            if ({a_hour1, a_hour0, a_min1, a_min0} == {c_hour1, c_hour0, c_min1, c_min0}) begin
                if (AL_ON) 
                    Alarm <= 1; 
            end
            if (STOP_al) 
                Alarm <= 0;
        end
    end

    // Assign current time to output ports
    assign H_out1 = c_hour1; 
    assign H_out0 = c_hour0; 
    assign M_out1 = c_min1; 
    assign M_out0 = c_min0; 
    assign S_out1 = c_sec1;
    assign S_out0 = c_sec0;

endmodule
