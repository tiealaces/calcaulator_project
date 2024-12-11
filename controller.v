`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 16:30:53
// Design Name: 
// Module Name: controller
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


module keypad_cntr_FSM(
    input clk, reset_p,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value,
    output reg key_valid
);
    parameter SCAN_0 = 5'b00001;
    parameter SCAN_1 = 5'b00010;
    parameter SCAN_2 = 5'b00100;
    parameter SCAN_3 = 5'b01000;
    parameter KEY_PROCESS = 5'b10000;
    
    reg [4:0] state, next_state;
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            next_state = SCAN_0;
        end
        else begin                
            case(state)
                SCAN_0 : begin
                    if(row == 0) next_state = SCAN_1;
                    else next_state = KEY_PROCESS;
                end
                SCAN_1 : begin
                    if(row == 0) next_state = SCAN_2;
                    else next_state = KEY_PROCESS;
                end
                SCAN_2 : begin
                    if(row == 0) next_state = SCAN_3;
                    else next_state = KEY_PROCESS;
                end
                SCAN_3 : begin
                    if(row == 0) next_state = SCAN_0;
                    else next_state = KEY_PROCESS;
                end
                KEY_PROCESS : begin
                    if(row == 0) next_state = SCAN_0;
                    else next_state = KEY_PROCESS;
                end
                default: begin
                end
            endcase
        end
    end
    
    wire clk_8msec_n, clk_8msec_p; // 8msec frequency divider
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)state = SCAN_0;
        else if(clk_8msec_p)state = next_state;
    end
    
    reg [14:0] clk_div;
    
    always @(posedge clk)clk_div = clk_div + 1;
        
    edge_detector_n ed(
        .clk(clk), .reset_p(reset_p), .cp(clk_div[14]), 
        .p_edge(clk_8msec_p), .n_edge(clk_8msec_n)
    );
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            col = 4'b0001;
            key_value = 0;
            key_valid = 0;
        end
        else if(clk_8msec_n)begin
            case(state)
                SCAN_0 : begin col = 4'b0001; key_valid = 0; end
                SCAN_1 : begin col = 4'b0010; key_valid = 0; end
                SCAN_2 : begin col = 4'b0100; key_valid = 0; end
                SCAN_3 : begin col = 4'b1000; key_valid = 0; end
                KEY_PROCESS : begin
                    key_valid = 1;
                    case({row,col})
                        
                        8'b0001_0001 : key_value = 4'h0;    // 7
                        8'b0001_0010 : key_value = 4'h1;    // 8
                        8'b0001_0100 : key_value = 4'h2;    // 9
                        8'b0001_1000 : key_value = 4'h3;    // A
                        8'b0010_0001 : key_value = 4'h4;    // 4
                        8'b0010_0010 : key_value = 4'h5;    // 5
                        8'b0010_0100 : key_value = 4'h6;    // 6
                        8'b0010_1000 : key_value = 4'h7;    // b
                        8'b0100_0001 : key_value = 4'h8;    // 1
                        8'b0100_0010 : key_value = 4'h9;    // 2
                        8'b0100_0100 : key_value = 4'ha;    // 3
                        8'b0100_1000 : key_value = 4'hb;    // E
                        8'b1000_0001 : key_value = 4'hc;    // C
                        8'b1000_0010 : key_value = 4'hd;    // 0
                        8'b1000_0100 : key_value = 4'he;    // F
                        8'b1000_1000 : key_value = 4'hf;    // d
                    endcase
                end
            endcase
        end
    end


endmodule


module op_code(
    input clk, reset_p,
    input [3:0] key_value,
    input key_valid,
    output [63:0] result_bcd,
    output [15:0] led
);

    reg [31:0] first_number;
    reg [31:0] second_number;
    reg [3:0] operator;  // 연산자 저장 (예: +, -, *, /)
    reg input_stage;     // 입력 단계 플래그
    
    reg [53:0] result;
    assign led = result;
    bin_to_dec_result result_b2d(  // binary to decimal
        .bin(result[53:0]),   // 54비트 이진수 입력
        .bcd(result_bcd)  // 16자리 10진수 표현
    );
    wire key_valid_pedge;
              
    edge_detector_n ed(
        .clk(clk), .reset_p(reset_p), .cp(key_valid),
        .p_edge(key_valid_pedge)
    );
    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            first_number <= 53'd0;
            second_number <= 53'd0;
            operator <= 4'd0;
            result <= 53'd0;
            input_stage <= 1'b0;  // 첫 번째 숫자 입력 단계
        end 
        else if (key_valid_pedge) begin
            if (!input_stage) begin
                // 첫 번째 숫자 입력
                case (key_value)
                    4'h0: first_number <= (first_number * 10) + 1; 
                    4'h1: first_number <= (first_number * 10) + 2; 
                    4'h2: first_number <= (first_number * 10) + 3; 
                    4'h4: first_number <= (first_number * 10) + 4; 
                    4'h5: first_number <= (first_number * 10) + 5; 
                    4'h6: first_number <= (first_number * 10) + 6; 
                    4'h8: first_number <= (first_number * 10) + 7; 
                    4'h9: first_number <= (first_number * 10) + 8; 
                    4'ha: first_number <= (first_number * 10) + 9; 
                    4'hd: first_number <= (first_number * 10) + 0;
                    4'h3, 4'h7, 4'hb, 4'hf: begin // 연산자 입력
                        operator <= key_value;
                        input_stage <= 1'b1; // 두 번째 숫자 입력 단계로 전환
                    end
                    default: first_number = 0;
                endcase
            end
            else begin
                // 두 번째 숫자 입력
                case (key_value)
                    4'h0: second_number <= (second_number * 10) + 1;
                    4'h1: second_number <= (second_number * 10) + 2;
                    4'h2: second_number <= (second_number * 10) + 3;
                    4'h4: second_number <= (second_number * 10) + 4;
                    4'h5: second_number <= (second_number * 10) + 5;
                    4'h6: second_number <= (second_number * 10) + 6;
                    4'h8: second_number <= (second_number * 10) + 7;
                    4'h9: second_number <= (second_number * 10) + 8;
                    4'ha: second_number <= (second_number * 10) + 9;
                    4'hd: second_number <= (second_number * 10) + 0;
                    4'he: begin // '=' 버튼 입력 시 결과 계산
                        case (operator)
                            4'h3: result <= first_number + second_number; // + 덧셈
                            4'h7: result <= first_number - second_number; // - 뺄셈
                            4'hb: result <= first_number * second_number; // * 곱셈
                            4'hf: result <= first_number / second_number; // / 나눗셈
                            default: result <= 53'd0;
                        endcase
                        // 초기화하여 다음 연산 준비
                        first_number <= 16'd0;
                        second_number <= 16'd0;
                        operator <= 4'd0;
                        input_stage <= 0;
                    end
                    default: second_number = 0;
                endcase
            end
        end
    end

endmodule


module i2c_cal_lcd_test_top(
    input clk, reset_p,
    input [3:0] key_value,
    input [1:0] btn,
    input key_valid,
    input [63:0] result_bcd,
    output scl, sda
);

    parameter IDLE = 8'b0000_0001;
    parameter INIT = 8'b0000_0010;
    parameter SEND_BYTE = 8'b0000_0100;
    parameter SHIFT_RIGHT_DISPLAY = 8'b0000_1000;
    parameter SHIFT_LEFT_DISPLAY = 8'b0001_0000;
    parameter CLEAR_DISPLAY = 8'b0010_0000; // LCD 초기화 상태 추가
    parameter NEXT_LINE = 8'b0100_0000; // LCD 초기화 상태 추가
    parameter SEND_STRING = 8'b1000_0000;
    wire [1:0] btn_pedge;
    
    button_cntr btn_0(
        .clk(clk), .reset_p(reset_p), .btn(btn[0]),
        .btn_pedge(btn_pedge[0])
    );
    button_cntr btn_1(
        .clk(clk), .reset_p(reset_p), .btn(btn[1]),
        .btn_pedge(btn_pedge[1])
    );
    
    wire clk_usec;
    clock_div_100 usec_clk(                              
        .clk(clk), .reset_p(reset_p),      
        .clk_div_100(clk_usec)
    );
    
    wire key_valid_pedge;
              
    edge_detector_n ed(
        .clk(clk), .reset_p(reset_p), .cp(key_valid),
        .p_edge(key_valid_pedge)
    );
    
    reg [12:0] count_usec;
    reg count_usec_e;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)begin
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e)count_usec = count_usec + 1;
            else if(!count_usec_e)count_usec = 0;
        end
    end
    
    reg [7:0] send_buffer;
    reg send, rs;
    wire busy;  // 출력 신호
    i2c_lcd_send_byte send_byte(
        .clk(clk), .reset_p(reset_p),
        .addr(7'h27),
        .send_buffer(send_buffer),
        .send(send), .rs(rs),
        .scl(scl), .sda(sda),
        .busy(busy));

    wire [127:0] result_ascii;
    dec_to_ascii d2a(
        .result_bcd(result_bcd),
        .result_ascii(result_ascii)
    );

    reg [7:0] state, next_state;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    
    wire [7:0] buffer [0:15];
    assign buffer[15]  = result_ascii[7:0];
    assign buffer[14]  = result_ascii[15:8];       
    assign buffer[13]  = result_ascii[23:16];      
    assign buffer[12]  = result_ascii[31:24];      
    assign buffer[11]  = result_ascii[39:32];      
    assign buffer[10]  = result_ascii[47:40];      
    assign buffer[9]  = result_ascii[55:48];      
    assign buffer[8]  = result_ascii[63:56];      
    assign buffer[7]  = result_ascii[71:64];      
    assign buffer[6]  = result_ascii[79:72];      
    assign buffer[5] = result_ascii[87:80];      
    assign buffer[4] = result_ascii[95:88];      
    assign buffer[3] = result_ascii[103:96];     
    assign buffer[2] = result_ascii[111:104];    
    assign buffer[1] = result_ascii[119:112];    
    assign buffer[0] = result_ascii[127:120];
    
    reg [4:0] result_length;  // result_ascii length

    always @(posedge clk, posedge reset_p) begin
        if(reset_p)begin
            result_length = 5'd1;
        end
        else begin
            result_length = 5'd1;
            if(buffer[0] != 8'h30)
                result_length = 5'd16;
            else if (buffer[1] != 8'h30)
                result_length = 5'd15;
            else if (buffer[2] != 8'h30)
                result_length = 5'd14;
            else if (buffer[3] != 8'h30)
                result_length = 5'd13;
            else if (buffer[4] != 8'h30)
                result_length = 5'd12;
            else if (buffer[5] != 8'h30)
                result_length = 5'd11;
            else if (buffer[6] != 8'h30)
                result_length = 5'd10;
            else if (buffer[7] != 8'h30)
                result_length = 5'd9;
            else if (buffer[8] != 8'h30)
                result_length = 5'd8;
            else if (buffer[9] != 8'h30)
                result_length = 5'd7;
            else if (buffer[10] != 8'h30)
                result_length = 5'd6;
            else if (buffer[11] != 8'h30)
                result_length = 5'd5;
            else if (buffer[12] != 8'h30)
                result_length = 5'd4;
            else if (buffer[13] != 8'h30)
                result_length = 5'd3;
            else if (buffer[14] != 8'h30)
                result_length = 5'd2;
            else
                result_length = result_length;  // 만약 모든 값이 '0'이라면 길이는 0으로 설정
        end
    end

    
    // 초기화 코드
    reg init_flag;
    reg [4:0] cnt_data;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            init_flag = 0;
            next_state = IDLE;
            send = 0;
            send_buffer = 0;
            cnt_data = 0;
            rs = 0;
        end
        else begin
            case(state)
                IDLE :begin
                    if(init_flag)begin
                        if(key_valid_pedge && !(key_value == 4'hc)&& !(key_value == 4'he))begin
                            next_state = SEND_BYTE;
                        end
                        if(btn_pedge[0]) next_state = SHIFT_RIGHT_DISPLAY;
                        if(btn_pedge[1]) next_state = SHIFT_LEFT_DISPLAY;
                        if(key_valid_pedge && key_value == 4'he) next_state = NEXT_LINE;
                    end
                    else begin
                        if(count_usec <= 13'd8000)begin
                            count_usec_e = 1;
                        end
                        else begin
                            init_flag = 1;
                            next_state = INIT;
                            count_usec_e = 0;
                        end
                    end
                end
                INIT :begin
                    if(busy)begin
                        send = 0;
                        if(cnt_data >= 6)begin
                            cnt_data = 0;
                            next_state = IDLE;
                            init_flag = 1;
                        end
                    end
                    else if(send == 0)begin
                        case(cnt_data)
                            0 : send_buffer = 8'h33;
                            1 : send_buffer = 8'h32;
                            2 : send_buffer = 8'h28;
                            3 : send_buffer = 8'h0c;    // 08 = 디스플레이 OFF
                            4 : send_buffer = 8'h01;
                            5 : send_buffer = 8'h06;
                        endcase
                        send = 1;
                        cnt_data = cnt_data + 1;
                    end
                end
                SEND_BYTE :begin
                    if(busy)begin
                        next_state = IDLE;
                        send = 0;
                    end
                    else begin
                        case(key_value)
                            4'h0: send_buffer = "1";
                            4'h1: send_buffer = "2";
                            4'h2: send_buffer = "3";
                            4'h3: send_buffer = "+";
                            4'h4: send_buffer = "4";
                            4'h5: send_buffer = "5";
                            4'h6: send_buffer = "6";
                            4'h7: send_buffer = "-";
                            4'h8: send_buffer = "7";
                            4'h9: send_buffer = "8";
                            4'ha: send_buffer = "9";
                            4'hb: send_buffer = "*";
                            4'hd: send_buffer = "0";
                            4'hf: send_buffer = "/";
                            default: send_buffer = 8'h00;
                        endcase
                        rs = 1;
                        send = 1;
                    end
                end
                SHIFT_RIGHT_DISPLAY :begin
                    if(busy)begin
                        next_state = IDLE;
                        send = 0;
                    end
                    else begin
                        rs = 0;
                        send_buffer = 8'h1c;
                        send = 1;
                    end            
                end
                SHIFT_LEFT_DISPLAY :begin
                    if(busy)begin
                        next_state = IDLE;
                        send = 0;
                    end
                    else begin
                        rs = 0;
                        send_buffer = 8'h18;
                        send = 1;
                    end
                end
                CLEAR_DISPLAY: begin
                    if(busy)begin
                        next_state = IDLE;
                        send = 0;
                    end
                    else begin
                        rs = 0;
                        send_buffer = 8'h01; // 디스플레이 초기화 명령
                        send = 1;
                    end
                end
                NEXT_LINE: begin
                    if(busy)begin
                        next_state = SEND_STRING;
                        send = 0;
                    end
                    else begin
                        rs = 0;
                        send_buffer = 8'hc0; // next line
                        send = 1;
                    end
                end
                SEND_STRING: begin
                    if(busy)begin
                        send = 0;
                        if(cnt_data == result_length) next_state = IDLE;       
                    end
                    else if(!send) begin
                        rs = 1;                       
                        send = 1;
                        send_buffer = buffer[16 - result_length + cnt_data]; // 디스플레이 초기화 명령
                        cnt_data = cnt_data +1;
                    end
                end
            endcase
        end
    end


endmodule


module button_cntr(
    input clk, reset_p,
    input btn,
    output btn_pedge, btn_nedge);
    
    reg [13:0] clk_div; // 65536
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_16_pedge;
    edge_detector_n ed_div(
        .clk(clk), .reset_p(reset_p), 
        .cp(clk_div[13]), .p_edge(clk_div_16_pedge)
    );
        
    reg debounced_btn;
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) debounced_btn = 0;
        else if(clk_div_16_pedge)debounced_btn = btn;
    end
    
    edge_detector_n ed(
        .clk(clk), .reset_p(reset_p), .cp(debounced_btn), 
        .p_edge(btn_pedge), .n_edge(btn_nedge)
    );
endmodule


module i2c_lcd_send_byte(
    input clk, reset_p,
    input [6:0] addr,
    input [7:0] send_buffer,
    input send, rs,
    output scl, sda,
    output reg busy);

    parameter IDLE = 6'b00_0001;
    parameter SEND_HIGH_NIBBLE_DISABLE = 6'b00_0010;
    parameter SEND_HIGH_NIBBLE_ENABLE = 6'b00_0100;
    parameter SEND_LOW_NIBBLE_DISABLE = 6'b00_1000;
    parameter SEND_LOW_NIBBLE_ENABLE = 6'b01_0000;
    parameter SEND_DISABLE = 6'b10_0000;
    
        
    wire send_pedge;
    edge_detector_n ed_go(
        .clk(clk), .reset_p(reset_p), .cp(send),
        .p_edge(send_pedge)
    );
    
        
    reg [10:0] count_usec;
    reg count_usec_e;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)begin
            count_usec = 0;
        end
        else begin
            if(clk && count_usec_e)count_usec = count_usec + 1;
            else if(!count_usec_e)count_usec = 0;
        end
    end
    
    reg [5:0] state, next_state;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    
    reg [7:0] data;
    reg comm_go;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            next_state = IDLE;
            busy = 0;
        end
        else begin
            case(state)
                IDLE :begin
                    if(send_pedge)begin
                        next_state = SEND_HIGH_NIBBLE_DISABLE;
                        busy = 1;
                    end
                end
                SEND_HIGH_NIBBLE_DISABLE :begin
                    if(count_usec <= 22'd500)begin
                        data = {send_buffer[7:4], 3'b100, rs};  // [d7 d6 d5 d4] [BT EN RW] RS
                        comm_go = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_HIGH_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        comm_go = 0;
                    end
                end
                SEND_HIGH_NIBBLE_ENABLE :begin
                    if(count_usec <= 22'd500)begin
                        data = {send_buffer[7:4], 3'b110, rs};  // [d7 d6 d5 d4] [BT EN RW] RS
                        comm_go = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_DISABLE;
                        count_usec_e = 0;
                        comm_go = 0;
                    end
                end
                SEND_LOW_NIBBLE_DISABLE :begin
                    if(count_usec <= 22'd500)begin
                        data = {send_buffer[3:0], 3'b100, rs};  // [d7 d6 d5 d4] [BT EN RW] RS
                        comm_go = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        comm_go = 0;
                    end
                end
                SEND_LOW_NIBBLE_ENABLE :begin
                    if(count_usec <= 22'd500)begin
                        data = {send_buffer[3:0], 3'b110, rs};  // [d7 d6 d5 d4] [BT EN RW] RS
                        comm_go = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_DISABLE;
                        count_usec_e = 0;
                        comm_go = 0;
                    end
                end
                SEND_DISABLE :begin
                    if(count_usec <= 22'd500)begin
                        data = {send_buffer[3:0], 3'b100, rs};  // [d7 d6 d5 d4] [BT EN RW] RS
                        comm_go = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = IDLE;
                        count_usec_e = 0;
                        comm_go = 0;
                        busy = 0;
                    end
                end
            endcase
        end
    end
    
    
    I2C_master master(
        .clk(clk), .reset_p(reset_p),
        .addr(addr),   // 7'h27 = binary 0010 0111
        .data(data),
        .rd_wr(0), .comm_go(comm_go),
        .sda(sda), .scl(scl), .led(led));
        
    

endmodule


module I2C_master(
    input clk, reset_p,
    input [6:0] addr,
    input [7:0] data,
    input rd_wr, comm_go,   // rd_wr = 1 or 0, comm_go == comm_start
    output reg sda, scl,
    output reg [6:0] led);
    
    parameter IDLE = 7'b000_0001;
    parameter COMM_START = 7'b000_0010;
    parameter SEND_ADDR = 7'b000_0100;
    parameter RD_ACK = 7'b000_1000;
    parameter SEND_DATA = 7'b001_0000;
    parameter SCL_STOP = 7'b010_0000;
    parameter COMM_STOP = 7'b100_0000;
    
    wire [7:0] addr_rw;
    assign addr_rw = {addr, rd_wr};

    
    reg [5:0] count_usec5;
    reg scl_e;
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            count_usec5 = 0;
            scl = 1;
        end
        else if(scl_e)begin
            if(clk)begin
                if(count_usec5 >= 4)begin
                    count_usec5 = 0;
                    scl = ~scl;
                end
                else count_usec5 = count_usec5 +1;
            end
        end
        else if(!scl_e)begin
            count_usec5 = 0;
            scl = 1;
        end
    end
    
    wire comm_go_pedge;
    edge_detector_n ed_go(
        .clk(clk), .reset_p(reset_p), .cp(comm_go),
        .p_edge(comm_go_pedge)
    );
    
    wire scl_pedge, scl_nedge;
    edge_detector_n ed_scl(
        .clk(clk), .reset_p(reset_p), .cp(scl),
        .p_edge(scl_pedge), .n_edge(scl_nedge)
    );
    
    reg [6:0] state, next_state;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    
    reg [2:0] cnt_bit;
    reg stop_flag;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            next_state = IDLE;
            scl_e = 0;
            sda = 1;
            cnt_bit = 7;
            stop_flag = 0;
            led = 0;
        end
        else begin
            case(state)
                IDLE :begin
                    led[0] = 1;
                    scl_e = 0;
                    sda = 1;
                    if(comm_go_pedge)next_state = COMM_START;
                end
                COMM_START :begin
                    led[1] = 1;
                    sda = 0;
                    scl_e = 1;
                    next_state = SEND_ADDR;
                end
                SEND_ADDR :begin
                    led[2] = 1;
                    if(scl_nedge)sda = addr_rw[cnt_bit];
                    if(scl_pedge)begin
                        if(cnt_bit == 0)begin
                            cnt_bit = 7;
                            next_state = RD_ACK;
                        end
                        else cnt_bit = cnt_bit - 1;
                    end
                end
                RD_ACK :begin
                led[3] = 1;
                    if(scl_nedge)sda = 'bz;
                    else if(scl_pedge)begin
                        if(stop_flag)begin
                            stop_flag = 0;
                            next_state = SCL_STOP;
                        end
                        else begin
                            stop_flag = 1;
                            next_state = SEND_DATA;
                        end
                    end
                end
                SEND_DATA :begin
                    led[4] = 1;
                    if(scl_nedge)sda = data[cnt_bit];
                    if(scl_pedge)begin
                        if(cnt_bit == 0)begin
                            cnt_bit = 7;
                            next_state = RD_ACK;
                        end
                        else cnt_bit = cnt_bit - 1;
                    end
                end
                SCL_STOP :begin
                    led[5] = 1;
                    if(scl_nedge)sda = 0;
                    else if(scl_pedge) next_state = COMM_STOP;
                end
                COMM_STOP :begin
                    led[6] = 1;
                    if(count_usec5 >= 1)begin   // because anxiety
                        scl_e = 0;
                        sda = 1;
                        next_state = IDLE;
                    end
                end
            endcase
        end
    end
    
endmodule


module dec_to_ascii(
    input [63:0] result_bcd,
    output [127:0] result_ascii
);
    
    assign result_ascii[7:0] = result_bcd[3:0] + "0";
    assign result_ascii[15:8] = result_bcd[7:4] + "0";
    assign result_ascii[23:16] = result_bcd[11:8] + "0";
    assign result_ascii[31:24] = result_bcd[15:12] + "0";
    assign result_ascii[39:32] = result_bcd[19:16] + "0";
    assign result_ascii[47:40] = result_bcd[23:20] + "0";
    assign result_ascii[55:48] = result_bcd[27:24] + "0";
    assign result_ascii[63:56] = result_bcd[31:28] + "0";
    assign result_ascii[71:64] = result_bcd[35:32] + "0";
    assign result_ascii[79:72] = result_bcd[39:36] + "0";
    assign result_ascii[87:80] = result_bcd[43:40] + "0";
    assign result_ascii[95:88] = result_bcd[47:44] + "0";
    assign result_ascii[103:96] = result_bcd[51:48] + "0";
    assign result_ascii[111:104] = result_bcd[55:52] + "0";
    assign result_ascii[119:112] = result_bcd[59:56] + "0";
    assign result_ascii[127:120] = result_bcd[63:60] + "0";

    
    
endmodule