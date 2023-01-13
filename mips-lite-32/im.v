module insmem (input[31:0] addr, output [31:0] inst);

reg[31:0] i_mem[31:0];
	
	//Used to load program into instruction memory
	initial begin
		$readmemb("i_mem.txt",i_mem);
	end
	
	assign inst = i_mem[addr];

endmodule


