module sockit_top (
    input  CLOCK_50_B6A,

    inout  AUD_ADCLRCK,
    input  AUD_ADCDAT,
    inout  AUD_DACLRCK,
    output AUD_DACDAT,
    output AUD_XCK,
    inout  AUD_BCLK,
    output AUD_I2C_SCLK,
    inout  AUD_I2C_SDAT,
    output AUD_MUTE,

    input  [3:0] KEY,
    input  [3:0] SW,
    output [3:0] LED
);

wire reset = !KEY[0];
wire main_clk;
wire audio_clk;

wire [1:0] sample_end;
wire [1:0] sample_req;
wire [15:0] audio_output;
wire [15:0] audio_input;

clock_pll pll (
    .refclk (CLOCK_50_B6A),
    .rst (reset),
    .outclk_0 (audio_clk),
    .outclk_1 (main_clk)
);

i2c_av_config av_config (
    .clk (main_clk),
    .reset (reset),
    .i2c_sclk (AUD_I2C_SCLK),
    .i2c_sdat (AUD_I2C_SDAT),
    .status (dummy)
);

reg[16:0] count = 0;
reg temp = 0;
assign LED[0] = SW[0];
assign LED[1] = SW[1];
assign LED[2] = SW[2];
assign LED[3] = SW[3];
assign LEDEXTRA = temp;
always@(posedge audio_clk) begin
		temp <= 1;
end

assign AUD_XCK = audio_clk;
assign AUD_MUTE = (SW != 4'b0);

wire[3:0] dummy;
audio_codec ac (
    .clk (audio_clk),
    .reset (reset),
    .sample_end (sample_end),
    .sample_req (sample_req),
    .audio_output (audio_output),
    .audio_input (audio_input),
    .channel_sel (2'b10),

    .AUD_ADCLRCK (AUD_ADCLRCK),
    .AUD_ADCDAT (AUD_ADCDAT),
    .AUD_DACLRCK (AUD_DACLRCK),
    .AUD_DACDAT (AUD_DACDAT),
    .AUD_BCLK (AUD_BCLK)
);

audio_effects ae (
    .clk (audio_clk),
    .sample_end (sample_end[1]),
    .sample_req (sample_req[1]),
    .audio_output (audio_output),
    .audio_input  (audio_input),
    .control (SW)
);

endmodule