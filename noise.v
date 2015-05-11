`timescale 1ps/1ps

`define MULT 25

module noise(input clk, input[7:0] r400c, input[7:0] r400e, input[7:0] r400f, output en);
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
    end
    // Register fields
    // loop env + disable length (halt)
    wire      l = r400c[5];
    // env disable
    wire      e = r400c[4];
    // volume + env period
    wire[3:0] n = r400c[3:0];
    // short mode
    wire      mode = r400e[7];
    // period index (see ptable)
    wire[3:0] pi = r400e[3:0];
    // length index (see ltable0/1)
    wire[3:0] li = r400f[7:4];
    // length mode
    wire      lmode = r400f[3];

    wire hlt = 0;

    // 15-bit shift register
    reg[14:0] shift;
    reg[7:0]  counter;
    reg       out = 0;
    assign en = out;
    reg c;
    always@(posedge clk) begin
        // shift register shifting
        for(c = 0; c < 14; c = c + 1) begin
            shift[c] <= shift[c+1];
        end
        // set the 14th bit based on the mode field of r400e
        // TODO confirm what pre-shifted means
        shift[14] <= mode == 0 ? shift[0] ^ shift[1] :
                                 shift[0] ^ shift[6];
        counter <= counter == 0 ? counter : counter - 1;
        out <= shift[0] ? 0 : 1; // TODO else case seems to be unknown?
    end
    // TODO status register counter disable
    // The counter is reset when r400f (?) TODO 4th register is written
    // TODO conflict updating shift/counter in 2 always blocks
    always@(posedge r400f) begin
        counter <= hlt        ? 0 :
                   lmode == 0 ? ltable0[li] :
                                ltable1[li];
    end
    always@(posedge r400e) begin
        shift <= ptable[pi];
    end
endmodule

module clock(output clk);
    reg clock = 1;
    assign clk = clock;
    always begin
        #500;
        clock = !clock;
    end
endmodule

module divider(input base, input[15:0] count, output clk);
    reg[15:0] counter = 0;
    reg       outputclk = 0;
    assign clk = outputclk;
    always@(posedge base) begin
        counter <= counter + 1;
        if(counter == count) begin
            outputclk <= !outputclk;
        end
    end
endmodule
