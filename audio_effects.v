module audio_effects (
    input  clk,
    input  sample_end,
    input  sample_req,
    output [15:0] audio_output,
    input  [15:0] audio_input,
    input  [3:0]  control,
	 output   status
);

reg [15:0] romdata [0:99];
reg [6:0]  index = 7'd0;
reg [15:0] last_sample;
reg [15:0] dat;

assign audio_output = dat;

noise nc0(clk,8'b00000001,8'b00000101,0,noise_inter);
square sc0(clk,8'b10000100, 8'b01100000, 0, 0, sq1_inter);
square sc1(clk,8'b10000100, 8'b01100000, 0, 0, sq2_inter);
triangle tc0(clk, 0, 0, 8'b11111111, 8'b00000011, tr_inter);

lengthCounter nl0(clk, r400c[5], r400f[7:3], r4015[3], r4015_out[3], noise_inter, noise_out);
lengthCounter sl0(clk, r4000[5], r4003[7:3], r4015[0], r4015_out[0], sq1_inter, sq1_out);
lengthCounter sl1(clk, r4004[5], r4007[7:3], r4015[1], r4015_out[1], sq2_inter, sq2_out);
lengthCounter tl0(clk, r4008[7], r400b[7:3], r4015[2], r4015_out[2], tr_inter, tr_out);

parameter SINE     = 0;
parameter FEEDBACK = 1;

wire [3:0] sq1_inter;
wire [3:0] sq2_inter;
wire [3:0] noise_inter;
wire [3:0] tr_inter;

wire [3:0] sq1_out;
wire [3:0] sq2_out;

wire [6:0] dmc_out;
wire [3:0] tr_out;
wire [3:0] noise_out;

reg[15:0] sq_tbl[30:0];
reg[15:0] tnd_tbl[202:0];

// DMC Control registers
reg[7:0] r4000;
reg[7:0] r4001;
reg[7:0] r4002;
reg[7:0] r4003;
reg[7:0] r4004;
reg[7:0] r4005;
reg[7:0] r4006;
reg[7:0] r4007;
reg[7:0] r4008;
reg[7:0] r4009;
reg[7:0] r400a;
reg[7:0] r400b;
reg[7:0] r400c;
reg[7:0] r400d;
reg[7:0] r400e;
reg[7:0] r400f;

// LengthCounter control/output
reg[7:0] r4015;
wire[7:0] r4015_out;

// DMC control register fields

wire[3:0]  sq1_vol    = r4000[3:0];
wire[3:0]  sq2_vol    = r4004[3:0];
wire[3:0]  noise_vol  = r400c[3:0];
// Square 1 length counter disable
wire       sq1_lden   = r4000[4];
wire       sq2_lden   = r4004[4];
wire       noise_lden = r400c[4];

wire[1:0]  sq1_dtype  = r4000[7:6];
wire[1:0]  sq2_dtype  = r4004[7:6];

wire[2:0]  sq1_rshift = r4001[2:0];
wire[2:0]  sq2_rshift = r4005[2:0];
wire[2:0]  sq1_swen   = r4001[6:4];
wire[2:0]  sq2_swen   = r4005[6:4];

wire[10:0] sq1_wavelength;
wire[10:0] sq2_wavelength;
wire[10:0] tri_wavelength;

assign sq1_wavelength[7:0]  = r4002;
assign sq1_wavelength[10:8] = r4003[2:0];
assign sq2_wavelength[7:0]  = r4006;
assign sq2_wavelength[10:8] = r4007[2:0];
assign tri_wavelength[7:0]  = r400a;
assign tri_wavelength[10:8] = r400b[2:0];

wire[3:0] noise_pindex  = r400e[3:0];
wire      noise_rngtype = r400e[7];

wire[5:0] sq1_lcount    = r4003[7:3];
wire[5:0] sq2_lcount    = r4007[7:3];
wire[5:0] tri_lcount    = r400b[7:3];
wire[5:0] noise_lcount  = r400f[7:3];

