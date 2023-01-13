module CPSR(zout,sout,vout,ben,bvf,cpsr_reset,cpsr_update,cpsr_out);

input zout,sout,vout,ben,bvf,cpsr_reset,cpsr_update;
output cpsr_out;
reg [2:0] svz;

always @(cpsr_update |cpsr_reset) begin
    if(cpsr_reset) svz = 3'b000;
    else if(cpsr_update) svz = {sout, vout, zout};
end

always @(ben|bvf)begin
    if(ben&svz[0]) assign cpsr_out = svz[0];
    else if(bvf&svz[1]) assign cpsr_out = svz[1];
    else if(ben&svz[2]) assign cpsr_out = svz[2];
    else assign cpsr_out = 0;
end

endmodule