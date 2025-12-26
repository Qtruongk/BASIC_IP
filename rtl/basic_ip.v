`define INT_A 8'h00
`define INT_B 8'h00
`define INT_C 8'h00
`define INT_D 8'h00
`define INT_E 8'h00
`define INT_F 8'h00
`define INT_G 8'h00
`define INT_H 8'h00

`define HIGH    1'b1
`define LOW     1'b0

`define WAIT_CYCLES       6'd2
`define COUNT_RESET_VALUE 6'd0

module basic_ip_core (
    // Tín hiệu bus APB
    input  wire        pclk,
    input  wire        preset_n,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [7:0]  paddr,
    input  wire [7:0]  pwdata,

    // Tín hiệu output bus APB
    output reg         pready,
    output reg         pslverr,
    output reg  [7:0]  prdata,

    // Các thanh ghi nội bộ được đưa ra làm output để testbench theo dõi
    output reg [7:0]   A, B, C, D, E, F, G, H
);

    //================================================================
    // KHAI BÁO CÁC BIẾN TRUNG GIAN
    //================================================================
    reg [7:0] psel_reg;
    reg [5:0] count;

    //================================================================
    // 1. LOGIC GIẢI MÃ ĐỊA CHỈ
    //================================================================
    always @(*) begin
        case (paddr)
            8'h00: psel_reg = 8'b0000_0001;
            8'h01: psel_reg = 8'b0000_0010;
            8'h02: psel_reg = 8'b0000_0100;
            8'h03: psel_reg = 8'b0000_1000;
            8'h04: psel_reg = 8'b0001_0000;
            8'h05: psel_reg = 8'b0010_0000;
            8'h06: psel_reg = 8'b0100_0000;
            8'h07: psel_reg = 8'b1000_0000;
            default: psel_reg = 8'b0000_0000;
        endcase
    end

    //================================================================
    // 2. LOGIC GHI (WRITE PATH)
    //================================================================
    wire write_en = psel && penable && pwrite;
    always @(posedge pclk or negedge preset_n) begin
        if (!preset_n) begin
            A <= `INT_A; B <= `INT_B; C <= `INT_C; D <= `INT_D;
            E <= `INT_E; F <= `INT_F; G <= `INT_G; H <= `INT_H;
        end else if (write_en) begin
            if (psel_reg[0]) A <= pwdata;
            if (psel_reg[1]) B <= pwdata;
            if (psel_reg[2]) C <= pwdata;
            if (psel_reg[3]) D <= pwdata;
            if (psel_reg[4]) E <= pwdata;
            if (psel_reg[5]) F <= pwdata;
            if (psel_reg[6]) G <= pwdata;
            if (psel_reg[7]) H <= pwdata;
        end
    end
    
    //================================================================
    // 3. LOGIC ĐỌC (READ PATH)
    //================================================================
    always @(*) begin
        case (paddr)
            8'h00:   prdata = A;
            8'h01:   prdata = B;
            8'h02:   prdata = C;
            8'h03:   prdata = D;
            8'h04:   prdata = E;
            8'h05:   prdata = F;
            8'h06:   prdata = G;
            8'h07:   prdata = H;
            default: prdata = 8'h00;
        endcase
    end

    //================================================================
    // 4. LOGIC ĐIỀU KHIỂN BUS (PSLVERR và PREADY)
    //================================================================
    always@(posedge pclk or negedge preset_n) begin
        if(!preset_n) begin
            pslverr <= `LOW;
        end else if(psel && penable && (psel_reg == 8'b0)) begin
            pslverr <= `HIGH;
        end else begin
            pslverr <= `LOW;
        end
    end

    always@(posedge pclk or negedge preset_n) begin
        if(!preset_n) begin
            pready <= `LOW;
            count  <= `COUNT_RESET_VALUE;
        end else begin
            if (psel && penable) begin
                if (count == `WAIT_CYCLES) begin
                    pready <= `HIGH;
                end else begin
                    count  <= count + 1;
                    pready <= `LOW;
                end
            end else begin
                pready <= `LOW;
                count  <= `COUNT_RESET_VALUE;
            end
        end
    end

endmodule