initial begin
	sq_tbl[0] = 0;
	sq_tbl[1] = 196;
	sq_tbl[2] = 388;
	sq_tbl[3] = 575;
	sq_tbl[4] = 757;
	sq_tbl[5] = 936;
	sq_tbl[6] = 1110;
	sq_tbl[7] = 1280;
	sq_tbl[8] = 1446;
	sq_tbl[9] = 1609;
	sq_tbl[10] = 1770;
	sq_tbl[11] = 1926;
	sq_tbl[12] = 2077;
	sq_tbl[13] = 2226;
	sq_tbl[14] = 2374;
	sq_tbl[15] = 2518;
	sq_tbl[16] = 2655;
	sq_tbl[17] = 2792;
	sq_tbl[18] = 2929;
	sq_tbl[19] = 3063;
	sq_tbl[20] = 3190;
	sq_tbl[21] = 3314;
	sq_tbl[22] = 3441;
	sq_tbl[23] = 3563;
	sq_tbl[24] = 3685;
	sq_tbl[25] = 3798;
	sq_tbl[26] = 3918;
	sq_tbl[27] = 4025;
	sq_tbl[28] = 4139;
	sq_tbl[29] = 4247;
	sq_tbl[30] = 4362;
	
	tnd_tbl[0] = 0;
	tnd_tbl[1] = 331;
	tnd_tbl[2] = 660;
	tnd_tbl[3] = 986;
	tnd_tbl[4] = 1309;
	tnd_tbl[5] = 1629;
	tnd_tbl[6] = 1947;
	tnd_tbl[7] = 2262;
	tnd_tbl[8] = 2575;
	tnd_tbl[9] = 2884;
	tnd_tbl[10] = 3192;
	tnd_tbl[11] = 3497;
	tnd_tbl[12] = 3799;
	tnd_tbl[13] = 4099;
	tnd_tbl[14] = 4396;
	tnd_tbl[15] = 4691;
	tnd_tbl[16] = 4984;
	tnd_tbl[17] = 5274;
	tnd_tbl[18] = 5562;
	tnd_tbl[19] = 5848;
	tnd_tbl[20] = 6131;
	tnd_tbl[21] = 6413;
	tnd_tbl[22] = 6692;
	tnd_tbl[23] = 6969;
	tnd_tbl[24] = 7243;
	tnd_tbl[25] = 7516;
	tnd_tbl[26] = 7786;
	tnd_tbl[27] = 8055;
	tnd_tbl[28] = 8321;
	tnd_tbl[29] = 8585;
	tnd_tbl[30] = 8848;
	tnd_tbl[31] = 9108;
	tnd_tbl[32] = 9366;
	tnd_tbl[33] = 9623;
	tnd_tbl[34] = 9877;
	tnd_tbl[35] = 10130;
	tnd_tbl[36] = 10381;
	tnd_tbl[37] = 10630;
	tnd_tbl[38] = 10877;
	tnd_tbl[39] = 11122;
	tnd_tbl[40] = 11365;
	tnd_tbl[41] = 11607;
	tnd_tbl[42] = 11847;
	tnd_tbl[43] = 12085;
	tnd_tbl[44] = 12322;
	tnd_tbl[45] = 12556;
	tnd_tbl[46] = 12789;
	tnd_tbl[47] = 13021;
	tnd_tbl[48] = 13251;
	tnd_tbl[49] = 13479;
	tnd_tbl[50] = 13705;
	tnd_tbl[51] = 13930;
	tnd_tbl[52] = 14154;
	tnd_tbl[53] = 14375;
	tnd_tbl[54] = 14596;
	tnd_tbl[55] = 14814;
	tnd_tbl[56] = 15031;
	tnd_tbl[57] = 15247;
	tnd_tbl[58] = 15461;
	tnd_tbl[59] = 15674;
	tnd_tbl[60] = 15886;
	tnd_tbl[61] = 16095;
	tnd_tbl[62] = 16304;
	tnd_tbl[63] = 16511;
	tnd_tbl[64] = 16717;
	tnd_tbl[65] = 16921;
	tnd_tbl[66] = 17124;
	tnd_tbl[67] = 17325;
	tnd_tbl[68] = 17526;
	tnd_tbl[69] = 17724;
	tnd_tbl[70] = 17922;
	tnd_tbl[71] = 18118;
	tnd_tbl[72] = 18313;
	tnd_tbl[73] = 18507;
	tnd_tbl[74] = 18700;
	tnd_tbl[75] = 18891;
	tnd_tbl[76] = 19081;
	tnd_tbl[77] = 19270;
	tnd_tbl[78] = 19457;
	tnd_tbl[79] = 19643;
	tnd_tbl[80] = 19829;
	tnd_tbl[81] = 20013;
	tnd_tbl[82] = 20195;
	tnd_tbl[83] = 20377;
	tnd_tbl[84] = 20558;
	tnd_tbl[85] = 20737;
	tnd_tbl[86] = 20915;
	tnd_tbl[87] = 21092;
	tnd_tbl[88] = 21268;
	tnd_tbl[89] = 21443;
	tnd_tbl[90] = 21617;
	tnd_tbl[91] = 21790;
	tnd_tbl[92] = 21962;
	tnd_tbl[93] = 22132;
	tnd_tbl[94] = 22302;
	tnd_tbl[95] = 22471;
	tnd_tbl[96] = 22638;
	tnd_tbl[97] = 22805;
	tnd_tbl[98] = 22970;
	tnd_tbl[99] = 23135;
	tnd_tbl[100] = 23298;
	tnd_tbl[101] = 23461;
	tnd_tbl[102] = 23623;
	tnd_tbl[103] = 23783;
	tnd_tbl[104] = 23943;
	tnd_tbl[105] = 24102;
	tnd_tbl[106] = 24260;
	tnd_tbl[107] = 24416;
	tnd_tbl[108] = 24572;
	tnd_tbl[109] = 24728;
	tnd_tbl[110] = 24882;
	tnd_tbl[111] = 25035;
	tnd_tbl[112] = 25187;
	tnd_tbl[113] = 25339;
	tnd_tbl[114] = 25489;
	tnd_tbl[115] = 25639;
	tnd_tbl[116] = 25788;
	tnd_tbl[117] = 25936;
	tnd_tbl[118] = 26083;
	tnd_tbl[119] = 26230;
	tnd_tbl[120] = 26375;
	tnd_tbl[121] = 26520;
	tnd_tbl[122] = 26664;
	tnd_tbl[123] = 26807;
	tnd_tbl[124] = 26949;
	tnd_tbl[125] = 27091;
	tnd_tbl[126] = 27232;
	tnd_tbl[127] = 27372;
	tnd_tbl[128] = 27511;
	tnd_tbl[129] = 27649;
	tnd_tbl[130] = 27787;
	tnd_tbl[131] = 27924;
	tnd_tbl[132] = 28060;
	tnd_tbl[133] = 28195;
	tnd_tbl[134] = 28330;
	tnd_tbl[135] = 28464;
	tnd_tbl[136] = 28597;
	tnd_tbl[137] = 28729;
	tnd_tbl[138] = 28861;
	tnd_tbl[139] = 28992;
	tnd_tbl[140] = 29123;
	tnd_tbl[141] = 29252;
	tnd_tbl[142] = 29381;
	tnd_tbl[143] = 29509;
	tnd_tbl[144] = 29637;
	tnd_tbl[145] = 29764;
	tnd_tbl[146] = 29890;
	tnd_tbl[147] = 30016;
	tnd_tbl[148] = 30141;
	tnd_tbl[149] = 30265;
	tnd_tbl[150] = 30389;
	tnd_tbl[151] = 30512;
	tnd_tbl[152] = 30634;
	tnd_tbl[153] = 30756;
	tnd_tbl[154] = 30877;
	tnd_tbl[155] = 30997;
	tnd_tbl[156] = 31117;
	tnd_tbl[157] = 31236;
	tnd_tbl[158] = 31355;
	tnd_tbl[159] = 31473;
	tnd_tbl[160] = 31590;
	tnd_tbl[161] = 31707;
	tnd_tbl[162] = 31823;
	tnd_tbl[163] = 31939;
	tnd_tbl[164] = 32054;
	tnd_tbl[165] = 32169;
	tnd_tbl[166] = 32283;
	tnd_tbl[167] = 32396;
	tnd_tbl[168] = 32509;
	tnd_tbl[169] = 32621;
	tnd_tbl[170] = 32733;
	tnd_tbl[171] = 32844;
	tnd_tbl[172] = 32954;
	tnd_tbl[173] = 33064;
	tnd_tbl[174] = 33174;
	tnd_tbl[175] = 33283;
	tnd_tbl[176] = 33391;
	tnd_tbl[177] = 33499;
	tnd_tbl[178] = 33606;
	tnd_tbl[179] = 33713;
	tnd_tbl[180] = 33819;
	tnd_tbl[181] = 33925;
	tnd_tbl[182] = 34031;
	tnd_tbl[183] = 34135;
	tnd_tbl[184] = 34240;
	tnd_tbl[185] = 34343;
	tnd_tbl[186] = 34447;
	tnd_tbl[187] = 34549;
	tnd_tbl[188] = 34652;
	tnd_tbl[189] = 34754;
	tnd_tbl[190] = 34855;
	tnd_tbl[191] = 34956;
	tnd_tbl[192] = 35056;
	tnd_tbl[193] = 35156;
	tnd_tbl[194] = 35256;
	tnd_tbl[195] = 35355;
	tnd_tbl[196] = 35453;
	tnd_tbl[197] = 35551;
	tnd_tbl[198] = 35649;
	tnd_tbl[199] = 35746;
	tnd_tbl[200] = 35843;
	tnd_tbl[201] = 35939;
	tnd_tbl[202] = 36035;

