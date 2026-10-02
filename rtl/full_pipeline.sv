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

logic [W-1:0] reg0, reg1;
logic wptr, rptr;
logic [1:0] counter;
logic do_write, do_read;

assign do_write = s_ready && s_valid; //input handshake
assign do_read = m_ready && m_valid; //output handshake

assign s_ready = (counter < 2'd2); //if any reg is empty
assign m_valid = (counter > 2'd0); //if all regs are full

assign m_data = rptr ? reg1 : reg0; //2x1 mux

always_ff @(posedge clk) begin
  if (rst) begin
    reg0 <= '0;
    reg1 <= '0;

    counter <= '0;

    rptr <= 1'b0;
    wptr <= 1'b0;
  end  else begin
    //1x2 dmux
    if (do_write) begin
      if (wptr == 1'b0) begin
        reg0 <= s_data;
      end else begin
        reg1 <= s_data;
      end
    end

    if (do_write && (!do_read)) begin
      counter <= counter + 1;
    end 

    if (do_read && (!do_write)) begin
      counter <= counter - 1;
    end

    //if do_write -> change reg to next write
    if (do_write) begin
      wptr <= ~wptr;
    end

    //if do_read -> change reg to next read
    if (do_read) begin
      rptr <= ~rptr;
    end

  end
end


endmodule
