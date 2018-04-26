testbed : testbed.v func_test.v 6502_top.v microcode.v 6502_alu.v 6502_inc.vh
	iverilog -o testbed -s main testbed.v func_test.v 6502_top.v 6502_alu.v microcode.v

test : testbed
	testbed
