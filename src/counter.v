module counter (
    clk,
    state,
    rst,
    timelimit,
    timeIsup
);

  input clk, rst;
  input [3:0] state;
  output reg [7:0] timelimit;
  output reg timeIsup;

  // 定义状态机常数
  parameter beforeGame = 4'b0001, inGame = 4'b0010, GameLost = 4'b0100, GameWin = 4'b1000;
  // 定义信号常数
  parameter keepCurrent = 4'b0001, game_win = 4'b0010, start_press = 4'b0100, game_lost = 4'b1000;
  // 游戏模式常数
  parameter Level = 2'b10, Dead = 2'b01;
  // hit状态常数
  parameter Success = 2'b10, noneSense = 2'b11, hitLost = 2'b01;

  parameter Aminute = 8'b0110_0000;


  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      timelimit <= Aminute;
    end else begin
      case (state)
        inGame: begin
          if (timelimit[3:0] != 4'b0000) timelimit <= timelimit - 1;
          else if (timelimit[7:4] != 4'b0000) begin
            timelimit[7:4] <= timelimit[7:4] - 1;
            timelimit[3:0] <= 4'b1001;
          end
        end
        GameWin: begin
          timelimit <= Aminute;
        end
        beforeGame: begin
          timelimit <= Aminute;
        end
        GameLost: begin
          timelimit <= Aminute;
        end
      endcase
    end
  end

  always @(posedge clk) begin
    if (timelimit == 0) timeIsup <= 1'b1;
    else timeIsup <= 1'b0;
  end

endmodule
