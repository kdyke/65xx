#### Data Path Implementation Notes

In order to support synchronous memories and be able to respond to the results of reads witn a single clock cycle, we have to violate normal good design rules and have purely combinatorial paths from the current memory read output byte all the way through to the data out path and address output paths.   This is because in cases such as zero page addressing, the byte we just read (and is now on the data in path) is required to be on the bus during the current cycle for external synchronous memories (block rams) to provide the results on the next clock cycle.

Also, the 65CE02 generally has shorter execution times than the 6502 and 65C02 did, so in some cases we need to be able to calculate the output address (possibly indexed) at the same time we're driving data out.  The execution timings on the original 6502 generally allowed data to get moved around a bit (there was always a delay of one clock through the ALU) so this wasn't really required in the 6502 re-implementation.

For this and other reasons I've decided to go with dedicated addressing adders for the PC, ABH/ADL and SP sections.  There's not much to be saved in the FPGA by having a single shared ALU and then a dedicated incrementer as well, so instead each of the address sources can do its own calculations as needed.

In general each of the address adders has an 'A' input used for the "base" of the address calcuation, and the 'B' input is used for the "offset", if any.   Simple increments are done via the carry input being set to 0 or 1 as needed, and in some cases (like for RTS) we'll wind up doing an increment at the same time we're reading the new register value off the bus.

#### Data ALU

The data ALU is used for doing all of the user-visible "math" operations such as ADC, SBC, EOR, INC, DEC, etc.   Thus, the data ALU doesn't need to be able to read from the full set of user visible registers.  However, in order to supprt transfers to/from the SPH, SPL and B registers, the ALU B input supports reading from those three registers directly (maybe).

#### Addressing mode descriptions

##### Immediate

```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din -> dALU, dALU -> Reg,  PC++, AddrN = PCn, Tn = 1
```

##### Zero Page

```` 
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	B -> ABHn, Din + 0 -> ABLn, PC++, AddrN = ABn         (Dout = x)
Cycle 3:	Din -> dALU, dALU -> Reg, AddrN = PCn, Tn = 1
````

##### Absolute
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din + 0 -> ABLn, PC++, AddrN = PCn
Cycle 2:	Din + 0 -> ABHn, Din + 0 -> ABLn, PC++, AddrN = ABn
Cycle 4:	Din -> dALU, dALU -> Reg, AddrN = PCn, Tn = 1
```

##### Zero Page Indexed   a8,X
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	B -> ABHn, Din + X -> ABLn, PC++, AddrN = ABn
Cycle 3:	Din -> dALU, dALU -> Reg, AddrN = PCn, Tn = 1
```

##### Absolute Indexed   a16,X
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din + X -> ADLn, PC++, AddrN = PCn
Cycle 2:	Din + 0 + DLc -> ADHn, PC++, AddrN = ADn, ?Dout = reg
Cycle 4:	Din -> dALU, dALU -> Reg, AddrN = PCn, Tn = 1
```

##### Indexed Indirect   (a8,X)
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	B -> ABHn, Din + X -> ABLn, PC++, AddrN = ABn
Cycle 3:	Din + 0 -> ADL, AB++, AddrN = ABn
Cycle 4:	Din + 0 -> ADH, AddrN = ADn, ?Dout = reg
Cycle 5:	Din -> dALU, dALU -> Reg, AddrN = PCn, Tn = 1
```

##### Indirect Indexed (a8),Y
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	B -> ABHn, Din + 0 -> ABLn, PC++, AddrN = ABn
Cycle 3:	Din + Y -> ADLn, AB++, AddrN = ABn
Cycle 4:	Din + 0 + DLc -> ADHn, AddrN = ADn,  ?Dout = reg
Cycle 5:	Din -> dALU, dALU -> Reg, AddrN = PCn, Tn = 1
```

##### Stack Vector Indirect Indexed [(d8, SP), Y] 
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	B -> ABHn, Din + SPL -> ABLn & ADLn, PC++, AddrN = ABn
Cycle 3:	SPH + 0 + DLc -> ABHn, AddrN = ABn
Cycle 4:	Din + Y -> ADLn, AB++, AddrN = ABn
Cycle 5:	Din + 0 + DLc -> ADHn, AddrN = ADn
Cycle 6:	Din -> dALU, dALU -> Reg, AddrN = PCn, Tn = 1
```

##### Jump abs
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din + 0 -> ADLn, PC++, AddrN = PCn
Cycle 3:	Din + 0 -> PCHn, ADL -> PCLn, AddrN = PCn, Tn = 1
```

##### Jump (abs)
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din + 0 -> ADL, PC++, AddrN = PCn
Cycle 3:	Din + 0 -> PCHn, ADL -> PCLn, AddrN = PCn
Cycle 4:	Din + 0 -> ADL, PC++, AddrN = PCn
Cycle 5:	Din + 0 -> PCHn, ADL -> PCLn, AddrN = PCn, Tn = 1
```

