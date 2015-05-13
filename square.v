`timescale 1ps/1ps

module square(input clk, input[7:0] r4000, input[7:0] r4001, input[7:0] r4002_input, input[7:0] r4003_input, output[3:0] vol);
    // constants and tables
    // If bit 5 == 0, use ltable 0
	 reg[7:0] r4002;
	 reg[7:0] r4003;
	 
    reg[8:0] ltable0[15:0];
    // else use ltable 1
    reg[8:0] ltable1[15:0];
    // period table
    reg[11:0] ptable[15:0];
    // Duty table
    reg[1:0] dtable[3:0];
    initial begin
        dtable[0] = 4'h02;
        dtable[1] = 4'h04;
        dtable[2] = 4'h08;
        dtable[3] = 4'h0c;
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
    end
    // Register fields
    // loop env + disable length (halt)
    wire[3:0]   rvol = r4000[3:0];
    wire        env_disable = r4000[4];
    wire        len_disable = r4000[5];
    wire[1:0]   dtype = r4000[7:6];

    wire[2:0]   rs = r4001[2:0];
    wire        dec_wavelength = r4001[3];
    wire[2:0]   pindex = r4001[6:4];
    wire        swen = r4001[7];

    wire[10:0]   wavelength;
    assign wavelength[7:0] = r4002;
    assign wavelength[10:8] = r4003[2:0];
    wire[4:0]   lreg = r4003[7:3];

	 // For sweeping
	 // TODO: subtract one from the decrement side in square channel 1
	 wire[10:0] newWavelength = ~swen ? wavelength :
										dec_wavelength ? wavelength - wavelength >> rs :
										wavelength + wavelength >> rs;
	 wire sweepClk;
	 divider d(clk, 14920 * (1 + pindex), sweepClk);
    // Duty Cycle Generator counter
    reg[3:0]  duty_counter = 0;
    reg[3:0]  out = 0;
    reg[11:0] ptimer = 0;
    wire hlt = 0;
    assign vol = out;
    reg c;
    always@(posedge clk) begin
        ptimer <= ptimer == 0 ? ptable[pindex] : ptimer - 1;
        if(ptimer == 0) begin
            duty_counter <= duty_counter + 1;
        end
		  if(ptimer != 0) begin
		  end
        else if(duty_counter < dtable[dtype] + 1) begin
            out <= rvol;
        end
        else begin
            out <= 0;
        end
    end
	 
	 always @(r4002_input) begin
		r4002 <= r4002_input;
	 end
	 
	 always @(r4003_input) begin
		r4003 <= r4003_input;
	 end
	 
	 // Sweep unit
	 // Oustide world won't see changes?
	 // Not sure if problem
	 always @(sweepClk) begin 
		r4002 <= newWavelength[7:0];
		r4003[2:0] <= newWavelength[10:8];
	 end
	 

endmodule
