#### Implementation Notes

The basic idea behind this whole design is to build everything assuming synchrnonous clocked memories and such.  This goes for both the internal "PLA" (stored in a block RAM) and external memories.

The other primary design goal is to optimize things (as best as my feeble skills currently allow) assuming that we are targeting an FPGA.  This means using FPGA resources in such a way to give us the most bang for our buck (hence the desire to use a block RAM for the PLA instead of the usual sea of combinatorial logic).

Storing the microcode in block rams currently seems to save around 200 LUTs, although it's not really a fair comparison because the synthesis tools can only do so much given how the microcode is described today.  But, one interesting thing is that filling up the microcode completely is basically "free" except for any additional data path logic that's needed to support whatever instructions want to be supported.

#### Timing Control

On the original 6502 the timing control was (almost) a one-hot design, except for the magic T0+T2 state where both states were active simulataneously.   T0 was in general the next-to-last instruction state, following by T1 where the following instruction was fetched and any last bit of the previous instruction's execution was completed.

In my design I can't really do the T0+T2 thing because I'm using a block RAM in place of a PLA, and so I can only have one "active" state at a time.  But the original T0+T2 state was likely just an optimization so that two cycle instructions wouldn't need duplicated PLA decodes for all of the cases where T2 would have otherwise done the right thing.  Because I'm using a block RAM, I don't have that problem so T0 just containts whatever state is needed.

#### "PLA" output encoding

In cases where we want to control a mux I'm going to try to use normal n-bit encodings since those should be usable directly.  For load-enables I think single output bits per enable will be the right thing to try.

The current microcode is 54 bits wide and so fits exactly into 3 2Kx18 bit block rams.  There are probably some savings to be had by combining the ADL/ADH field into a unified field since there aren't really 2^6 possible combinations in use by the microcode. It'd be trivial to encode the current combinations with only 4 bits, and it might be possible to get it down to just 8 with better use of ABL/ABH holds.

#### Timing control

Right now timing control is done with a simple 3-bit register that contains the current state (T0 to T7).  The microcode has another encoded 3-bit field that describes what state to go to next.  The "default" is just to go to T+1, but there are many conditions where something else needs to happen based on internal CPU state.  Other things like the predecode logic factor into this as well.

##### Experiments tried

I tried doing the timing with an "offical" FSM and it wound up taking up more LUTs and was only marginally faster.  Going to a one-hot design might be ok if I could also redo the microcode outputs to have a single bit for all of the special cases rather than having to decode things.  This would require freeing up some microcode bits, though.