`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 16:27:33
// Design Name: 
// Module Name: test_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module calculator_top(
    input clk, reset_p,
    input [3:0] row,
    input [1:0] btn,
    output [3:0] col,
    output scl,sda,
    output [15:0] led
);
    
    wire [3:0] key_value;
    wire key_valid;
    wire [63:0] result_bcd;
    wire clk_div_10;
    
    clock_div_10 clk_div(
        .clk(clk), .reset_p(reset_p),
        .clk_div_10(clk_div_10)    
    );
    
    keypad_cntr_FSM cal_fsm(
        .clk(clk_div_10), .reset_p(reset_p),
        .row(row),
        .col(col),
        .key_value(key_value),
        .key_valid(key_valid)
    );
    
    op_code opcode(
        .clk(clk_div_10), .reset_p(reset_p),
        .key_value(key_value),
        .key_valid(key_valid),
        .result_bcd(result_bcd),
        .led(led)
    );
    
    i2c_cal_lcd_test_top cal_lcd(
        .clk(clk_div_10), .reset_p(reset_p),
        .btn(btn),
        .key_valid(key_valid),
        .key_value(key_value),
        .result_bcd(result_bcd),
        .scl(scl), .sda(sda)
    );
    
     
endmodule
