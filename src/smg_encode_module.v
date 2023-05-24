module smg_encode_module (
    input        clk,
    input  [3:0] Number_Data,
    output [7:0] SMG_Data
);

  parameter charL=8'b1100_0111,charE=8'b1000_0110,charV=8'b1100_0001,charA=8'b1000_1000,charD=8'b1100_0000,cline=8'b1111_0111;
  parameter _0 = 8'b1100_0000, _1 = 8'b1111_1001, _2 = 8'b1010_0100, 
           _3 = 8'b1011_0000, _4 = 8'b1001_1001, _5 = 8'b1001_0010, 
           _6 = 8'b1000_0010, _7 = 8'b1111_1000, _8 = 8'b1000_0000,
           _9 = 8'b1001_0000;
  reg [7:0] rSMG;
  assign SMG_Data = rSMG;
  always @(posedge clk) begin
    case (Number_Data)
      4'd0:  rSMG <= _0;
      4'd1:  rSMG <= _1;
      4'd2:  rSMG <= _2;
      4'd3:  rSMG <= _3;
      4'd4:  rSMG <= _4;
      4'd5:  rSMG <= _5;
      4'd6:  rSMG <= _6;
      4'd7:  rSMG <= _7;
      4'd8:  rSMG <= _8;
      4'd9:  rSMG <= _9;
      4'd10: rSMG <= charL;
      4'd11: rSMG <= charE;
      4'd12: rSMG <= charV;
      4'd13: rSMG <= charA;
      4'd14: rSMG <= charD;
      4'd15: rSMG <= cline;
    endcase
  end
endmodule
