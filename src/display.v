module display (
    clk,
    rst,
    state,
    gameMode,
    level,
    segIndex,
    seg,
    score,
    timelimit
);
  input clk, rst;
  input [3:0] state;
  input [1:0] gameMode;
  input [3:0] level;
  input [11:0] score;
  input [7:0] timelimit;
  output [7:0] seg;  // 数码管
  output [5:0] segIndex;  // 数码管选通信号

  reg [23:0] Number_Sig;
  // 数码管的接口，以1ms的速度刷新每个数码管的显示
  wire clk_2;

  time_divider #(32'd24_999_999, 32) clock_2Hz (
      .clk(clk),
      .rst(rst),
      .clk_out(clk_2)
  );
  smg_interface myinterface (
      .clk(clk),
      .rst(rst),
      .Number_Sig(Number_Sig),
      .SMG_Data(seg),
      .Scan_Sig(segIndex)
  );

  // 定义状态机常数
  parameter beforeGame = 4'b0001, inGame = 4'b0010, GameLost = 4'b0100, GameWin = 4'b1000;
  // 游戏模式常数
  parameter Level = 2'b10, Dead = 2'b01;

  // 字符显示
  parameter charL=4'b1010,charE=4'b1011,charV=4'b1100,charA=4'b1101,charD=4'b1110,cline=4'b1111;
  parameter Alloff = 24'b1111_1111_1111_1111_1111_1111;
  always @(posedge clk or negedge rst) begin
    // 初始化全灭
    if (!rst) begin
      Number_Sig <= Alloff;
    end else begin
      case (state)
        // 在游戏开始前显示游戏模式
        beforeGame: begin
          case (gameMode)
            Level: begin
              Number_Sig[23:20] <= charL;
              Number_Sig[19:16] <= charE;
              Number_Sig[15:12] <= charV;
              Number_Sig[11:8]  <= charE;
              Number_Sig[7:4]   <= charL;
              Number_Sig[3:0]   <= level;
            end
            Dead: begin
              Number_Sig[23:20] <= cline;
              Number_Sig[19:16] <= charD;
              Number_Sig[15:12] <= charE;
              Number_Sig[11:8]  <= charA;
              Number_Sig[7:4]   <= charD;
              Number_Sig[3:0]   <= level;
            end
          endcase
        end
        // 在游戏中显示时间限制，当前分数
        inGame: begin
          Number_Sig[23:16] <= timelimit;
          Number_Sig[15:12] <= cline;
          Number_Sig[11:0]  <= score;
        end
        // 游戏失败，限时清零，得分闪烁
        GameLost: begin
          Number_Sig[23:16] <= 8'b1111_1111;
          Number_Sig[15:12] <= cline;
          if (clk_2) begin
            Number_Sig[11:0] <= score;
          end else Number_Sig[11:0] <= 12'b1111_1111_1111;
        end
        GameWin: begin
          case (gameMode)
            Level: begin
              Number_Sig[23:20] <= charL;
              Number_Sig[19:16] <= charE;
              Number_Sig[15:12] <= charV;
              Number_Sig[11:8]  <= charE;
              Number_Sig[7:4]   <= charL;
              Number_Sig[3:0]   <= level;
            end
            Dead: begin
              Number_Sig[23:20] <= cline;
              Number_Sig[19:16] <= charD;
              Number_Sig[15:12] <= charE;
              Number_Sig[11:8]  <= charA;
              Number_Sig[7:4]   <= charD;
              if (clk_2) begin
                Number_Sig[3:0] <= level;
              end else Number_Sig[3:0] <= cline;
            end
          endcase
        end
      endcase
    end
  end
endmodule