end

reg statusreg;
//assign status = r4015_out[2];
assign status = onL;
wire counter_clk2;
	//divider d2(clk, 833333, counter_clk2);
	divider d2(clk, 29834, counter_clk2);
	
	reg[15:0] newclk = 0;
	reg[15:0] cnt = 0;
	reg lReg = 0;
	wire onL = lReg;
	always @(posedge counter_clk2) begin
		if(cnt >= 60) begin
			cnt <= 0;
			lReg <= !lReg;
		end
		else begin
			cnt <= cnt + 1;
		end
	end


always @(posedge clk) begin
	 statusreg <= tr_out > 0;
	 if (sample_end) begin
        last_sample <= audio_input;
    end
	 if(control[0]) begin
		dat <= sq_tbl[sq1_out + sq2_out] + tnd_tbl[3 * tr_out + 2 * noise_out + dmc_out];
	 end
	 if(control[1]) begin
		  r400c[5] <= 1;
		  r4000[5] <= 1;
		  r4004[5] <= 1;
		  r4008[7] <= 1;
	 end
    else if(control[2]) begin
		  r4015[3:0] <= 4'b1111;
		  r400c[5] <= 0;
		  r4000[5] <= 0;
		  r4004[5] <= 0;
		  r4008[7] <= 0;
		  r4003[4:0] <= 5'b01111;
		  r4007[4:0] <= 5'b00011;
		  r400b[4:0] <= 5'b00001;
		  r400f[4:0] <= 5'b01111;
    end
	 if(control[3]) begin
		  r4003[4:0] <= 5'b00111;
		  r4007[4:0] <= 5'b01011;
		  r400b[4:0] <= 5'b01001;
		  r400f[4:0] <= 5'b00111;
	 end
