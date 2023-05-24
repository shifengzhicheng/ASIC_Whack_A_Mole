// 时钟周期接收为1000个clock
module mouseInterface (
    clk,
    rst,
    state,
    level,
    hit_Index,
    hitSuccess,
    mouse
);
  // 这个模块接收打击坐标，产生mouse
  // 比对打击坐标以及老鼠的序号
  input clk, rst;
  input [3:0] level;
  input [3:0] state;
  input [15:0] hit_Index;
  output reg [15:0] mouse;
  output reg [1:0] hitSuccess;

  wire [31:0] random;
  reg [4:0] CurrentMouse;
  // 下一只老鼠出现的时间
  reg [31:0] nextMousecounter;
  reg [3:0] nextIndex;
  // 最多2只老鼠，每只老鼠剩余的生存时间
  reg [31:0] counter;
  // 定义状态机常数

  reg [31:0] maxComeup;
  reg [31:0] minComeup;

  reg gamestart;
  // 随机数生成器
  random lfsr (
      .gamestart(gamestart),
      .refreshSig(clk),
      .rst(rst),
      .randout(random)
  );


  parameter beforeGame = 4'b0001, inGame = 4'b0010, GameLost = 4'b0100, GameWin = 4'b1000;
  parameter baseMinTime = 32'd149999;
  parameter Sec = 32'd49999;
  parameter Success = 2'b10, noneSense = 2'b00, hitLost = 2'b01;

  always @(level) begin
    maxComeup <= baseMinTime + 32'd5000 * (9 - level);
    minComeup <= baseMinTime - 32'd5000 * level;
  end

  reg [1:0] Smstate;
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      gamestart <= 1'b0;
      Smstate   <= 2'b00;
    end else begin
      case (Smstate)
        2'b00: begin
          if (state == inGame) begin
            Smstate   <= 2'b01;
            gamestart <= 1'b1;
          end else begin
            Smstate   <= 2'b00;
            gamestart <= 1'b0;
          end
        end
        2'b01: begin
          if (state == inGame) begin
            Smstate   <= 2'b10;
            gamestart <= 1'b0;
          end else begin
            Smstate   <= 2'b00;
            gamestart <= 1'b0;
          end
        end
        2'b10: begin
          if (state == inGame) begin
            Smstate   <= 2'b10;
            gamestart <= 1'b0;
          end else begin
            Smstate   <= 2'b00;
            gamestart <= 1'b0;
          end
        end
      endcase
    end
  end


  // 距离下一只老鼠生成
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      nextMousecounter <= maxComeup;
    end else if (state == inGame) begin
      if (nextMousecounter != 0) begin
        nextMousecounter <= nextMousecounter - 1;
      end else begin
        nextMousecounter <= random[31:10] % (maxComeup - minComeup) + maxComeup + Sec;
      end
    end
  end

  reg [31:0] liveTime;
  // 老鼠生存时间计数器的更新逻辑
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      liveTime <= maxComeup;
    end else if (state == inGame) begin
      // 只有当下只老鼠到来且当前有老鼠空闲才能产生新的老鼠
      if (counter != 0) begin
        counter <= counter - 1;
      end else if (nextMousecounter == 0) begin
        liveTime <= random[21:0] % (maxComeup - minComeup) + minComeup;
        counter  <= liveTime;
      end
    end else begin
      counter <= 0;
    end
  end
  // 当前老鼠出现的序号的逻辑
  always @(posedge clk) begin
    if (gamestart) begin
      nextIndex <= random[3:0];
      hitSuccess <= noneSense;
      CurrentMouse[4] <= 1'b0;
    end else if (state == inGame) begin
      if (CurrentMouse[4] == 1'b0 && nextMousecounter == 0) begin
        CurrentMouse[3:0] <= nextIndex;
        nextIndex <= random[3:0];
        CurrentMouse[4] <= 1'b1;
        hitSuccess <= noneSense;
      end else if (CurrentMouse[4] == 1'b1) begin
        if (hit_Index[CurrentMouse[3:0]] == 1'b1) begin
          hitSuccess <= Success;
          CurrentMouse[4] <= 1'b0;
        end else if (counter == 0) begin
          hitSuccess <= hitLost;
          CurrentMouse[4] <= 1'b0;
        end else hitSuccess <= noneSense;
      end else hitSuccess <= noneSense;
    end
  end

  // 一直检查老鼠的状态
  always @(CurrentMouse or state) begin
    if (state == inGame) begin
      mouse <= 16'b0000_0000_0000_0000;
      if (CurrentMouse[4] == 1'b1) begin
        mouse[CurrentMouse[3:0]] <= 1'b1;
      end
    end else mouse <= 16'b0000_0000_0000_0000;
  end

endmodule
