`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 16:32:19
// Design Name: 
// Module Name: combinational_logic
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


module bin_to_dec_result(  // binary to decimal
    input [53:0] bin,   // 54비트 이진수 입력
    output reg [63:0] bcd  // 16자리 10진수 표현
);

    reg [5:0] i;  // 루프를 54번 수행하기 위해 인덱스 크기 조정

    always @(bin) begin
        bcd = 0;
        for (i = 0; i < 54; i = i + 1) begin
            bcd = {bcd[62:0], bin[53-i]};  // 이진수의 각 비트를 BCD로 변환
            if (i < 53 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
            if (i < 53 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
            if (i < 53 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
            if (i < 53 && bcd[15:12] > 4) bcd[15:12] = bcd[15:12] + 3;
            if (i < 53 && bcd[19:16] > 4) bcd[19:16] = bcd[19:16] + 3;
            if (i < 53 && bcd[23:20] > 4) bcd[23:20] = bcd[23:20] + 3;
            if (i < 53 && bcd[27:24] > 4) bcd[27:24] = bcd[27:24] + 3;
            if (i < 53 && bcd[31:28] > 4) bcd[31:28] = bcd[31:28] + 3;
            if (i < 53 && bcd[35:32] > 4) bcd[35:32] = bcd[35:32] + 3;
            if (i < 53 && bcd[39:36] > 4) bcd[39:36] = bcd[39:36] + 3;
            if (i < 53 && bcd[43:40] > 4) bcd[43:40] = bcd[43:40] + 3;
            if (i < 53 && bcd[47:44] > 4) bcd[47:44] = bcd[47:44] + 3;
            if (i < 53 && bcd[51:48] > 4) bcd[51:48] = bcd[51:48] + 3;
            if (i < 53 && bcd[55:52] > 4) bcd[55:52] = bcd[55:52] + 3;
            if (i < 53 && bcd[59:56] > 4) bcd[59:56] = bcd[59:56] + 3;
            if (i < 53 && bcd[63:60] > 4) bcd[63:60] = bcd[63:60] + 3;
        end
    end
endmodule
