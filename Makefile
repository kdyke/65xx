functest : testbed.v func_test.v 6502_top.v microcode.v 6502_alu.v 6502_inc.vh
	iverilog -o functest -s main -D CMOS=1 testbed.v func_test.v 6502_top.v 6502_alu.v microcode.v

cfunctest : testbed.v func_test.v 6502_top.v microcode.v 6502_alu.v 6502_inc.vh
	iverilog -o cfunctest -s main testbed.v func_test.v 6502_top.v 6502_alu.v microcode.v

inttest : testbed.v int_test.v 6502_top.v microcode.v 6502_alu.v 6502_inc.vh
	iverilog -o inttest -s main testbed.v int_test.v 6502_top.v 6502_alu.v microcode.v

cmostest : testbed.v cmos_test.v 6502_top.v microcode.v 6502_alu.v 6502_inc.vh
	iverilog -o cmostest -s main -D CMOS=1 testbed.v cmos_test.v 6502_top.v 6502_alu.v microcode.v

copy :
	cp func_test.v 6502_top.v microcode.v 6502_alu.v 6502_inc.vh /Volumes/Projects/6502_sync

func : functest
	functest

cfunc : cfunctest
	cfunctest

int : inttest
	inttest

cmos : cmostest
	cmostest
