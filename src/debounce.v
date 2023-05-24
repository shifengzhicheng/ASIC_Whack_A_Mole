module debounce (
    clk,
    button_in,
    button_out
);
  input wire clk;
  input wire [3:0] button_in;
  output reg [3:0] button_out;
  reg [1:0] state;
  parameter threshold = 10;
  integer i;

  always @(posedge clk) begin
    case (state)
      2'b00: begin
        button_out <= 4'b1111;
        if (button_in != 4'b1111) begin
          i <= 0;
          state <= 2'b01;
        end
      end
      2'b01: begin
        if (button_in == 4'b1111) begin
          state <= 2'b00;
        end else if (i >= threshold) begin
          button_out <= button_in;
          state <= 2'b10;
        end else begin
          i <= i + 1;
        end
      end
      2'b10: begin
        button_out <= 4'b1111;
        if (button_in == 4'b1111) begin
          i <= 0;
          state <= 2'b11;
        end
      end
      2'b11: begin
        if (button_in != 4'b1111) begin
          state <= 2'b10;
        end else if (i >= threshold) begin
          button_out <= button_in;
          state <= 2'b00;
        end else begin
          i <= i + 1;
        end
      end
    endcase
  end
endmodule
