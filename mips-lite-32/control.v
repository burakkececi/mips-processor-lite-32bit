module control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2, jump, bformat, bvf, ben, cpsr_update, cpsr_reset);
input [5:0] in;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2, jump, bformat, bvf, ben, cpsr_update, cpsr_reset;

wire rformat,itype,lw,sw,beq,j,addi,bformat,bvf,ben;

assign rformat =~| in;

assign lw = in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];

assign sw = in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];

assign beq = ~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);

assign j = (~in[5]) & (~in[4]) & (~in[3]) & (~in[2]) & in[1] & (~in[0]);

assign addi = (~in[5]) & (~in[4]) & in[3] & (~in[2]) & (~in[1]) & (~in[0]);

assign bvf = (~in[5]) & (~in[4]) & in[3] &in[2]& (~in[1]) &in[0]; // 0x5

assign ben = (~in[5]) & (~in[4]) & in[3] &in[2]&in[1]& (~in[0]); // 0x6

assign regdest = rformat;

assign itype = lw|sw|addi;
assign bformat = bvf|ben;

assign cpsr_update = rformat|itype;
assign cpsr_reset = bformat| branch | (~cpsr_update) | j

assign alusrc = lw|sw|addi;
assign memtoreg = lw;
assign regwrite = rformat|lw|addi;
assign memread = lw;
assign memwrite = sw;
assign branch = beq;
assign aluop1 = rformat;
assign aluop2 = beq;
assign jump = j;
assign ben = ben;

endmodule
