`define HIGH        1'b1
`define LOW         1'b0
`define RESET_VALUE 8'h00
`timescale 1ns / 1ns

module cpu_model (
    // input
    input        pclk,
    input        preset_n,
    input        pslverr,
    input        pready,
    input [7:0]  prdata,
    // output
    output reg   psel,
    output reg   pwrite,
    output reg   penable,
    output reg [7:0] paddr,
    output reg [7:0] pwdata
);

//=======================================================
// KHỞI TẠO TÍN HIỆU BAN ĐẦU
//=======================================================
initial begin
    // Khởi tạo các tín hiệu ở trạng thái idle
    $display("[%0t] INFO: Initializing cpu_model outputs to idle state.", $time);
    psel    = 1'b0;
    pwrite  = 1'b0;
    penable = 1'b0;
    paddr   = 8'h00;
    pwdata  = 8'h00;
end

/*************************|
|1.     Writing data       |
|*************************/
task MOVT;
    input [7:0] address;
    input [7:0] data;
    begin
        $display("[%0t] Write task started", $time);
        // --- SETUP ---
        paddr   = address;
        pwdata  = data;
        psel    = `HIGH;
        pwrite  = `HIGH;
        penable = `LOW;
        @(posedge pclk);
        $display("[%0t]: [WRITE] Setup Phase   -> Addr=0x%h, WData=0x%h, PSEL=1, PWRITE=1, PENABLE=0", $time, address, data);
        
        // --- ACCESS Phase + Wait States
        penable = `HIGH;
        @(posedge pclk);
        $display("[%0t]: [WRITE] Access Phase Start -> PENABLE=1", $time);
        
        // --- Chờ PREADY ---
        $display("[%0t]: [WRITE] Waiting for PREADY...", $time);
        while(!pready) begin
            @(posedge pclk);
            $display("[%0t]: [WRITE] Still waiting... (PREADY=%b)", $time, pready);
        end
        // Pready = 1 tại sườn clock này
        
        $display("[%0t]: [WRITE] PREADY detected!", $time);
        
        if(pslverr) begin
            $display("[%0t], (CPU), incorrect address", $time);
        end
        
        @(posedge pclk);
        
        // --- END --- 
        $display("[%0t]: [WRITE] End Phase     -> PSEL=0, PWRITE=0, PENABLE=0", $time);
        psel    = `LOW;
        pwrite  = `LOW;
        penable = `LOW;
        paddr   = `RESET_VALUE;
        pwdata  = `RESET_VALUE;
    end
endtask

/*************************|
|2.     Reading data       |
|*************************/
task MOVF;
    input  [7:0] address;
    output [7:0] rdata;
    begin
        $display("[%0t] Read task started", $time);
        // --- SETUP ---
        paddr   = address;
        pwdata  = 8'hXX; // Không dùng trong giao dịch đọc
        psel    = `HIGH;
        pwrite  = `LOW;  // pwrite = 0 cho giao dịch ĐỌC
        penable = `LOW;
        @(posedge pclk);
        $display("[%0t]: [READ] Setup Phase -> Addr=0x%h, PSEL=1, PWRITE=0, PENABLE=0", $time, address);

        // --- ACCESS Phase + Wait States
        penable = `HIGH;
        @(posedge pclk);
        $display("[%0t]: [READ] Access Phase Start-> PENABLE=1", $time);

        // --- Chờ PREADY ---
        $display("[%0t]: [READ]  Waiting for PREADY...", $time);
        while(!pready) begin
            @(posedge pclk);
            $display("[%0t]: [READ] Still waiting... (PREADY=%b)", $time, pready);
        end
        // Pready = 1 tại sườn clock này
        
        // --- LẤY DỮ LIỆU ---
        // PREADY đã lên cao, ta có thể lấy dữ liệu từ prdata
        rdata = prdata;
        $display("[%0t]: [READ] PREADY detected! Read data = 0x%h", $time, rdata);
        
        if(pslverr) begin
            $display("[%0t], (CPU), incorrect address", $time);
        end

        @(posedge pclk);

        // --- END --- 
        $display("[%0t]: [READ] End Phase     -> PSEL=0, PWRITE=0, PENABLE=0", $time);
        psel    = `LOW;
        pwrite  = `LOW;
        penable = `LOW;
        paddr   = `RESET_VALUE;
        pwdata  = `RESET_VALUE;
    end
endtask

endmodule