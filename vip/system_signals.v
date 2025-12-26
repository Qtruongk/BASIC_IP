module system_signals(
	output reg pclk,
	output reg preset_n
);

// initial begin
//   $display("At %0t, (SS) is being initiated", $time);
// end

initial begin
		pclk = 1'b0;
		forever begin
			#10;
			pclk = !pclk;
		end
end

initial begin
	preset_n = 1'b1;
	#20;
	preset_n = 1'b0;
	#50;
	preset_n = 1'b1;
end

task system_reset();
    begin
        preset_n = 1'b0;
        #20
        preset_n = 1'b1;
    end
endtask

endmodule