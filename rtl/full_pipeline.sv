`timescale 1ns / 1ps

// full_pipeline - see the task description for the requirements.
// Replace the placeholder assignments below with your implementation.

module full_pipeline #(
    parameter int W = 32
) (
    input logic clk,
    input logic rst,  // synchronous, active high

    // input side (from the upstream block)
    input  logic         s_valid,
    output logic         s_ready,
    input  logic [W-1:0] s_data,

    // output side (to the downstream block)
    output logic         m_valid,
    input  logic         m_ready,
    output logic [W-1:0] m_data
);

logic [W-1:0] reg_0, reg_1;
logic [1:0] counter;
logic wptr, rptr;
logic do_write, do_read;

assign do_write = s_ready & s_valid; //input handshake
assign do_read = m_ready & m_valid; //output handshake

assign s_ready = (counter < 2'd2); //reg is free
assign m_valid = (counter > 2'd0); //regs are full

assign m_data = rptr ? reg_1 : reg_0; //output with mux 2x1

always_ff @(posedge clk) begin
  if (rst) begin
    reg_0 <= '0;
    reg_1 <= '0;

    counter <= 2'd0;
      
    wptr <= 1'b0;
    rptr <= 1'b0;
  end else begin
    if (!do_read && do_write) begin
      counter <= counter + 1'b1;
    end else if (!do_write && do_read) begin
      counter <= counter - 1'b1;
    end

    if (do_write) begin
      wptr <= ~wptr;
    end 

    if (do_read) begin
      rptr <= ~rptr;
    end    
  end
end

//input dmux 1x2
always_ff @(posedge clk) begin
  case (do_write)
    1'b0: reg_0 <= s_data;
    1'b1: reg_1 <= s_data;
  endcase
end

endmodule
