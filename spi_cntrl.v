//spi controller only register programming
module spi_cntrl(
//Processor interface
pclk_i,prst_i,psel_i,penable_i,pwrite_i,paddr_i,pwdata_i,prdata_o,pready_o,
//SPI slave interface
sclk,mosi,miso,ssel);

parameter NUM_OF_SLAVES = 3;

parameter WIDTH = 8;
parameter MAX_TXNS = 8;
input pclk_i,prst_i,psel_i,penable_i,pwrite_i;
input [WIDTH-1:0] paddr_i;
input [WIDTH-1:0]pwdata_i;
output reg sclk,mosi;
output reg [NUM_OF_SLAVES-1:0] ssel;
input miso;
output reg [WIDTH-1:0] prdata_o;
output reg pready_o;
integer i;
//SPI registers
reg [WIDTH-1:0] addr_regA[MAX_TXNS-1:0];
reg [WIDTH-1:0] data_regA[MAX_TXNS-1:0];
reg [WIDTH-1:0] cntrl_reg;


always @(posedge pclk_i)
begin
	if (prst_i)
	begin
		prdata_o=0;
		pready_o=0;
		sclk=1;
		mosi=1;
		ssel=0;
		for (i=0;i<MAX_TXNS;i=i+1)
		begin
			addr_regA[i]=0;
			data_regA[i]=0;
		end
		cntrl_reg=0;
	end
	else//programming the addr,data and cntrl regs
	begin
		pready_o=0;
		if (psel_i && penable_i)
		begin
			pready_o=1;
			if(pwrite_i)//write opertion
			begin
			//00,01,02,03,04,05,06,07 address for addr regs
			//08,09,0a,0b,0c,0d,0e,0f reserved for future use

				if(paddr_i>=8'h0 && paddr_i<=8'h7)
				addr_regA[paddr_i] = pwdata_i;
			//10,11,12,13,14,15,16,17 address for data regs
			//18,19,1a,1b,1c,1d,1e,1f reserved for future use

				if(paddr_i>=8'h10 && paddr_i<=8'h17)
				data_regA[paddr_i-8'h10] = pwdata_i;
			//20 for control reg
				if(paddr_i==8'h20)
				cntrl_reg[3:0] = pwdata_i[3:0];
			end
			else //read operation
			begin
				if(paddr_i>=8'h0 && paddr_i<=8'h7)
				prdata_o = addr_regA[paddr_i];
				if(paddr_i>=8'h10 && paddr_i<=8'h17)
				prdata_o =data_regA[paddr_i-8'h10];
				if(paddr_i==8'h20)
				prdata_o[3:0]=cntrl_reg[3:0];
			end
			
		end
	end
end

endmodule
