module Top_module (
    clk,
    rst_n,
    key_in,
    controlkey,
    led_react,
    mouse,
    seg,
    segIndex,
    key_out
);
  input [3:0] controlkey;  // 控制按键
  input [3:0] key_in;  // 键盘输入
  input rst_n, clk;  // 复位，时�?
  output [3:0] led_react;  // 控制按键反馈
  output [15:0] mouse;  // 地鼠
  output [7:0] seg;  // 数码
  output [5:0] segIndex;  // 数码管信�?
  output [3:0] key_out;  // 键盘选信�?

  // 顶层模块要连接各个模块，之后再细化功
  // 为了实现老鼠出现后的生存周期内需要将老鼠打掉
  // 鼠生存周期在两个数之间浮�?
  // 同时，鼠的出现时间间隔也要在某两个数之间浮动
  // 要至少两个寄存器去存储所要的数据

  wire [3:0] outrst;
  wire rst;
  wire [3:0] state;
  wire [3:0] gameSig;
  wire [15:0] hit_Index;
  wire [1:0] hitSuccess;
  wire timeIsup;
  wire [3:0] level;
  wire [1:0] gameMode;
  wire [7:0] timelimit;
  wire [11:0] score;
  wire [3:0] Ckey;
  wire clk_1000;
  wire clk_1Hz;
  wire [11:0] decscore;
  assign rst = outrst[0];

  // 1000倍时钟频率
  time_divider #(32'd999, 32) clk1000 (
      .clk(clk),
      .rst(rst),
      .clk_out(clk_1000)
  );

  // 1Hz频率发生
  time_divider #(32'd49999999, 32) clock_1Hz (
      .clk(clk),
      .rst(rst),
      .clk_out(clk_1Hz)
  );

  debounce debrst (
      .clk(clk),
      .button_in({3'b111, rst_n}),
      .button_out(outrst)
  );

  debounce debouncecontrolkey (
      .clk(clk_1000),
      .button_in(controlkey),
      .button_out(Ckey)
  );

  counter mycounter (
      .clk(clk_1Hz),
      .state(state),
      .rst(rst),
      .timelimit(timelimit),
      .timeIsup(timeIsup)
  );

  reactled myCkeyspress (
      .clk(clk),
      .controlkey(controlkey),
      .led_react(led_react)
  );

  gameControl mygameData (
      .clk(clk_1000),
      .rst(rst),
      .state(state),
      .hitSuccess(hitSuccess),
      .timeIsup(timeIsup),
      .controlkey(Ckey),
      .level(level),
      .gameMode(gameMode),
      .gameSig(gameSig),
      .score(score)
  );

  binary_bcd bin2bcd (
      .bin_in (score),
      .bcd_out(decscore)
  );
  
  keyboard_scan mypresskey (
      .clk(clk),
      .clk_1000(clk_1000),
      .rst(rst),
      .key_in_y(key_in),
      .key_out_x(key_out),
      .hit_Index(hit_Index)
  );

  FSM myFSM (
      .clk(clk_1000),
      .rst(rst),
      .state(state),
      .gameSig(gameSig)
  );

  display mydisplay (
      .clk(clk),
      .rst(rst),
      .state(state),
      .gameMode(gameMode),
      .level(level),
      .score(decscore),
      .timelimit(timelimit),
      .segIndex(segIndex),
      .seg(seg)
  );

  mouseInterface mymouse (
      .clk(clk_1000),
      .rst(rst),
      .state(state),
      .hit_Index(hit_Index),
      .hitSuccess(hitSuccess),
      .level(level),
      .mouse(mouse)
  );
endmodule
