module FSM (
    clk,
    rst,
    gameSig,
    state
);
  input clk, rst;  // 时钟信号以及复位信号
  input [3:0] gameSig;  // 用于传输游戏状态机转换的信号
  output [3:0] state;  // 用于记录状态机的state
  reg [3:0] state, next_state;

  // 定义状态机常数
  parameter beforeGame = 4'b0001, inGame = 4'b0010, GameLost = 4'b0100, GameWin = 4'b1000;
  // 定义信号常数
  parameter keepCurrent = 4'b0001, game_win = 4'b0010, start_press = 4'b0100, game_lost = 4'b1000;
  // 游戏模式常数
  parameter Level = 2'b10, Dead = 2'b01;
  // hit状态常数
  parameter Success = 2'b10, noneSense = 2'b11, hitLost = 2'b01;

  // 状态机在next_state与beforeGame状态间跳转
  always @(posedge clk or negedge rst) begin
    if (!rst) state <= beforeGame;
    else state <= next_state;
  end
  // 状态跳转
  always @(gameSig) begin
    case (state)
      beforeGame: begin
        if (gameSig == start_press) next_state <= inGame;
        else next_state <= beforeGame;
      end
      inGame: begin
        if (gameSig == game_win) next_state <= GameWin;
        else if (gameSig == game_lost) next_state <= GameLost;
        else next_state <= inGame;
      end
      GameLost: begin
        if (gameSig == start_press) next_state <= beforeGame;
        else next_state <= GameLost;
      end
      GameWin: begin
        if (gameSig == start_press) next_state <= inGame;
      end
    endcase
  end
endmodule
