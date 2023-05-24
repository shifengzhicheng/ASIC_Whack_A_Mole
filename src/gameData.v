module gameControl (
    clk,
    rst,
    state,
    hitSuccess,
    timeIsup,
    controlkey,
    level,
    gameMode,
    gameSig,
    score
);

  // 输入输出定义
  input clk, rst, timeIsup;
  input [1:0] hitSuccess;
  input [3:0] state;
  input [3:0] controlkey;
  output reg [3:0] level;
  output reg [1:0] gameMode;
  output reg [3:0] gameSig;
  output reg [11:0] score;

  reg [11:0] hitInround;

  // 定义状�?�机常数
  parameter beforeGame = 4'b0001, inGame = 4'b0010, GameLost = 4'b0100, GameWin = 4'b1000;
  // 定义信号常数
  parameter keepCurrent = 4'b0001, game_win = 4'b0010, start_press = 4'b0100, game_lost = 4'b1000;
  // 游戏模式常数
  parameter Level = 2'b10, Dead = 2'b01;
  // hit状�?�常�?
  parameter Success = 2'b10, noneSense = 2'b00, hitLost = 2'b01;

  parameter zeroLevel = 4'b0000, ZeroScore = 12'b0000_0000_0000;

  parameter least_hit = 12'd7;

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      level <= zeroLevel;
      gameMode <= Level;
      gameSig <= keepCurrent;
    end else begin
      case (state)
        beforeGame: begin
          if (controlkey[0] == 0) begin
            gameSig <= start_press;
          end else if (controlkey[1] == 0 && level < 4'b1001) begin
            level   <= level + 1'b1;
            gameSig <= keepCurrent;
          end else if (controlkey[2] == 0 && level > 4'b0000) begin
            level   <= level - 1'b1;
            gameSig <= keepCurrent;
          end else if (controlkey[3] == 0) begin
            gameMode <= ~gameMode;
            level <= zeroLevel;
            gameSig <= keepCurrent;
          end else begin
            gameSig <= keepCurrent;
          end
        end
        inGame: begin
          case (gameMode)
            Level: begin
              if (!timeIsup) gameSig <= keepCurrent;
              else if (hitInround > least_hit) gameSig <= game_win;
              else gameSig <= game_lost;
            end
            Dead: begin
              if (hitSuccess != hitLost && ~timeIsup) gameSig <= keepCurrent;
              else if (timeIsup) gameSig <= game_win;
              else gameSig <= game_lost;
            end
          endcase
        end
        GameLost: begin
          if (controlkey[0] == 0) begin
            gameSig <= start_press;
          end else begin
            gameSig <= keepCurrent;
          end
        end
        GameWin: begin
          if (controlkey[0] == 0) begin
            if (level < 4'd9) begin
              level <= level + 1'b1;
            end
            gameSig <= start_press;
          end else begin
            gameSig <= keepCurrent;
          end
        end
      endcase
    end
  end

  // 计分
  always @(posedge clk or negedge rst) begin
    if (!rst) hitInround <= 0;
    else if (state == inGame) begin
      if (hitSuccess == Success) begin
        hitInround <= hitInround + 1;
      end
    end else hitInround <= 0;
  end

  always @(posedge clk or negedge rst) begin
    if (!rst) score <= ZeroScore;
    else if (state == inGame) begin
      if (hitSuccess == Success) begin
        if (score < 12'd999) begin
          score <= score + 1;
        end else score <= 12'd999;
      end
    end else if (state == beforeGame) begin
      score <= ZeroScore;
    end
  end
endmodule