end

endmodule

module lengthCounter (
	input clk,
	input clock_disable, 
	input[4:0] length, 
	input r4015_in, 
	output r4015_out,
	input[3:0] soundIn,
	output[3:0] soundOut
);
	assign soundOut = ~r4015_in || (~clock_disable && time_left == 0) ? 0 : soundIn;
	assign r4015_out = time_left != 0;
	reg[4:0] last_length = 0;
	reg[6:0] time_left;
	
	wire[6:0] real_length = 
		length == 5'h1f ? 30 :
		length == 5'h1d ? 28 :
		length == 5'h1b ? 26 :
		length == 5'h19 ? 24 :
		length == 5'h17 ? 22 :
		length == 5'h15 ? 20 :
		length == 5'h13 ? 18 :
		length == 5'h11 ? 16 :
		length == 5'h0f ? 14 :
		length == 5'h0d ? 12 :
		length == 5'h0b ? 10 :
		length == 5'h09 ? 8 :
		length == 5'h07 ? 6 :
		length == 5'h05 ? 4 :
		length == 5'h03 ? 2 :
		length == 5'h01 ? 254 :
		length == 5'h1e ? 32 :
		length == 5'h1c ? 16 :
		length == 5'h1a ? 72 :
		length == 5'h18 ? 192 :
		length == 5'h16 ? 96 :
		length == 5'h14 ? 48 :
		length == 5'h12 ? 24 :
		length == 5'h10 ? 12 :
		length == 5'h0e ? 26 :
		length == 5'h0c ? 14 :
		length == 5'h0a ? 60 :
		length == 5'h08 ? 160 :
		length == 5'h06 ? 80 :
		length == 5'h04 ? 40 :
		length == 5'h02 ? 20 :
		length == 5'h00 ? 10 :
		0;
		
		
	
	wire counter_clk;
	divider d(clk, 29834, counter_clk);
	
	reg[15:0] newclk = 0;
	always @(posedge counter_clk) begin
		if (~r4015_in) begin
			time_left <= 0;
			last_length <= 0;
		end
		else if (length != last_length) begin
			time_left <= real_length;
			last_length <= length;
		end 
		else if (~clock_disable) begin
			if (time_left != 0) begin
				time_left <= time_left - 1;
			end
		end
	end
endmodule