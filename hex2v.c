#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

int main(int argc, char **argv)
{
	FILE *in = fopen(argv[1],"r");
	FILE *out = fopen(argv[2],"w");
	
	size_t ramsize = strtoul(argv[4],NULL,0);
	
	fprintf(out,
		"module %s(clk, we, addr, di, do);\n"
		"input clk;\n"
		"input we;\n"
		"input [15:0] addr;\n"
		"input [7:0] di;\n"
		"output [7:0] do;\n"
		"reg [7:0] ram [0:%ld];"
		"reg [7:0] do;\n"
		"\n"
		"initial\n"
		"begin\n"
		,argv[3],ramsize-1);
	
	for(;;)
	{
		char buffer[256];
		fgets(buffer,256,in);
		uint32_t count, addr, type, byte;
		sscanf(&buffer[1],"%02x%04x%02x",&count,&addr,&type);
		//fprintf(stderr,"count: %d addr: %04x type: %02x\n",count,addr,type);
		if(type == 0x01)
			break;
		for(uint32_t i = 0; i < count; i++)
		{
			sscanf(&buffer[9+i*2],"%02x",&byte);
			fprintf(out,"ram[16'h%04x] = 8'h%02x; ",addr+i,byte);
			if((i+1)%8 == 0)
				fprintf(out,"\n");
		}
		fprintf(out,"\n");
	}
	fprintf(out,
		" // Override start vector\n"
		"ram[16'hfffc] = 8'h00;\n"
		"ram[16'hfffd] = 8'h06;\n"
		"end\n\n"
		"always @(posedge clk)\n"
		"begin\n"
		"    if(we)\n"
		"        ram[addr] = di;\n"
		"    if(we && addr == 16'h0400)\n"
          	"        $display(\"last test: %%d\",di);\n"
		"    do = ram[addr];\n"
		"end\n"
		"\n"
		"endmodule\n");
	fclose(in);
	fclose(out);
	exit(0);
}
