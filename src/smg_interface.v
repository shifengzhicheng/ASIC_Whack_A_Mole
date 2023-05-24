module smg_interface (
    input         clk,
    input         rst,
    input  [23:0] Number_Sig,
    output [ 7:0] SMG_Data,
    output [ 5:0] Scan_Sig
);

  wire [3:0] Number_Data;

  parameter T1MS = 16'd49999;  //1ms count
  parameter IDLE = 6'b000001;
  parameter ST1 = 6'b000010;
  parameter ST2 = 6'b000100;
  parameter ST3 = 6'b001000;
  parameter ST4 = 6'b010000;
  parameter ST5 = 6'b100000;

  reg [15:0] time_cnt;  //time count
  reg [ 5:0] cur_state;
  reg [ 5:0] next_state;

  always @(posedge clk or negedge rst) begin
    if (!rst) cur_state <= IDLE;
    else cur_state <= next_state;
  end
  always @(posedge clk)
    if (time_cnt == T1MS) time_cnt <= 16'd0;
    else time_cnt <= time_cnt + 1'b1;

  always @(time_cnt or cur_state) begin
    case (cur_state)
      IDLE: begin
        if (time_cnt == T1MS) next_state <= ST1;
        else next_state <= IDLE;
      end
      ST1: begin
        if (time_cnt == T1MS) next_state <= ST2;
        else next_state <= ST1;
      end
      ST2: begin
        if (time_cnt == T1MS) next_state <= ST3;
        else next_state <= ST2;
      end
      ST3: begin
        if (time_cnt == T1MS) next_state <= ST4;
        else next_state <= ST3;
      end
      ST4: begin
        if (time_cnt == T1MS) next_state <= ST5;
        else next_state <= ST4;
      end
      ST5: begin
        if (time_cnt == T1MS) next_state <= IDLE;
        else next_state <= ST5;
      end
      default: next_state <= IDLE;
    endcase
  end
  smg_control_module mycontrol (
      .clk(clk),
      .Number_Sig(Number_Sig),
      .cur_state(cur_state),
      .Number_Data(Number_Data)
  );
  smg_encode_module myencode (
      .clk(clk),
      .Number_Data(Number_Data),
      .SMG_Data(SMG_Data)
  );
  smg_scan_module myscan (
      .clk(clk),
      .cur_state(cur_state),
      .Scan_Sig(Scan_Sig)
  );
endmodule
