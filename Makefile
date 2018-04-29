functest : testbed.v func_test.v 6502_top.v microcode.v 6502_alu.v 6502_inc.vh
	iverilog -o functest -s main testbed.v func_test.v 6502_top.v 6502_alu.v microcode.v

inttest : testbed.v int_test.v 6502_top.v microcode.v 6502_alu.v 6502_inc.vh
	iverilog -o inttest -s main testbed.v int_test.v 6502_top.v 6502_alu.v microcode.v

func : functest
	functest

int : inttest
	inttest
