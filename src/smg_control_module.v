module smg_control_module (
    input         clk,
    input  [23:0] Number_Sig,
    input  [ 5:0] cur_state,
    output [ 3:0] Number_Data
);
  parameter IDLE = 6'b000001;
  parameter ST1 = 6'b000010;
  parameter ST2 = 6'b000100;
  parameter ST3 = 6'b001000;
  parameter ST4 = 6'b010000;
  parameter ST5 = 6'b100000;

  reg [3:0] rNumber;

  always @(posedge clk) begin
    case (cur_state)
      IDLE:    rNumber <= Number_Sig[23:20];  //sixth digital tube display        
      ST1:     rNumber <= Number_Sig[19:16];  //fifth digital tube display
      ST2:     rNumber <= Number_Sig[15:12];  //fourth digital tube display
      ST3:     rNumber <= Number_Sig[11:8];  //third digital tube display
      ST4:     rNumber <= Number_Sig[7:4];  //second digital tube display
      ST5:     rNumber <= Number_Sig[3:0];  //first digital tube display
      default: rNumber <= 4'd0;
    endcase
  end
  assign Number_Data = rNumber;
endmodule
