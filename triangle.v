`timescale 1ps/1ps

module triangle(input clk, input[7:0] r4008, input[7:0] r4009, input[7:0] r400a, input[7:0] r400b, output[3:0] vol);
    // constants and tables
    // If bit 5 == 0, use ltable 0
    reg[8:0] ltable0[15:0];
    // else use ltable 1
    reg[8:0] ltable1[15:0];
    // period table
    reg[11:0] ptable[15:0];
    initial begin
        shift = 1;
        ltable0[0] = 8'h0a;
        ltable0[1] = 8'h14;
        ltable0[2] = 8'h28;
        ltable0[3] = 8'h50;
        ltable0[4] = 8'ha0;
        ltable0[5] = 8'h3c;
        ltable0[6] = 8'h0e;
        ltable0[7] = 8'h1a;
        ltable0[8] = 8'h0c;
        ltable0[9] = 8'h18;
        ltable0[10] = 8'h30;
        ltable0[11] = 8'h60;
        ltable0[12] = 8'hc0;
        ltable0[13] = 8'h48;
        ltable0[14] = 8'h10;
        ltable0[15] = 8'h20;
        ltable1[0] = 8'hfe;
        ltable1[1] = 8'h02;
        ltable1[2] = 8'h04;
        ltable1[3] = 8'h06;
        ltable1[4] = 8'h08;
        ltable1[5] = 8'h0a;
        ltable1[6] = 8'h0c;
        ltable1[7] = 8'h0e;
        ltable1[8] = 8'h10;
        ltable1[9] = 8'h12;
        ltable1[10] = 8'h14;
        ltable1[11] = 8'h16;
        ltable1[12] = 8'h18;
        ltable1[13] = 8'h1a;
        ltable1[14] = 8'h1c;
        ltable1[15] = 8'h1e;
        ptable[0] = 12'h004;
        ptable[1] = 12'h008;
        ptable[2] = 12'h010;
        ptable[3] = 12'h020;
        ptable[4] = 12'h040;
        ptable[5] = 12'h060;
        ptable[6] = 12'h080;
        ptable[7] = 12'h0a0;
        ptable[8] = 12'h0ca;
        ptable[9] = 12'h0fe;
        ptable[10] = 12'h17c;
        ptable[11] = 12'h1fc;
        ptable[12] = 12'h2fa;
        ptable[13] = 12'h3f8;
        ptable[14] = 12'h7f2;
        ptable[15] = 12'hfe4;
        shift = ptable[0];
    end
    // Register fields
	 wire[6:0] lc = r4008[6:0];
	 wire      ldisable = r4008[7];
	 
	 wire[7:0] unused = r4009[7:0];
	 
	 wire[10:0] wavelength;
	 assign wavelength[7:0] = r400a[7:0];
	 assign wavelength[10:8] = r400b[2:0];
	 
	 wire[4:0] lclr = r400b[7:3];
	 
    wire hlt = 0;

    // 15-bit shift register
    reg[14:0] shift;
    reg[7:0]  counter;
    reg[3:0]  out = 0;
    assign vol = out;
	 reg[3:0]  stepgen = 0;
	 reg[11:0] ptimer = 0;
	 reg		  inc = 1;
    always@(posedge clk) begin
	     ptimer <= ptimer == 0 ? wavelength : ptimer - 1;
		  inc = out == 0 ? 1 :
			     out == 4'hf ? 0 : inc;
		  out <= ptimer != 0 ? out :
					inc ? out + 1 : out - 1;
    end
endmodule