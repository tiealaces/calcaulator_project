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
    reg ff_cur, ff_old; // ����, ����
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            ff_cur <= 0;
            ff_old <= 0;
        end
        else begin
            ff_old <= ff_cur; // always������ '<=' �����ڴ� ���� ������(����ŷ��)
            ff_cur <= cp; // ������ �Ʒ� ������ ����Ǳ� ������ ������ �߿�!
        end
    end
    
    assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1 : 0; // cur�� ���� ��Ʈ, old�� ������Ʈ
    assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1 : 0;

endmodule
