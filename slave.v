`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:35:08 05/29/2024 
// Design Name: 
// Module Name:    slave 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module ahb_slave(
  input hclk,
  input hresetn,
  input hsel,
  input [31:0] haddr,
  input hwrite,
  input [2:0] hsize,
  input [2:0] hburst,
  input [3:0] hprot,
  input [1:0] htrans,
  input hmastlock,
  input hready,
  input [31:0] hwdata,
  output reg hreadyout,
  output reg hresp,
  output reg [31:0] hrdata,
  output reg add_invalid,
  output reg add_valid,
  output reg rdata_invalid,
  output reg rdata_valid
);

//----------------------------------------------------------------------
// The definitions for internal registers for data storage
//----------------------------------------------------------------------
reg [31:0] mem [31:0];
reg [4:0] waddr;
reg [4:0] raddr;

//----------------------------------------------------------------------
// The definition for state machine
//----------------------------------------------------------------------
reg [1:0] state;
reg [1:0] next_state;
localparam idle = 2'b00, s1 = 2'b01, s2 = 2'b10, s3 = 2'b11;

//----------------------------------------------------------------------
// Memory initialization
//----------------------------------------------------------------------

(*RAM_STYLE = "BLOCK" *)
initial begin
$readmemh("slavemem.txt", mem, 0, 14);
end
 

//----------------------------------------------------------------------
// The state machine
//----------------------------------------------------------------------

always @(posedge hclk or posedge hresetn) begin
  if(hresetn) begin
    state <= idle;
  end
  else begin
    state <= next_state;
  end
end

always @(*) begin
next_state = state; 
  case(state)
    idle: begin
      if(hsel == 1'b1) begin
        if(hwrite == 1'b1)
          next_state = s2;
        else
          next_state = s1;
      end
      else begin
        next_state = idle;
      end
    end
    s1: begin
      if((hwrite == 1'b1) && (hready == 1'b1)) begin
        next_state = s2;
      end
      else if((hwrite == 1'b0) && (hready == 1'b1)) begin
        next_state = s3;
      end
      else begin
        next_state = s1;
      end
    end
    s2: begin
      next_state = idle;
    end
    s3: begin
      next_state = idle;
    end
    default: begin
      next_state = idle;
    end
  endcase
end

always @(posedge hclk or posedge hresetn) begin

  if(hresetn) begin
    hreadyout <= 1'b0;
    hresp <= 1'b0;
    hrdata <= 32'h0000_0000;
    waddr <= 5'b00000;
    raddr <= 5'b00000;
  end
  else begin
    case(next_state)
      idle: begin
        hreadyout <= 1'b0;
        hresp <= 1'b0;
        hrdata <= hrdata;
        waddr <= waddr;
        raddr <= raddr;
      end
      s1: begin
        hreadyout <= 1'b0;
        hresp <= 1'b0;
        hrdata <= hrdata;
        waddr <= haddr[4:0];
        raddr <= haddr[4:0];
      end
      s2: begin
        hreadyout <= 1'b1;
        hresp <= 1'b0;
        mem[waddr] <= hwdata;
		  end

      s3: begin
        if(!hwrite && hready)begin
			hrdata <= mem[raddr];
        hreadyout <= 1'b1;
        hresp <= 1'b0; end
		  
      end
      default: begin
        hreadyout <= 1'b0;
        hresp <= 1'b0;
        hrdata <= hrdata;
        waddr <= waddr;
        raddr <= raddr;
      end
    endcase
  end
end

endmodule
