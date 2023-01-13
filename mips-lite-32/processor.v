module processor;

reg [31:0] pc;

reg clk;
reg [7:0] datmem[0:31], mem[0:31];

wire [31:0] dataa,datab;
wire [31:0] out2,out3,out4; 
wire [31:0] sum, extad, adder1out, adder2out;
wire [31:0] sextad,readdata;
wire [28:0] jumpAddr;

wire [5:0] inst31_26;
wire [25:0] inst25_0;
wire [4:0] inst25_21, inst20_16, inst15_11, out1;
wire [15:0] inst15_0;
wire [31:0] instruc,dpack;
wire [2:0] gout;

wire cout,zout,nout,pcsrc,regdest,alusrc,memtoreg,regwrite,memread,
memwrite,branch,aluop1,aluop0,jump,ben,bvf,sout,vout, cpsr_reset, cpsr_update,
cpsr_mux, bformat;

reg [31:0] registerfile [0:31];
integer i;

// datamemory connections
always @(posedge clk)
begin
	if(memwrite)
	begin 
		datmem[sum[4:0]+3]=datab[7:0];
		datmem[sum[4:0]+2]=datab[15:8];
		datmem[sum[4:0]+1]=datab[23:16];
		datmem[sum[4:0]]=datab[31:24];
	end
end

//instruction memory
assign instruc = {mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
assign inst31_26 = instruc[31:26];
assign inst25_0 = instruc [25:0]; // 26 bit instruction field
assign inst25_21 = instruc[25:21];
assign inst20_16 = instruc[20:16];
assign inst15_11 = instruc[15:11];
assign inst15_0 = instruc[15:0];

// registers
assign dataa = registerfile[inst25_21];
assign datab = registerfile[inst20_16];

//multiplexers
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};

mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);
mult2_to_1_32 mult2(out2, datab, extad, alusrc);
mult2_to_1_32 mult3(out3, sum, dpack, memtoreg);
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);
mult2_to_1_32 mult5(out5, out4,pcjaddr,jump); // (pc + 4) + jump addr or out4 result according to jump selection bit
mult2_to_1_32 mult6(out6, out5,extad,cpsr_mux);


always @(posedge clk)
begin
	registerfile[out1]= regwrite ? out3 : registerfile[out1];
end


// load pc
always @(negedge clk)
pc = out4;

// alu, adder and control logic connections

alu32 alu1(sum, dataa, out2, zout, gout);
adder add1(pc,32'h4,adder1out);
adder add2(adder1out,sextad,adder2out);
/*
control(in, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2);
*/
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,jump, bformat, bvf, ben, cpsr_update, cpsr_reset);

CPSR flagReg(zout,sout,vout,ben,bvf,cpsr_reset,cpsr_update,cpsr_out);

signext sext(instruc[15:0],extad);

alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0],gout);

shift shift2(sextad,extad);

// shifted 26 bit jump address to 28 bit address
assign jumpaddr26 = inst25_0;
assign jumpAddr28 = {jumpaddr26}<<2;

// added together pc + 4 and shifted jump address
assign pcjaddr = {jumpaddr28[27:0], adder1out[31:28]};

assign cpsr_mux = bformat && cpsr_out;

assign pcsrc = branch && zout;

//initialize datamemory,instruction memory and registers
initial
begin
	$readmemh("/home/burak/docs/course/CENG311-CompArch/Mips/singlecycleMIPS-lite/initdata.dat",datmem);
	$readmemh("/home/burak/docs/course/CENG311-CompArch/Mips/singlecycleMIPS-lite/init.dat",mem);
	$readmemh("/home/burak/docs/course/CENG311-CompArch/Mips/singlecycleMIPS-lite/initreg.dat",registerfile);

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
	pc=0;
	#400 $finish;
end

initial
begin
	clk=0;
forever #20  clk=~clk;
end

initial 
begin
	$monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
	"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end

endmodule

