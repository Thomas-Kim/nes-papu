module audio_effects (
    input  clk,
    input  sample_end,
    input  sample_req,
    output [15:0] audio_output,
    input  [15:0] audio_input,
    input  [3:0]  control
);

reg [15:0] romdata [0:99];
reg [6:0]  index = 7'd0;
reg [15:0] last_sample;
reg [15:0] dat;

assign audio_output = dat;

wire noise_en;
noise nc0(clk,0,0,0,noise_en);
wire [3:0]square_vol;
square sc0(clk,8'b10000010, 8'b0001000, 0, 0, square_vol);

parameter SINE     = 0;
parameter FEEDBACK = 1;

wire [3:0] sq1_out;
wire [3:0] sq2_out;

wire [6:0] dmc_out;
wire [3:0] tr_out;
wire [3:0] noise_out;

reg[15:0] sq_tbl[30:0];
reg[15:0] tnd_tbl[202:0];

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

always @(posedge clk) begin
    if (sample_end) begin
        last_sample <= audio_input;
    end

    /*if (sample_req) begin
        if (control[FEEDBACK])
            dat <= last_sample;
        else if (control[SINE]) begin
            dat <= romdata[index];
            if (index == 7'd99)
                index <= 7'd00;
            else
                index <= index + 1'b1;
        end else
            dat <= 16'd0;
    end*/
    //if(control[0]) begin
    //    dat <= noise_en ? 16'h8003 : 16'h0000;
    //end
	 if(control[0]) begin
		dat <= sq_tbl[sq1_out + sq2_out] + tnd_tbl[3 * tr_out + 2 * noise_out + dmc_out];
	 end
	 if else(control[1]) begin
		dat <= square_vol << 10;
	 end
end

endmodule
