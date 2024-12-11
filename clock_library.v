`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 16:28:43
// Design Name: 
// Module Name: clock_library
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


module clock_div_10(
    input clk, reset_p,
    input clk_source,
    output clk_div_10    
);
    
    edge_detector_n ed(
        .clk(clk), .reset_p(reset_p), .cp(clk_source),
        .n_edge(nedge_source)
    );
    
    reg [3:0] cnt_sysclk;
   
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) cnt_sysclk = 0;
        else if(nedge_source)begin 
            if(cnt_sysclk >= 9) cnt_sysclk = 0;
            else cnt_sysclk = cnt_sysclk + 1;
        end
    end
    
    assign cp_div_10 = (cnt_sysclk < 5) ? 0 : 1;
    edge_detector_n ed10(
        .clk(clk), .reset_p(reset_p), .cp(cp_div_10),
        .n_edge(clk_div_10)
    );
    
    
endmodule


module clock_div_100(
    input clk, reset_p,
    output clk_div_100,
    output cp_div_100
    );
    reg [6:0] cnt_sysclk;
   
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) cnt_sysclk = 1;
        else begin 
            if(cnt_sysclk >= 99) cnt_sysclk = 0;
            else cnt_sysclk = cnt_sysclk + 1;
        end
    end
    
    assign cp_div_100 = (cnt_sysclk < 50) ? 0 : 1;
    
    edge_detector_n ed(
        .clk(clk), .reset_p(reset_p), .cp(cp_div_100),
        .n_edge(clk_div_100)
    );
    
endmodule