##### Jump (abs,x)
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din + X -> ADL, PC++, AddrN = PCn
Cycle 3:	Din + DLc -> PCHn, ADL -> PCLn, AddrN = PCn
Cycle 4:	Din + 0 -> ADL, PC++, AddrN = PCn
Cycle 5:	Din + 0 -> PCHn, ADL -> PCLn, AddrN = PCn, Tn = 1
```

##### Branch 8-bit relative
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	PCH + Din[7] + Cy -> PCHn, PCL + Din + 1 -> PCLn, AddrN = PCn (taken)
Cycle 3:	PC++, AddrN = PCn   (not taken)
```

##### Branch 16-bit relative
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	PCL + Din + 1 -> ADL, PC++, AddrN = PCn
Cycle 3:	PCH + Din + DLc -> PCHn, ADL -> PCLn, AddrN = PCn   (taken)
Cycle 3:	PC++, AddrN = PCn   (not taken)
```

##### JSR a16
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din + 0 -> ADL, PC++, AddrN = SPn, Dout = PCHn
Cycle 3:	AddrN = SPn, SP--, Dout = PCLn
Cycle 4:	AddrN = PCn, SP--
Cycle 5:	Din + 0 -> PCHn, ADL -> PCLn, AddrN = PCn, Tn = 1
```

##### BSR r16
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	PCL + Din + 1 -> ADL, PC++, AddrN = SPn, Dout = PCHn
Cycle 3:	AddrN = SPn, SP--, Dout = PCLn
Cycle 4:	AddrN = PCn, SP--
Cycle 5:	PCH + Din + ADCc -> PCHn, ADL -> PCLn, AddrN = PCn, Tn = 1
```

##### RTS
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	SP++, AddrN = SPn
Cycle 3:	Din + 0 + 1 -> PCLn, SP++, AddrN = SPn
Cycle 4:	Din + Dc -> PCHn, AddrN = PCn
```

##### RTI
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	SP++, AddrN = SPn
Cycle 3:	Din -> P, SP++, AddrN = SPn
Cycle 4:	Din + 0 + 1 -> ADL, SP++, AddrN = SPn
Cycle 5:	Din + 0 + Dc -> PCHn, ADL -> PCLn, AddrN = PCn
```

##### RTN
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	PCL -> ABLn, SP++, AddrN = PCn
Cycle 3:  PCH -> ABHn, SP++, AddrN = SPn
Cycle 4:	Din + 0 + 1 -> PCLn, SP++, AddrN = SPn
Cycle 5:	Din + 0 + DLc -> PCHn, AddrN = AB
Cycle 6:	Din + SPL -> SPLn, AddrN = AB
Cycle 7:	SPH + DLc -> SPHn, AddrN = PCn
```

##### Push reg
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Dout = reg (dALU), AddrN = SPn
Cycle 3:	AddrN = PCn, SP--
```

##### Pull reg
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	AddrN = SPn, SP++
Cycle 3:	AddrN = PCn, Din -> reg
```

##### Push immediate word
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Dout = din (dALU), AddrN = SPn
Cycle 3:	AddrN = PCn, PC++, SP--
Cycle 4:	Dout = din (dALU), AddrN = SPn
Cycle 5:	AddrN = PCn, SP--
```

##### Push absolute word
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din + 0 -> ADL, PC++, AddrN = PCn
Cycle 3:	Din + 0 -> ABHn, ADL -> ABL, AddrN = ABn
Cycle 4:	Dout = Din (dALU), AddrN = SPn
Cycle 5:	AddrN = ABn, AB++, SP--
Cycle 6:	Dout = Din (dALU), AddrN = SPn
Cycle 7:	AddrN = PCn, SP--
```

##### Inc/Dec word zp
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	B -> ABHn, Din + 0 -> ABL, PC++, AddrN = ABn
Cycle 3:	Dout = Din+1, AddrN = ABn
Cycle 4:	AddrN = ABn, AB++
Cycle 5:	Dout = Din + DLc, WordZ = 1, AddrN = ABn
Cycle 6:  AddrN = PCn
```

##### Shift word
```
Cycle 1:	Din -> IR, PC++, AddrN = PCn
Cycle 2:	Din + 0 -> ABL, PC++, AddrN = PCn
Cycle 3:	Din + 0 -> ABHn, PC++, AddrN = ABn
Cycle 4:	Dout = Din+1, AddrN = ABn
Cycle 5:	AddrN = ABn, AB++
Cycle 6:	Dout = Din+Cy, WordZ = 1, AddrN = ABn
Cycle 7:  AddrN = PCn
```


PC Unit Needed operations

Nop
PC INC
PC Load from DB/ADL 				(0+DB,0+ADL,0)
PC Load from DB/ADL+1				(0+DB,0+ADL,1)
PC 8-bit branch		(or inc)		(PCH+DB7,PCL+ADL)
PC 16-bit branch    (or inc)		(PCH+DB, PCL+ADL)
