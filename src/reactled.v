module reactled (
    clk,
    controlkey,
    led_react
);
  input clk;
  input [3:0] controlkey;
  output reg [3:0] led_react;
  always @(posedge clk) begin
    if (controlkey[0] == 0) begin
      led_react[0] <= 0;
    end else led_react[0] <= 1;
    if (controlkey[1] == 0) begin
      led_react[1] <= 0;
    end else led_react[1] <= 1;
    if (controlkey[2] == 0) begin
      led_react[2] <= 0;
    end else led_react[2] <= 1;
    if (controlkey[3] == 0) begin
      led_react[3] <= 0;
    end else led_react[3] <= 1;
  end
endmodule
