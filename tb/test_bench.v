`timescale 1ns / 1ns

module test_bench;

    // Clock & Reset
    wire pclk;
    wire preset_n;

    // APB signals
    wire psel;
    wire pwrite;
    wire penable;
    wire [7:0] paddr;
    wire [7:0] pwdata;
    wire [7:0] prdata;
    wire pready;
    wire pslverr;
    
    // Wires để kết nối và theo dõi các thanh ghi của DUT
    wire [7:0] A_out, B_out, C_out, D_out, E_out, F_out, G_out, H_out;

    //================================================================
    // KHAI BÁO BIẾN CHO TESTBENCH
    //================================================================
    reg [7:0] write_data;
    reg [7:0] read_data;
    reg [7:0] temp_addr;
    integer   i, pass_count, fail_count;

    //================================================================
    // 1. INSTANTIATION
    //================================================================

    system_signals u_signals (
        .pclk(pclk),
        .preset_n(preset_n)
    );
    cpu_model CPU ( 
		.pclk(pclk), 
		.preset_n(preset_n), 
		.pready(pready), 
		.pslverr(pslverr), 
		.prdata(prdata), 
		.psel(psel), 
		.pwrite(pwrite), 
		.penable(penable), 
		.paddr(paddr), 
		.pwdata(pwdata) );

    // Khởi tạo basic_ip_core và kết nối các cổng output của thanh ghi
    basic_ip_core DUT (
        .pclk(pclk), 
		.preset_n(preset_n), 
		.psel(psel), 
		.penable(penable), 
		.pwrite(pwrite),
        .paddr(paddr), 
		.pwdata(pwdata), 
		.pready(pready), 
		.pslverr(pslverr), .
		prdata(prdata),
        .A(A_out), .B(B_out), .C(C_out), .D(D_out), .E(E_out), .F(F_out), .G(G_out), .H(H_out)
    );

    //================================================================
    // 2. MAIN STIMULUS AND CHECKER
    //================================================================
    initial begin
        // Khởi tạo giá trị ban đầu cho các biến đếm
        i = 0;
        pass_count = 0;
        fail_count = 0;

        $display("\nINFO: Starting APB Read/Write Verification for BASIC_IP_CORE");
        wait (preset_n == 1'b1);
        @(posedge pclk); #10;

        $display("INFO: ---> BEGINNING RANDOMIZED WRITE-CHECK-READ-CHECK TESTS...");
        repeat (50) begin
            temp_addr  = $urandom_range(0, 7);
            write_data = $random;

            $display("\n--------------------------------------------------------");
            $display("TEST #%0d: Verifying R/W for Addr=0x%h", (i+1), temp_addr);
            $display("--------------------------------------------------------");

            // --- BƯỚC 1: GHI DỮ LIỆU ---
            CPU.MOVT(temp_addr, write_data);

            // --- BƯỚC 2: KIỂM TRA TRỰC TIẾP (WRITE PATH) ---
            @(posedge pclk);
            case (temp_addr)
                8'h00: if (A_out !== write_data) $error("WRITE FAIL Reg A: Expected 0x%h, Got 0x%h", write_data, A_out);
                8'h01: if (B_out !== write_data) $error("WRITE FAIL Reg B: Expected 0x%h, Got 0x%h", write_data, B_out);
                8'h02: if (C_out !== write_data) $error("WRITE FAIL Reg C: Expected 0x%h, Got 0x%h", write_data, C_out);
                8'h03: if (D_out !== write_data) $error("WRITE FAIL Reg D: Expected 0x%h, Got 0x%h", write_data, D_out);
                8'h04: if (E_out !== write_data) $error("WRITE FAIL Reg E: Expected 0x%h, Got 0x%h", write_data, E_out);
                8'h05: if (F_out !== write_data) $error("WRITE FAIL Reg F: Expected 0x%h, Got 0x%h", write_data, F_out);
                8'h06: if (G_out !== write_data) $error("WRITE FAIL Reg G: Expected 0x%h, Got 0x%h", write_data, G_out);
                8'h07: if (H_out !== write_data) $error("WRITE FAIL Reg H: Expected 0x%h, Got 0x%h", write_data, H_out);
            endcase

            // --- BƯỚC 3: ĐỌC DỮ LIỆU ---
            CPU.MOVF(temp_addr, read_data);
            
            // --- BƯỚC 4: KIỂM TRA DỮ LIỆU ĐỌC VỀ (READ PATH) ---
            if (read_data === write_data) begin
                pass_count = pass_count + 1;
                $display("[PASS] Write/Read matched: 0x%h", read_data);
            end else begin
                fail_count = fail_count + 1;
                $error("[FAIL] Read mismatch: Expected 0x%h, Got 0x%h", write_data, read_data);
            end
            
            i = i + 1;
        end

        // --- TEST CÁC TRƯỜNG HỢP LỖI ---
        $display("\n\nINFO: ---> BEGINNING ERROR CONDITION TESTS...");
        temp_addr = 8'hA0;
        $display("\n--------------------------------------------------------");
        $display("TEST #%0d: Write to Invalid Addr=0x%h", (i+1), temp_addr);
        CPU.MOVT(temp_addr, $random);
        i = i + 1;
        
        temp_addr = 8'hB0;
        $display("\n--------------------------------------------------------");
        $display("TEST #%0d: Read from Invalid Addr=0x%h", (i+1), temp_addr);
        CPU.MOVF(temp_addr, read_data);
        i = i + 1;

        // --- BÁO CÁO TỔNG KẾT ---
        $display("\n========================================================");
        $display("============= VERIFICATION SUMMARY =================");
        $display("Total Tests: %0d", i);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        if (fail_count == 0) begin
            $display("STATUS:      ALL TESTS PASSED");
        end else begin
            $display("STATUS:      SIMULATION FAILED");
        end
        $display("========================================================");
        $finish;
    end

endmodule