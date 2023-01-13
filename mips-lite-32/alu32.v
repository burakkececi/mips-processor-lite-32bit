module alu32(alu_out, a, b, zout, alu_control);
output reg [31:0] alu_out;
input [31:0] a,b;
input [2:0] alu_control;

reg [31:0] less;
reg [31:0] b_temp; // contains 2's comp b
output zout, sout, vout;
reg zout, sout, vout;

always @(a or b or alu_control)
begin
	/*
	there are 5 type of instructions which are 
	2) sum = a + b
	6) sum = a - b
	7) 
	*/
	case(alu_control)
	3'b010: begin 
			alu_out = a+b;
			if((a[31] && b[31]) && !alu_out[31]) vout = 1'b1;
        	else if ((!a[31] && !b[31]) && alu_out[31]) vout= 1'b1;
        	else vout = 1'b0; //disable overflow
		end 
	3'b110: begin 
			alu_out = a+1+(~b);
			b_temp = ~b + 1; // 2's comp of input B
        	alu_out = a + b_temp; //same as A-B
			// produce overflow
        	if((!a[31] && !b_temp[31]) && alu_out[31]) vout = 1'b1;
        	else vout = 1'b0; // disable overflow
		end
	3'b111: begin less = a+1+(~b);
			if (less[31]) alu_out=1;
			else alu_out=0;
		end
	/*
	0) a AND b
	1) a OR b
	*/
	3'b000: alu_out = a & b;
	3'b001: alu_out = a | b;
	3'b011: alu_out = a ^ b; //bitwise XOR
	3'b100: alu_out = ~(a | b); // NOR operation
	default: alu_out=31'bx;
	endcase
end

always @(alu_out) begin
    if(!alu_out) = zout = 1'b1; // produce zero flag
    else zout = 1'b0;

    if(alu_out[31]) sout = 1'b1; // produce neg flag
    else sout = 1'b0;
end

endmodule
