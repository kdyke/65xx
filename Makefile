CORE_SRCS = 6502_top.v 6502_ucode.v 6502_alu.v 6502_timing.v 6502_mux.v 6502_reg.v 4510_top.v 4510_mapper.v 4510_hyper.v
CORE_HDRS = 6502_inc.vh

functest : testbed.v func_test.v $(CORE_SRCS) $(CORE_HDRS)
	iverilog -o functest -s main -D CMOS=1 testbed.v func_test.v $(CORE_SRCS)

cfunctest : testbed.v func_test.v $(CORE_SRCS) $(CORE_HDRS)
	iverilog -o cfunctest -s main testbed.v func_test.v $(CORE_SRCS)

inttest : testbed.v int_test.v $(CORE_SRCS) $(CORE_HDRS)
	iverilog -o inttest -s main testbed.v int_test.v $(CORE_SRCS)

cmostest : testbed.v cmos_test.v $(CORE_SRCS) $(CORE_HDRS)
	iverilog -o cmostest -s main -D CMOS=1 testbed.v cmos_test.v $(CORE_SRCS)

cinttest : testbed.v cint_test.v $(CORE_SRCS) $(CORE_HDRS)
	iverilog -o cinttest -s main -D CMOS=1 testbed.v cint_test.v $(CORE_SRCS)

etest : testbed.v efunc_test.v $(CORE_SRCS) $(CORE_HDRS)
	iverilog -o etest -s main -D CMOS=1 testbed.v efunc_test.v $(CORE_SRCS)

efunc_test.v : 65CE02_opcodes_test.hex hex2v
	hex2v  65CE02_opcodes_test.hex efunc_test.v memory 65536

hex2v : hex2v.c
	cc -o hex2v hex2v.c

65CE02_opcodes_test.hex : 65CE02_opcodes_test.t64
	64tass  --m4510  --intel-hex -o 65CE02_opcodes_test.hex --list=65CE02_opcodes_test.lst --verbose-list 65CE02_opcodes_test.t64

copy :
	cp func_test.v $(CORE_SRCS) $(CORE_HDRS) /Volumes/Projects/6502_sync

func : functest
	functest

cfunc : cfunctest
	cfunctest

int : inttest
	inttest

cmos : cmostest
	cmostest

cint : cinttest
	cinttest

e : etest
	etest
