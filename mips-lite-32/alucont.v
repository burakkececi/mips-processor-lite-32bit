module alucont(aluop1,aluop0,f3,f2,f1,f0,gout);

input aluop1,aluop0,f3,f2,f1,f0;
output [2:0] gout;
reg [2:0] gout;

always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
	if(~(aluop1|aluop0))
		gout=3'b010;
	if(aluop0)
		gout=3'b110;
	if(aluop1)
	begin
		if (~(f3|f2|f1|f0))
			gout=3'b010;
		if (f1 & f3)
			gout=3'b111;
		if (f1 &~(f3))
			gout=3'b110;
		if (f2 & f0)
			gout=3'b001;
		if (f2 &~(f0))
			gout=3'b000;
		if (f2 & f1 & f3 & f0)
			gout = 3'b011;
		if (f2 & f1 & f0 & (~f3)) // 0111 for nor operation according to mips green sheet
			gout = 3'b100; // free pin for output
	end
end
endmodule
