#### Implementation Notes

The basic idea behind this whole design is to build everything assuming synchrnonous clocked memories and such.  This goes for both the internal "PLA" (stored in a block RAM) and external memories.

One of the upshots to this is that the CPU core can't really "latch" external data from the external bus at the positive clock edge because it won't actually show up from the external memory (i.e. block RAM) until the following cycle.   This means that the external bus logic effectively becomes the "data latch" that otherwise would have existed internal to the CPU.

The CPU still has an internal temporary DL-like register for holding intermediate results, however.

The other primary design goal is to optimize things (as best as my feeble skills currently allow) assuming that we are targeting an FPGA.  This means using FPGA resources in such a way to give us the most bang for our buck (hence the desire to use a block RAM for the PLA instead of the usual sea of combinatorial logic).

#### Timing Control

On the original 6502 the timing control was (almost) a one-hot design, except for the magic T0+T2 state where both states were active simulataneously.   T0 was in general the next-to-last instruction state, following by T1 where the following instruction was fetched and any last bit of the previous instruction's execution was completed.   Cycle T2 on the original 6502 was the "predecode" cycle where the PLA was precharged and some other bits of state were precalated directly, such as whether this was a one or two byte instruction, which might cause the CPU to also enable the T0 state during the current T2 cycle.

In my design I can't really do the T0+T2 thing because I'm using a block RAM in place of a PLA, and so I can only have one "active" state at a time.  It also breaks my brain to have the first cycle of an instruction start with T1, so in my design instruction fetch always starts with T0[^brain].  The other advantage to this is that the predecode timing step is now *always* T1, no matter how we got there.  In the original, it was always basically T2, but I didn't want the short instructions to ever use T2.

During T0, the address bus will contain the address of the next instruction to be fetched.  The data path will be finishing up the prior instruction execution if needed.

During T1, the instruction from T0's address will be visible on the data bus input.  T1 will always enable the IR load signal so that the output of the block RAM becomes available during the following cycle to begin the actual work of instruction execution.

Note: Somewhere (either during T0 or T1) we will detect that an interrupt is pending and force it so that during T1 we'll use a value of 0x00 for the "fetched" instruction (i.e. BRK).   I need to double check on which cycle it's more appropriate to do that to emulate the original timing behavior.

Also, during T1 we also need to determine whether or not to increment the PC.  One byte instructions (at least in pure 6502 mode) should not increment the PC as they still take a minimum of two cycles to execute.

If the instruction predecode determines that this is a one or two byte instruction then we must also force the next T cycle to 0.   We can't wait for the PLA to give us that during T2 as it would be too late to make the transition back to T0[^f1].

#### "PLA" output encoding

In cases where we want to control a mux I'm going to try to use normal n-bit encodings since those should be usable directly.  For load-enables I think single output bits per enable will be the right thing to try.

For T state control I'm thinking it might be fine to just use a direct "next" field that maybe has certain special values to override the behavior (such as for conditional branches, and cases under which we can go to state 0 earlier, such as some of the indexed addressing modes w/o page crossings).

[^brain]: One downside to doing it this way is that anyone else who's ever wrapped their head around the original 6502 timing control is going to have a Hell of a time with the fact I rearranged things.   At the end of the day it's all just addresses in the PLA, so mabye it wouldn't matter which route I took.

[^f1]: Idea: What if we allowed these instructions to proceed to T2, but then had their T2 microcode act just like T0?  The extra block ram space doesn't cost us anything, so there's no harm in always moving to T2.  This might simplify the timing control logic, and the Tnext PLA output for these instructions could say T1 just as easily as their T0 could.  Hmmm...