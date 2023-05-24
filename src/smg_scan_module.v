module smg_scan_module (
    input        clk,
    input  [5:0] cur_state,
    output [5:0] Scan_Sig
);
  parameter T1MS = 16'd49999;  //1ms time 
  parameter IDLE = 6'b000001;
  parameter ST1 = 6'b000010;
  parameter ST2 = 6'b000100;
  parameter ST3 = 6'b001000;
  parameter ST4 = 6'b010000;
  parameter ST5 = 6'b100000;
  reg [5:0] rScan;  //digital tube scan
  assign Scan_Sig = rScan;
  always @(posedge clk) begin
    case (cur_state)
      IDLE:    rScan <= 6'b011_111;  //The first digital tube strobe            
      ST1:     rScan <= 6'b101_111;  //The second digital tube strobe             
      ST2:     rScan <= 6'b110_111;  //The third digital tube strobe              
      ST3:     rScan <= 6'b111_011;  //The fourth digital tube strobe                
      ST4:     rScan <= 6'b111_101;  //The fifth digital tube strobe                
      ST5:     rScan <= 6'b111_110;  //The sixth digital tube strobe 
      default: rScan <= 6'b100_000;
    endcase
  end
endmodule
