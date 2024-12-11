`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 16:30:07
// Design Name: 
// Module Name: sequential_logic
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


module edge_detector_n(
    input clk, reset_p,
    input cp,
    output p_edge, n_edge
);
    reg ff_cur, ff_old; // 현재, 과거
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            ff_cur <= 0;
            ff_old <= 0;
        end
        else begin
            ff_old <= ff_cur; // always문에서 '<=' 연산자는 대입 연산자(논블로킹문)
            ff_cur <= cp; // 위에서 아래 순으로 실행되기 때문에 순서가 중요!
        end
    end
    
    assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1 : 0; // cur가 상위 비트, old가 하위비트
    assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1 : 0;

endmodule
