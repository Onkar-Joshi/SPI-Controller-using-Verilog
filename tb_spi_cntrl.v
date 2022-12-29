
`include "spi_cntrl.v"


module tb;
parameter NUM_OF_SLAVES = 3;
parameter WIDTH = 8;
parameter MAX_TXNS = 8;
reg pclk_i,prst_i,psel_i,penable_i,pwrite_i;
reg [WIDTH-1:0] paddr_i;
reg [WIDTH-1:0]pwdata_i;
wire sclk,mosi;
wire [NUM_OF_SLAVES-1:0] ssel;
reg miso,sclk_ref_i;
wire [WIDTH-1:0] prdata_o;
wire pready_o;
reg [WIDTH-1:0] random_num;
integer j;
spi_cntrl dut(.*);
//generating clk
initial begin
	pclk_i=1;
	forever #5 pclk_i=~pclk_i;
end 
//generating sclk reference
initial begin
	sclk_ref_i=1;
	forever #5 sclk_ref_i=~sclk_ref_i;
end

//applying reset
task reset();
begin
	//make all inputs 0 to avoid red signals in waveform
	prst_i=1;
	psel_i=0;
	penable_i=0;
	pwrite_i=0;
	paddr_i=0;
	pwdata_i=0;
	miso=1;
	@(posedge pclk_i);
	prst_i=0;
end
endtask
// task to write to regs
task write_reg(input [WIDTH-1:0] addr, input [WIDTH-1:0] data);
begin
	pwrite_i=1;
	paddr_i=addr;
	pwdata_i=data;
	psel_i=1;
	penable_i=1;
	wait (pready_o==1);
	@(posedge pclk_i)
	pwrite_i=0;
	paddr_i=0;
	pwdata_i=0;
	psel_i=0;
	penable_i=0;
end
endtask

//task to ready from regs
task read_reg(input [WIDTH-1:0] addr);
begin
	pwrite_i=0;
	paddr_i=addr;
	psel_i=1;
	penable_i=1;
	wait (pready_o==1);
	@(posedge pclk_i)
	psel_i=0;
	penable_i=0;
	paddr_i=0;
	
end
endtask

//main tb
initial begin
	reset();//applying reset
	//writing into addr regs
	for (j=0;j<MAX_TXNS;j=j+1)
	begin
		random_num = $urandom;//random no just for testing

		write_reg(j,{1'b1,random_num[WIDTH-2:0]});//forcing MSB=1 for write oper

	end
	//reading addr regs
	for (j=0;j<MAX_TXNS;j=j+1)
	begin
		read_reg(j);
	end

	//writing into data regs
	for (j=0;j<MAX_TXNS;j=j+1)
	begin
		random_num = $urandom;//random no just for testing
		write_reg(j+8'h10,random_num);
	end
	//reading data regs
	for (j=0;j<MAX_TXNS;j=j+1)
	begin
		read_reg(j+8'h10);
	end
//control reg [3:1]+1 is num of tnxs
//control reg [0] is 1 it initiates txn
//control reg [6:4] is used to indicate index of curr txn
//control reg[7] is interrupt generated to indicate txn is completed

	//writing to control reg
	random_num = $urandom;
	write_reg(8'h20,{4'b0000,3'b010,1'b1});//programming cntr_reg for 3 txns
	#1000;
	write_reg(8'h20,{3'b100,1'b1});//programming cntr_reg for 5 more txns
	//reading from control reg
	read_reg(8'h20);
/*	for (j=0;j<MAX_TXNS;j=j+1)
	begin
		random_num = $urandom;//random no just for testing

		write_reg(j,{1'b0,random_num});//forcing MSB=0 for read oper

	end*/
	
	//control reg [3:1]+1 is num of tnxs
//control reg [0] is 1 it initiates txn
//control reg [6:4] is used to indicate index of curr txn
//control reg[7] is interrupt generated to indicate txn is completed

	//writing to control reg
/*	random_num = $urandom;
	write_reg(8'h20,{4'b0000,3'b010,1'b1});//programming cntr_reg for 3 read txns
	#500;
	write_reg(8'h20,{4'b0000,3'b100,1'b1});//programming cntr_reg for 5 more txns
*/
	#1500;
	$finish;

end
endmodule
