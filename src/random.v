module random (
    gamestart,
    refreshSig,
    rst,
    randout
);
  input gamestart;
  input refreshSig;
  input rst;
  output wire [31:0] randout;
  reg [30:0] state;
  reg [30:0] seed;
  always @(posedge refreshSig or posedge gamestart) begin
    if (gamestart) begin
      state <= seed;
    end else begin
      state <= {state[29:0], state[30] ^ state[21] ^ state[9] ^ state[6]};
    end
  end
  always @(posedge refreshSig or negedge rst) begin
    if (!rst) begin
      seed <= 31'b1010;
    end else if (!gamestart) begin
      seed <= seed + 1;
    end
  end
  assign randout = {state, state[30]};

endmodule
