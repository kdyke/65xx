module memory(clk, we, addr_r, addr_w, di, do);
input clk;
input we;
input [15:0] addr_r;
input [15:0] addr_w;
input [7:0] di;
output [7:0] do;
reg [7:0] ram [0:65535];reg [7:0] do;

initial
begin
ram[16'h000a] = 8'h00; ram[16'h000b] = 8'h00; ram[16'h000c] = 8'h00; ram[16'h000d] = 8'h00; ram[16'h000e] = 8'h00; ram[16'h000f] = 8'h00; 
ram[16'h0200] = 8'h00; ram[16'h0201] = 8'h00; ram[16'h0202] = 8'h00; ram[16'h0203] = 8'h00; 
ram[16'h0400] = 8'hd8; ram[16'h0401] = 8'ha9; ram[16'h0402] = 8'h00; ram[16'h0403] = 8'h8d; ram[16'h0404] = 8'h03; ram[16'h0405] = 8'h02; ram[16'h0406] = 8'ha2; ram[16'h0407] = 8'hff; 
ram[16'h0408] = 8'h9a; ram[16'h0409] = 8'had; ram[16'h040a] = 8'hfc; ram[16'h040b] = 8'hbf; ram[16'h040c] = 8'h29; ram[16'h040d] = 8'h7e; ram[16'h040e] = 8'h8d; ram[16'h040f] = 8'hfc; 
ram[16'h0410] = 8'hbf; ram[16'h0411] = 8'had; ram[16'h0412] = 8'hfc; ram[16'h0413] = 8'hbf; ram[16'h0414] = 8'h29; ram[16'h0415] = 8'h7d; ram[16'h0416] = 8'h8d; ram[16'h0417] = 8'hfc; 
ram[16'h0418] = 8'hbf; ram[16'h0419] = 8'ha9; ram[16'h041a] = 8'h02; ram[16'h041b] = 8'h8d; ram[16'h041c] = 8'h03; ram[16'h041d] = 8'h02; ram[16'h041e] = 8'ha9; ram[16'h041f] = 8'h00; 

ram[16'h0420] = 8'h48; ram[16'h0421] = 8'had; ram[16'h0422] = 8'hfc; ram[16'h0423] = 8'hbf; ram[16'h0424] = 8'h29; ram[16'h0425] = 8'h7f; ram[16'h0426] = 8'h09; ram[16'h0427] = 8'h01; 
ram[16'h0428] = 8'h28; ram[16'h0429] = 8'h48; ram[16'h042a] = 8'h08; ram[16'h042b] = 8'h8d; ram[16'h042c] = 8'hfc; ram[16'h042d] = 8'hbf; ram[16'h042e] = 8'hea; ram[16'h042f] = 8'hea; 
ram[16'h0430] = 8'hea; ram[16'h0431] = 8'had; ram[16'h0432] = 8'h03; ram[16'h0433] = 8'h02; ram[16'h0434] = 8'hd0; ram[16'h0435] = 8'hfe; ram[16'h0436] = 8'hba; ram[16'h0437] = 8'he0; 
ram[16'h0438] = 8'hfd; ram[16'h0439] = 8'hd0; ram[16'h043a] = 8'hfe; ram[16'h043b] = 8'ha5; ram[16'h043c] = 8'h0c; ram[16'h043d] = 8'h4d; ram[16'h043e] = 8'hfe; ram[16'h043f] = 8'h01; 

ram[16'h0440] = 8'h29; ram[16'h0441] = 8'hcb; ram[16'h0442] = 8'hd0; ram[16'h0443] = 8'hfe; ram[16'h0444] = 8'ha2; ram[16'h0445] = 8'hff; ram[16'h0446] = 8'h9a; ram[16'h0447] = 8'ha2; 
ram[16'h0448] = 8'h49; ram[16'h0449] = 8'ha0; ram[16'h044a] = 8'h52; ram[16'h044b] = 8'ha9; ram[16'h044c] = 8'h02; ram[16'h044d] = 8'h8d; ram[16'h044e] = 8'h03; ram[16'h044f] = 8'h02; 
ram[16'h0450] = 8'ha9; ram[16'h0451] = 8'h00; ram[16'h0452] = 8'h48; ram[16'h0453] = 8'had; ram[16'h0454] = 8'hfc; ram[16'h0455] = 8'hbf; ram[16'h0456] = 8'h29; ram[16'h0457] = 8'h7f; 
ram[16'h0458] = 8'h09; ram[16'h0459] = 8'h01; ram[16'h045a] = 8'h28; ram[16'h045b] = 8'h48; ram[16'h045c] = 8'h08; ram[16'h045d] = 8'h8d; ram[16'h045e] = 8'hfc; ram[16'h045f] = 8'hbf; 

ram[16'h0460] = 8'h88; ram[16'h0461] = 8'h88; ram[16'h0462] = 8'h88; ram[16'h0463] = 8'h88; ram[16'h0464] = 8'h08; ram[16'h0465] = 8'he0; ram[16'h0466] = 8'h4a; ram[16'h0467] = 8'hd0; 
ram[16'h0468] = 8'hfe; ram[16'h0469] = 8'hc0; ram[16'h046a] = 8'h4b; ram[16'h046b] = 8'hd0; ram[16'h046c] = 8'hfe; ram[16'h046d] = 8'hc9; ram[16'h046e] = 8'h51; ram[16'h046f] = 8'hd0; 
ram[16'h0470] = 8'hfe; ram[16'h0471] = 8'hba; ram[16'h0472] = 8'he0; ram[16'h0473] = 8'hfc; ram[16'h0474] = 8'hd0; ram[16'h0475] = 8'hfe; ram[16'h0476] = 8'h68; ram[16'h0477] = 8'h4d; 
ram[16'h0478] = 8'hfe; ram[16'h0479] = 8'h01; ram[16'h047a] = 8'h29; ram[16'h047b] = 8'h7d; ram[16'h047c] = 8'hd0; ram[16'h047d] = 8'hfe; ram[16'h047e] = 8'ha5; ram[16'h047f] = 8'h0a; 

ram[16'h0480] = 8'hcd; ram[16'h0481] = 8'hff; ram[16'h0482] = 8'h01; ram[16'h0483] = 8'hd0; ram[16'h0484] = 8'hfe; ram[16'h0485] = 8'ha2; ram[16'h0486] = 8'hff; ram[16'h0487] = 8'h9a; 
ram[16'h0488] = 8'ha2; ram[16'h0489] = 8'hb6; ram[16'h048a] = 8'ha0; ram[16'h048b] = 8'had; ram[16'h048c] = 8'ha9; ram[16'h048d] = 8'h02; ram[16'h048e] = 8'h8d; ram[16'h048f] = 8'h03; 
ram[16'h0490] = 8'h02; ram[16'h0491] = 8'ha9; ram[16'h0492] = 8'hfb; ram[16'h0493] = 8'h48; ram[16'h0494] = 8'had; ram[16'h0495] = 8'hfc; ram[16'h0496] = 8'hbf; ram[16'h0497] = 8'h29; 
ram[16'h0498] = 8'h7f; ram[16'h0499] = 8'h09; ram[16'h049a] = 8'h01; ram[16'h049b] = 8'h28; ram[16'h049c] = 8'h48; ram[16'h049d] = 8'h08; ram[16'h049e] = 8'h8d; ram[16'h049f] = 8'hfc; 

ram[16'h04a0] = 8'hbf; ram[16'h04a1] = 8'h88; ram[16'h04a2] = 8'h88; ram[16'h04a3] = 8'h88; ram[16'h04a4] = 8'h88; ram[16'h04a5] = 8'h08; ram[16'h04a6] = 8'he0; ram[16'h04a7] = 8'hb7; 
ram[16'h04a8] = 8'hd0; ram[16'h04a9] = 8'hfe; ram[16'h04aa] = 8'hc0; ram[16'h04ab] = 8'ha6; ram[16'h04ac] = 8'hd0; ram[16'h04ad] = 8'hfe; ram[16'h04ae] = 8'hc9; ram[16'h04af] = 8'h51; 
ram[16'h04b0] = 8'hd0; ram[16'h04b1] = 8'hfe; ram[16'h04b2] = 8'hba; ram[16'h04b3] = 8'he0; ram[16'h04b4] = 8'hfc; ram[16'h04b5] = 8'hd0; ram[16'h04b6] = 8'hfe; ram[16'h04b7] = 8'h68; 
ram[16'h04b8] = 8'h4d; ram[16'h04b9] = 8'hfe; ram[16'h04ba] = 8'h01; ram[16'h04bb] = 8'h29; ram[16'h04bc] = 8'h7d; ram[16'h04bd] = 8'hd0; ram[16'h04be] = 8'hfe; ram[16'h04bf] = 8'ha5; 

ram[16'h04c0] = 8'h0a; ram[16'h04c1] = 8'hcd; ram[16'h04c2] = 8'hff; ram[16'h04c3] = 8'h01; ram[16'h04c4] = 8'hd0; ram[16'h04c5] = 8'hfe; ram[16'h04c6] = 8'ha2; ram[16'h04c7] = 8'hff; 
ram[16'h04c8] = 8'h9a; ram[16'h04c9] = 8'ha9; ram[16'h04ca] = 8'h02; ram[16'h04cb] = 8'h8d; ram[16'h04cc] = 8'h03; ram[16'h04cd] = 8'h02; ram[16'h04ce] = 8'ha9; ram[16'h04cf] = 8'hfb; 
ram[16'h04d0] = 8'h48; ram[16'h04d1] = 8'had; ram[16'h04d2] = 8'hfc; ram[16'h04d3] = 8'hbf; ram[16'h04d4] = 8'h29; ram[16'h04d5] = 8'h7f; ram[16'h04d6] = 8'h09; ram[16'h04d7] = 8'h01; 
ram[16'h04d8] = 8'h28; ram[16'h04d9] = 8'h48; ram[16'h04da] = 8'h08; ram[16'h04db] = 8'h8d; ram[16'h04dc] = 8'hfc; ram[16'h04dd] = 8'hbf; ram[16'h04de] = 8'hea; ram[16'h04df] = 8'hea; 

ram[16'h04e0] = 8'hea; ram[16'h04e1] = 8'had; ram[16'h04e2] = 8'h03; ram[16'h04e3] = 8'h02; ram[16'h04e4] = 8'hd0; ram[16'h04e5] = 8'hfe; ram[16'h04e6] = 8'hba; ram[16'h04e7] = 8'he0; 
ram[16'h04e8] = 8'hfd; ram[16'h04e9] = 8'hd0; ram[16'h04ea] = 8'hfe; ram[16'h04eb] = 8'ha5; ram[16'h04ec] = 8'h0c; ram[16'h04ed] = 8'h4d; ram[16'h04ee] = 8'hfe; ram[16'h04ef] = 8'h01; 
ram[16'h04f0] = 8'h29; ram[16'h04f1] = 8'hcb; ram[16'h04f2] = 8'hd0; ram[16'h04f3] = 8'hfe; ram[16'h04f4] = 8'ha2; ram[16'h04f5] = 8'hff; ram[16'h04f6] = 8'h9a; ram[16'h04f7] = 8'ha9; 
ram[16'h04f8] = 8'h01; ram[16'h04f9] = 8'h8d; ram[16'h04fa] = 8'h03; ram[16'h04fb] = 8'h02; ram[16'h04fc] = 8'ha9; ram[16'h04fd] = 8'h00; ram[16'h04fe] = 8'h48; ram[16'h04ff] = 8'h28; 

ram[16'h0500] = 8'h48; ram[16'h0501] = 8'h08; ram[16'h0502] = 8'h00; ram[16'h0503] = 8'hea; ram[16'h0504] = 8'hea; ram[16'h0505] = 8'hea; ram[16'h0506] = 8'hea; ram[16'h0507] = 8'had; 
ram[16'h0508] = 8'h03; ram[16'h0509] = 8'h02; ram[16'h050a] = 8'hd0; ram[16'h050b] = 8'hfe; ram[16'h050c] = 8'hba; ram[16'h050d] = 8'he0; ram[16'h050e] = 8'hfd; ram[16'h050f] = 8'hd0; 
ram[16'h0510] = 8'hfe; ram[16'h0511] = 8'ha5; ram[16'h0512] = 8'h0c; ram[16'h0513] = 8'h4d; ram[16'h0514] = 8'hfe; ram[16'h0515] = 8'h01; ram[16'h0516] = 8'h29; ram[16'h0517] = 8'hcb; 
ram[16'h0518] = 8'hd0; ram[16'h0519] = 8'hfe; ram[16'h051a] = 8'ha2; ram[16'h051b] = 8'hff; ram[16'h051c] = 8'h9a; ram[16'h051d] = 8'ha2; ram[16'h051e] = 8'h42; ram[16'h051f] = 8'ha0; 

ram[16'h0520] = 8'h52; ram[16'h0521] = 8'ha9; ram[16'h0522] = 8'h01; ram[16'h0523] = 8'h8d; ram[16'h0524] = 8'h03; ram[16'h0525] = 8'h02; ram[16'h0526] = 8'ha9; ram[16'h0527] = 8'h00; 
ram[16'h0528] = 8'h48; ram[16'h0529] = 8'h28; ram[16'h052a] = 8'h48; ram[16'h052b] = 8'h08; ram[16'h052c] = 8'h00; ram[16'h052d] = 8'h88; ram[16'h052e] = 8'h88; ram[16'h052f] = 8'h88; 
ram[16'h0530] = 8'h88; ram[16'h0531] = 8'h88; ram[16'h0532] = 8'h08; ram[16'h0533] = 8'he0; ram[16'h0534] = 8'h43; ram[16'h0535] = 8'hd0; ram[16'h0536] = 8'hfe; ram[16'h0537] = 8'hc0; 
ram[16'h0538] = 8'h4b; ram[16'h0539] = 8'hd0; ram[16'h053a] = 8'hfe; ram[16'h053b] = 8'hc9; ram[16'h053c] = 8'h4b; ram[16'h053d] = 8'hd0; ram[16'h053e] = 8'hfe; ram[16'h053f] = 8'hba; 

ram[16'h0540] = 8'he0; ram[16'h0541] = 8'hfc; ram[16'h0542] = 8'hd0; ram[16'h0543] = 8'hfe; ram[16'h0544] = 8'h68; ram[16'h0545] = 8'h4d; ram[16'h0546] = 8'hfe; ram[16'h0547] = 8'h01; 
ram[16'h0548] = 8'h29; ram[16'h0549] = 8'h7d; ram[16'h054a] = 8'hd0; ram[16'h054b] = 8'hfe; ram[16'h054c] = 8'ha5; ram[16'h054d] = 8'h0a; ram[16'h054e] = 8'hcd; ram[16'h054f] = 8'hff; 
ram[16'h0550] = 8'h01; ram[16'h0551] = 8'hd0; ram[16'h0552] = 8'hfe; ram[16'h0553] = 8'ha2; ram[16'h0554] = 8'hff; ram[16'h0555] = 8'h9a; ram[16'h0556] = 8'ha2; ram[16'h0557] = 8'hbd; 
ram[16'h0558] = 8'ha0; ram[16'h0559] = 8'had; ram[16'h055a] = 8'ha9; ram[16'h055b] = 8'h01; ram[16'h055c] = 8'h8d; ram[16'h055d] = 8'h03; ram[16'h055e] = 8'h02; ram[16'h055f] = 8'ha9; 

ram[16'h0560] = 8'hff; ram[16'h0561] = 8'h48; ram[16'h0562] = 8'h28; ram[16'h0563] = 8'h48; ram[16'h0564] = 8'h08; ram[16'h0565] = 8'h00; ram[16'h0566] = 8'h88; ram[16'h0567] = 8'h88; 
ram[16'h0568] = 8'h88; ram[16'h0569] = 8'h88; ram[16'h056a] = 8'h88; ram[16'h056b] = 8'h08; ram[16'h056c] = 8'he0; ram[16'h056d] = 8'hbe; ram[16'h056e] = 8'hd0; ram[16'h056f] = 8'hfe; 
ram[16'h0570] = 8'hc0; ram[16'h0571] = 8'ha6; ram[16'h0572] = 8'hd0; ram[16'h0573] = 8'hfe; ram[16'h0574] = 8'hc9; ram[16'h0575] = 8'h4b; ram[16'h0576] = 8'hd0; ram[16'h0577] = 8'hfe; 
ram[16'h0578] = 8'hba; ram[16'h0579] = 8'he0; ram[16'h057a] = 8'hfc; ram[16'h057b] = 8'hd0; ram[16'h057c] = 8'hfe; ram[16'h057d] = 8'h68; ram[16'h057e] = 8'h4d; ram[16'h057f] = 8'hfe; 

ram[16'h0580] = 8'h01; ram[16'h0581] = 8'h29; ram[16'h0582] = 8'h7d; ram[16'h0583] = 8'hd0; ram[16'h0584] = 8'hfe; ram[16'h0585] = 8'ha5; ram[16'h0586] = 8'h0a; ram[16'h0587] = 8'hcd; 
ram[16'h0588] = 8'hff; ram[16'h0589] = 8'h01; ram[16'h058a] = 8'hd0; ram[16'h058b] = 8'hfe; ram[16'h058c] = 8'ha2; ram[16'h058d] = 8'hff; ram[16'h058e] = 8'h9a; ram[16'h058f] = 8'ha9; 
ram[16'h0590] = 8'h01; ram[16'h0591] = 8'h8d; ram[16'h0592] = 8'h03; ram[16'h0593] = 8'h02; ram[16'h0594] = 8'ha9; ram[16'h0595] = 8'hff; ram[16'h0596] = 8'h48; ram[16'h0597] = 8'h28; 
ram[16'h0598] = 8'h48; ram[16'h0599] = 8'h08; ram[16'h059a] = 8'h00; ram[16'h059b] = 8'hea; ram[16'h059c] = 8'hea; ram[16'h059d] = 8'hea; ram[16'h059e] = 8'hea; ram[16'h059f] = 8'had; 

ram[16'h05a0] = 8'h03; ram[16'h05a1] = 8'h02; ram[16'h05a2] = 8'hd0; ram[16'h05a3] = 8'hfe; ram[16'h05a4] = 8'hba; ram[16'h05a5] = 8'he0; ram[16'h05a6] = 8'hfd; ram[16'h05a7] = 8'hd0; 
ram[16'h05a8] = 8'hfe; ram[16'h05a9] = 8'ha5; ram[16'h05aa] = 8'h0c; ram[16'h05ab] = 8'h4d; ram[16'h05ac] = 8'hfe; ram[16'h05ad] = 8'h01; ram[16'h05ae] = 8'h29; ram[16'h05af] = 8'hcb; 
ram[16'h05b0] = 8'hd0; ram[16'h05b1] = 8'hfe; ram[16'h05b2] = 8'ha2; ram[16'h05b3] = 8'hff; ram[16'h05b4] = 8'h9a; ram[16'h05b5] = 8'ha9; ram[16'h05b6] = 8'h04; ram[16'h05b7] = 8'h8d; 
ram[16'h05b8] = 8'h03; ram[16'h05b9] = 8'h02; ram[16'h05ba] = 8'ha9; ram[16'h05bb] = 8'h00; ram[16'h05bc] = 8'h48; ram[16'h05bd] = 8'had; ram[16'h05be] = 8'hfc; ram[16'h05bf] = 8'hbf; 

ram[16'h05c0] = 8'h29; ram[16'h05c1] = 8'h7f; ram[16'h05c2] = 8'h09; ram[16'h05c3] = 8'h02; ram[16'h05c4] = 8'h28; ram[16'h05c5] = 8'h48; ram[16'h05c6] = 8'h08; ram[16'h05c7] = 8'h8d; 
ram[16'h05c8] = 8'hfc; ram[16'h05c9] = 8'hbf; ram[16'h05ca] = 8'hea; ram[16'h05cb] = 8'hea; ram[16'h05cc] = 8'hea; ram[16'h05cd] = 8'had; ram[16'h05ce] = 8'h03; ram[16'h05cf] = 8'h02; 
ram[16'h05d0] = 8'hd0; ram[16'h05d1] = 8'hfe; ram[16'h05d2] = 8'hba; ram[16'h05d3] = 8'he0; ram[16'h05d4] = 8'hfd; ram[16'h05d5] = 8'hd0; ram[16'h05d6] = 8'hfe; ram[16'h05d7] = 8'ha5; 
ram[16'h05d8] = 8'h0f; ram[16'h05d9] = 8'h4d; ram[16'h05da] = 8'hfe; ram[16'h05db] = 8'h01; ram[16'h05dc] = 8'h29; ram[16'h05dd] = 8'hcb; ram[16'h05de] = 8'hd0; ram[16'h05df] = 8'hfe; 

ram[16'h05e0] = 8'ha2; ram[16'h05e1] = 8'hff; ram[16'h05e2] = 8'h9a; ram[16'h05e3] = 8'ha2; ram[16'h05e4] = 8'h4e; ram[16'h05e5] = 8'ha0; ram[16'h05e6] = 8'h4d; ram[16'h05e7] = 8'ha9; 
ram[16'h05e8] = 8'h04; ram[16'h05e9] = 8'h8d; ram[16'h05ea] = 8'h03; ram[16'h05eb] = 8'h02; ram[16'h05ec] = 8'ha9; ram[16'h05ed] = 8'h00; ram[16'h05ee] = 8'h48; ram[16'h05ef] = 8'had; 
ram[16'h05f0] = 8'hfc; ram[16'h05f1] = 8'hbf; ram[16'h05f2] = 8'h29; ram[16'h05f3] = 8'h7f; ram[16'h05f4] = 8'h09; ram[16'h05f5] = 8'h02; ram[16'h05f6] = 8'h28; ram[16'h05f7] = 8'h48; 
ram[16'h05f8] = 8'h08; ram[16'h05f9] = 8'h8d; ram[16'h05fa] = 8'hfc; ram[16'h05fb] = 8'hbf; ram[16'h05fc] = 8'h88; ram[16'h05fd] = 8'h88; ram[16'h05fe] = 8'h88; ram[16'h05ff] = 8'h88; 

ram[16'h0600] = 8'h08; ram[16'h0601] = 8'he0; ram[16'h0602] = 8'h4f; ram[16'h0603] = 8'hd0; ram[16'h0604] = 8'hfe; ram[16'h0605] = 8'hc0; ram[16'h0606] = 8'h46; ram[16'h0607] = 8'hd0; 
ram[16'h0608] = 8'hfe; ram[16'h0609] = 8'hc9; ram[16'h060a] = 8'h49; ram[16'h060b] = 8'hd0; ram[16'h060c] = 8'hfe; ram[16'h060d] = 8'hba; ram[16'h060e] = 8'he0; ram[16'h060f] = 8'hfc; 
ram[16'h0610] = 8'hd0; ram[16'h0611] = 8'hfe; ram[16'h0612] = 8'h68; ram[16'h0613] = 8'h4d; ram[16'h0614] = 8'hfe; ram[16'h0615] = 8'h01; ram[16'h0616] = 8'h29; ram[16'h0617] = 8'h7d; 
ram[16'h0618] = 8'hd0; ram[16'h0619] = 8'hfe; ram[16'h061a] = 8'ha5; ram[16'h061b] = 8'h0d; ram[16'h061c] = 8'hcd; ram[16'h061d] = 8'hff; ram[16'h061e] = 8'h01; ram[16'h061f] = 8'hd0; 

ram[16'h0620] = 8'hfe; ram[16'h0621] = 8'ha2; ram[16'h0622] = 8'hff; ram[16'h0623] = 8'h9a; ram[16'h0624] = 8'ha2; ram[16'h0625] = 8'hb1; ram[16'h0626] = 8'ha0; ram[16'h0627] = 8'hb2; 
ram[16'h0628] = 8'ha9; ram[16'h0629] = 8'h04; ram[16'h062a] = 8'h8d; ram[16'h062b] = 8'h03; ram[16'h062c] = 8'h02; ram[16'h062d] = 8'ha9; ram[16'h062e] = 8'hfb; ram[16'h062f] = 8'h48; 
ram[16'h0630] = 8'had; ram[16'h0631] = 8'hfc; ram[16'h0632] = 8'hbf; ram[16'h0633] = 8'h29; ram[16'h0634] = 8'h7f; ram[16'h0635] = 8'h09; ram[16'h0636] = 8'h02; ram[16'h0637] = 8'h28; 
ram[16'h0638] = 8'h48; ram[16'h0639] = 8'h08; ram[16'h063a] = 8'h8d; ram[16'h063b] = 8'hfc; ram[16'h063c] = 8'hbf; ram[16'h063d] = 8'h88; ram[16'h063e] = 8'h88; ram[16'h063f] = 8'h88; 

ram[16'h0640] = 8'h88; ram[16'h0641] = 8'h08; ram[16'h0642] = 8'he0; ram[16'h0643] = 8'hb2; ram[16'h0644] = 8'hd0; ram[16'h0645] = 8'hfe; ram[16'h0646] = 8'hc0; ram[16'h0647] = 8'hab; 
ram[16'h0648] = 8'hd0; ram[16'h0649] = 8'hfe; ram[16'h064a] = 8'hc9; ram[16'h064b] = 8'h49; ram[16'h064c] = 8'hd0; ram[16'h064d] = 8'hfe; ram[16'h064e] = 8'hba; ram[16'h064f] = 8'he0; 
ram[16'h0650] = 8'hfc; ram[16'h0651] = 8'hd0; ram[16'h0652] = 8'hfe; ram[16'h0653] = 8'h68; ram[16'h0654] = 8'h4d; ram[16'h0655] = 8'hfe; ram[16'h0656] = 8'h01; ram[16'h0657] = 8'h29; 
ram[16'h0658] = 8'h7d; ram[16'h0659] = 8'hd0; ram[16'h065a] = 8'hfe; ram[16'h065b] = 8'ha5; ram[16'h065c] = 8'h0d; ram[16'h065d] = 8'hcd; ram[16'h065e] = 8'hff; ram[16'h065f] = 8'h01; 

ram[16'h0660] = 8'hd0; ram[16'h0661] = 8'hfe; ram[16'h0662] = 8'ha2; ram[16'h0663] = 8'hff; ram[16'h0664] = 8'h9a; ram[16'h0665] = 8'ha9; ram[16'h0666] = 8'h04; ram[16'h0667] = 8'h8d; 
ram[16'h0668] = 8'h03; ram[16'h0669] = 8'h02; ram[16'h066a] = 8'ha9; ram[16'h066b] = 8'hfb; ram[16'h066c] = 8'h48; ram[16'h066d] = 8'had; ram[16'h066e] = 8'hfc; ram[16'h066f] = 8'hbf; 
ram[16'h0670] = 8'h29; ram[16'h0671] = 8'h7f; ram[16'h0672] = 8'h09; ram[16'h0673] = 8'h02; ram[16'h0674] = 8'h28; ram[16'h0675] = 8'h48; ram[16'h0676] = 8'h08; ram[16'h0677] = 8'h8d; 
ram[16'h0678] = 8'hfc; ram[16'h0679] = 8'hbf; ram[16'h067a] = 8'hea; ram[16'h067b] = 8'hea; ram[16'h067c] = 8'hea; ram[16'h067d] = 8'had; ram[16'h067e] = 8'h03; ram[16'h067f] = 8'h02; 

ram[16'h0680] = 8'hd0; ram[16'h0681] = 8'hfe; ram[16'h0682] = 8'hba; ram[16'h0683] = 8'he0; ram[16'h0684] = 8'hfd; ram[16'h0685] = 8'hd0; ram[16'h0686] = 8'hfe; ram[16'h0687] = 8'ha5; 
ram[16'h0688] = 8'h0f; ram[16'h0689] = 8'h4d; ram[16'h068a] = 8'hfe; ram[16'h068b] = 8'h01; ram[16'h068c] = 8'h29; ram[16'h068d] = 8'hcb; ram[16'h068e] = 8'hd0; ram[16'h068f] = 8'hfe; 
ram[16'h0690] = 8'ha2; ram[16'h0691] = 8'hff; ram[16'h0692] = 8'h9a; ram[16'h0693] = 8'ha2; ram[16'h0694] = 8'h00; ram[16'h0695] = 8'ha9; ram[16'h0696] = 8'h04; ram[16'h0697] = 8'h8d; 
ram[16'h0698] = 8'h03; ram[16'h0699] = 8'h02; ram[16'h069a] = 8'ha9; ram[16'h069b] = 8'h04; ram[16'h069c] = 8'h48; ram[16'h069d] = 8'had; ram[16'h069e] = 8'hfc; ram[16'h069f] = 8'hbf; 

ram[16'h06a0] = 8'h29; ram[16'h06a1] = 8'h7f; ram[16'h06a2] = 8'h09; ram[16'h06a3] = 8'h03; ram[16'h06a4] = 8'h28; ram[16'h06a5] = 8'h48; ram[16'h06a6] = 8'h08; ram[16'h06a7] = 8'h8d; 
ram[16'h06a8] = 8'hfc; ram[16'h06a9] = 8'hbf; ram[16'h06aa] = 8'he8; ram[16'h06ab] = 8'he8; ram[16'h06ac] = 8'he8; ram[16'h06ad] = 8'had; ram[16'h06ae] = 8'h03; ram[16'h06af] = 8'h02; 
ram[16'h06b0] = 8'hd0; ram[16'h06b1] = 8'hfe; ram[16'h06b2] = 8'ha2; ram[16'h06b3] = 8'h00; ram[16'h06b4] = 8'ha9; ram[16'h06b5] = 8'h02; ram[16'h06b6] = 8'h8d; ram[16'h06b7] = 8'h03; 
ram[16'h06b8] = 8'h02; ram[16'h06b9] = 8'h58; ram[16'h06ba] = 8'he8; ram[16'h06bb] = 8'he8; ram[16'h06bc] = 8'he8; ram[16'h06bd] = 8'had; ram[16'h06be] = 8'h03; ram[16'h06bf] = 8'h02; 

ram[16'h06c0] = 8'hd0; ram[16'h06c1] = 8'hfe; ram[16'h06c2] = 8'ha2; ram[16'h06c3] = 8'hff; ram[16'h06c4] = 8'h9a; ram[16'h06c5] = 8'ha2; ram[16'h06c6] = 8'h00; ram[16'h06c7] = 8'ha9; 
ram[16'h06c8] = 8'h07; ram[16'h06c9] = 8'h8d; ram[16'h06ca] = 8'h03; ram[16'h06cb] = 8'h02; ram[16'h06cc] = 8'ha9; ram[16'h06cd] = 8'hff; ram[16'h06ce] = 8'h8d; ram[16'h06cf] = 8'h00; 
ram[16'h06d0] = 8'h02; ram[16'h06d1] = 8'h8d; ram[16'h06d2] = 8'h01; ram[16'h06d3] = 8'h02; ram[16'h06d4] = 8'h8d; ram[16'h06d5] = 8'h02; ram[16'h06d6] = 8'h02; ram[16'h06d7] = 8'ha9; 
ram[16'h06d8] = 8'h00; ram[16'h06d9] = 8'h48; ram[16'h06da] = 8'had; ram[16'h06db] = 8'hfc; ram[16'h06dc] = 8'hbf; ram[16'h06dd] = 8'h29; ram[16'h06de] = 8'h7f; ram[16'h06df] = 8'h09; 

ram[16'h06e0] = 8'h03; ram[16'h06e1] = 8'h28; ram[16'h06e2] = 8'h48; ram[16'h06e3] = 8'h08; ram[16'h06e4] = 8'h8d; ram[16'h06e5] = 8'hfc; ram[16'h06e6] = 8'hbf; ram[16'h06e7] = 8'h00; 
ram[16'h06e8] = 8'he8; ram[16'h06e9] = 8'he8; ram[16'h06ea] = 8'he8; ram[16'h06eb] = 8'he8; ram[16'h06ec] = 8'he8; ram[16'h06ed] = 8'he8; ram[16'h06ee] = 8'he8; ram[16'h06ef] = 8'he8; 
ram[16'h06f0] = 8'had; ram[16'h06f1] = 8'h03; ram[16'h06f2] = 8'h02; ram[16'h06f3] = 8'hd0; ram[16'h06f4] = 8'hfe; ram[16'h06f5] = 8'h4c; ram[16'h06f6] = 8'hf5; ram[16'h06f7] = 8'h06; 
ram[16'h06f8] = 8'h4c; ram[16'h06f9] = 8'h00; ram[16'h06fa] = 8'h04; ram[16'h06fb] = 8'ha2; ram[16'h06fc] = 8'hff; ram[16'h06fd] = 8'h9a; ram[16'h06fe] = 8'ha0; ram[16'h06ff] = 8'h03; 

ram[16'h0700] = 8'ha9; ram[16'h0701] = 8'h00; ram[16'h0702] = 8'h8d; ram[16'h0703] = 8'h03; ram[16'h0704] = 8'h02; ram[16'h0705] = 8'ha9; ram[16'h0706] = 8'h04; ram[16'h0707] = 8'h48; 
ram[16'h0708] = 8'h28; ram[16'h0709] = 8'hcb; ram[16'h070a] = 8'h88; ram[16'h070b] = 8'h88; ram[16'h070c] = 8'h88; ram[16'h070d] = 8'hd0; ram[16'h070e] = 8'hfe; ram[16'h070f] = 8'h4c; 
ram[16'h0710] = 8'h0f; ram[16'h0711] = 8'h07; ram[16'h0712] = 8'ha2; ram[16'h0713] = 8'hff; ram[16'h0714] = 8'h9a; ram[16'h0715] = 8'ha0; ram[16'h0716] = 8'h07; ram[16'h0717] = 8'ha9; 
ram[16'h0718] = 8'h02; ram[16'h0719] = 8'h8d; ram[16'h071a] = 8'h03; ram[16'h071b] = 8'h02; ram[16'h071c] = 8'ha9; ram[16'h071d] = 8'h00; ram[16'h071e] = 8'h48; ram[16'h071f] = 8'h28; 

ram[16'h0720] = 8'hcb; ram[16'h0721] = 8'h88; ram[16'h0722] = 8'h88; ram[16'h0723] = 8'h88; ram[16'h0724] = 8'had; ram[16'h0725] = 8'h03; ram[16'h0726] = 8'h02; ram[16'h0727] = 8'hd0; 
ram[16'h0728] = 8'hfe; ram[16'h0729] = 8'h88; ram[16'h072a] = 8'hd0; ram[16'h072b] = 8'hfe; ram[16'h072c] = 8'h4c; ram[16'h072d] = 8'h2c; ram[16'h072e] = 8'h07; ram[16'h072f] = 8'hea; 
ram[16'h0730] = 8'hea; ram[16'h0731] = 8'hdb; ram[16'h0732] = 8'hea; ram[16'h0733] = 8'hea; ram[16'h0734] = 8'h4c; ram[16'h0735] = 8'h34; ram[16'h0736] = 8'h07; ram[16'h0737] = 8'h88; 
ram[16'h0738] = 8'h88; ram[16'h0739] = 8'h08; ram[16'h073a] = 8'h88; ram[16'h073b] = 8'h88; ram[16'h073c] = 8'h88; ram[16'h073d] = 8'h85; ram[16'h073e] = 8'h0d; ram[16'h073f] = 8'h86; 

ram[16'h0740] = 8'h0e; ram[16'h0741] = 8'h68; ram[16'h0742] = 8'h48; ram[16'h0743] = 8'h85; ram[16'h0744] = 8'h0f; ram[16'h0745] = 8'had; ram[16'h0746] = 8'h03; ram[16'h0747] = 8'h02; 
ram[16'h0748] = 8'h29; ram[16'h0749] = 8'h04; ram[16'h074a] = 8'hf0; ram[16'h074b] = 8'hfe; ram[16'h074c] = 8'h68; ram[16'h074d] = 8'h48; ram[16'h074e] = 8'h29; ram[16'h074f] = 8'h04; 
ram[16'h0750] = 8'hf0; ram[16'h0751] = 8'hfe; ram[16'h0752] = 8'h68; ram[16'h0753] = 8'h49; ram[16'h0754] = 8'hc3; ram[16'h0755] = 8'h48; ram[16'h0756] = 8'hba; ram[16'h0757] = 8'hbd; 
ram[16'h0758] = 8'h02; ram[16'h0759] = 8'h01; ram[16'h075a] = 8'h29; ram[16'h075b] = 8'h10; ram[16'h075c] = 8'hd0; ram[16'h075d] = 8'hfe; ram[16'h075e] = 8'had; ram[16'h075f] = 8'h03; 

ram[16'h0760] = 8'h02; ram[16'h0761] = 8'h29; ram[16'h0762] = 8'hfb; ram[16'h0763] = 8'h8d; ram[16'h0764] = 8'h03; ram[16'h0765] = 8'h02; ram[16'h0766] = 8'had; ram[16'h0767] = 8'hfc; 
ram[16'h0768] = 8'hbf; ram[16'h0769] = 8'h29; ram[16'h076a] = 8'h7d; ram[16'h076b] = 8'h8d; ram[16'h076c] = 8'hfc; ram[16'h076d] = 8'hbf; ram[16'h076e] = 8'ha6; ram[16'h076f] = 8'h0e; 
ram[16'h0770] = 8'he8; ram[16'h0771] = 8'h8e; ram[16'h0772] = 8'h00; ram[16'h0773] = 8'h02; ram[16'h0774] = 8'ha9; ram[16'h0775] = 8'h49; ram[16'h0776] = 8'h28; ram[16'h0777] = 8'h40; 
ram[16'h0778] = 8'h4c; ram[16'h0779] = 8'h78; ram[16'h077a] = 8'h07; ram[16'h077b] = 8'h88; ram[16'h077c] = 8'h88; ram[16'h077d] = 8'h08; ram[16'h077e] = 8'h88; ram[16'h077f] = 8'h88; 

ram[16'h0780] = 8'h88; ram[16'h0781] = 8'h85; ram[16'h0782] = 8'h0a; ram[16'h0783] = 8'h86; ram[16'h0784] = 8'h0b; ram[16'h0785] = 8'h68; ram[16'h0786] = 8'h48; ram[16'h0787] = 8'h85; 
ram[16'h0788] = 8'h0c; ram[16'h0789] = 8'had; ram[16'h078a] = 8'h03; ram[16'h078b] = 8'h02; ram[16'h078c] = 8'h29; ram[16'h078d] = 8'h03; ram[16'h078e] = 8'hf0; ram[16'h078f] = 8'hfe; 
ram[16'h0790] = 8'h68; ram[16'h0791] = 8'h48; ram[16'h0792] = 8'h29; ram[16'h0793] = 8'h04; ram[16'h0794] = 8'hf0; ram[16'h0795] = 8'hfe; ram[16'h0796] = 8'h68; ram[16'h0797] = 8'h49; 
ram[16'h0798] = 8'hc3; ram[16'h0799] = 8'h48; ram[16'h079a] = 8'hba; ram[16'h079b] = 8'hbd; ram[16'h079c] = 8'h02; ram[16'h079d] = 8'h01; ram[16'h079e] = 8'h29; ram[16'h079f] = 8'h10; 

ram[16'h07a0] = 8'hd0; ram[16'h07a1] = 8'h21; ram[16'h07a2] = 8'had; ram[16'h07a3] = 8'h03; ram[16'h07a4] = 8'h02; ram[16'h07a5] = 8'h29; ram[16'h07a6] = 8'h02; ram[16'h07a7] = 8'hf0; 
ram[16'h07a8] = 8'hfe; ram[16'h07a9] = 8'had; ram[16'h07aa] = 8'h03; ram[16'h07ab] = 8'h02; ram[16'h07ac] = 8'h29; ram[16'h07ad] = 8'hfd; ram[16'h07ae] = 8'h8d; ram[16'h07af] = 8'h03; 
ram[16'h07b0] = 8'h02; ram[16'h07b1] = 8'had; ram[16'h07b2] = 8'hfc; ram[16'h07b3] = 8'hbf; ram[16'h07b4] = 8'h29; ram[16'h07b5] = 8'h7e; ram[16'h07b6] = 8'h8d; ram[16'h07b7] = 8'hfc; 
ram[16'h07b8] = 8'hbf; ram[16'h07b9] = 8'ha6; ram[16'h07ba] = 8'h0b; ram[16'h07bb] = 8'he8; ram[16'h07bc] = 8'h8e; ram[16'h07bd] = 8'h01; ram[16'h07be] = 8'h02; ram[16'h07bf] = 8'ha9; 

ram[16'h07c0] = 8'h51; ram[16'h07c1] = 8'h28; ram[16'h07c2] = 8'h40; ram[16'h07c3] = 8'had; ram[16'h07c4] = 8'h03; ram[16'h07c5] = 8'h02; ram[16'h07c6] = 8'h29; ram[16'h07c7] = 8'h01; 
ram[16'h07c8] = 8'hf0; ram[16'h07c9] = 8'hfe; ram[16'h07ca] = 8'had; ram[16'h07cb] = 8'h03; ram[16'h07cc] = 8'h02; ram[16'h07cd] = 8'h29; ram[16'h07ce] = 8'hfe; ram[16'h07cf] = 8'h8d; 
ram[16'h07d0] = 8'h03; ram[16'h07d1] = 8'h02; ram[16'h07d2] = 8'ha6; ram[16'h07d3] = 8'h0b; ram[16'h07d4] = 8'he8; ram[16'h07d5] = 8'h8e; ram[16'h07d6] = 8'h02; ram[16'h07d7] = 8'h02; 
ram[16'h07d8] = 8'ha5; ram[16'h07d9] = 8'h0a; ram[16'h07da] = 8'ha9; ram[16'h07db] = 8'h4b; ram[16'h07dc] = 8'h28; ram[16'h07dd] = 8'h40; 
ram[16'hfffa] = 8'h39; ram[16'hfffb] = 8'h07; ram[16'hfffc] = 8'h78; ram[16'hfffd] = 8'h07; ram[16'hfffe] = 8'h7d; ram[16'hffff] = 8'h07; 
 // Override start vector
ram[16'hfffc] = 8'h00;
ram[16'hfffd] = 8'h04;
end

always @(posedge clk)
begin
    if(we)
        ram[addr_w] = di;
    if(we && addr_w == 16'h0200)
        $display("last test: %d",di);
    do = ram[addr_r];
end

endmodule
