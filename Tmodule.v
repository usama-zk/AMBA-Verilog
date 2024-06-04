`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:40:34 05/30/2024 
// Design Name: 
// Module Name:    ahb_top 
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

module ahb_top(
  input hclk,
  input clk2,
  input hresetn,
  input enable,
  input wr,
  input [1:0] sw,
  input [2:0] sel,
  
  output [3:0] ENABLE,
  output [6:0] LED_OUT
  //output [31:0] dout
);

  wire [31:0] slave_sel, dina, addr;
  wire [31:0] hrdata1, hrdata2, hrdata3, addr_to_slave, b_addr, b_data, readedData, apbread;
  wire hreadyout1, hreadyout2, hreadyout3, hr, wr2;
  wire hresp1, hresp2, hresp3;
  wire rdata_invalid1, rdata_invalid2, rdata_invalid3, trans, b_writeSignal;



  dataholder(
  .clk(hclk),
  .place_address(addr),
  .place_data(dina));
  
  
  decoder dec(
    .sel(sel),
    .slave_sel(slave_sel)
  );

  ahb_master master(
    .hclk(hclk),
    .hresetn(hresetn),
    .enable(enable),
    .dina(dina),
    .addr(addr),
    .wr(wr),
    .hreadyout(hreadyout1 & hreadyout2 & hreadyout3), // Assuming hreadyout is AND of all slaves' hreadyout
    .hresp(hresp1 & hresp2 & hresp3),             // Assuming hresp is AND of all slaves' hresp
    .hrdata(readedData),
    .slave_sel(slave_sel[1:0]),
    .sel(sel),
    .haddr(addr_to_slave),
    .hwrite(wr2),
    .hsize(hsize),
    .hburst(hburst),
    .hprot(hprot),
    .htrans(htrans),
    .hmastlock(hmastlock),
    .hready(hr),
    .hwdata(hwdata),
    .dout()
  );

  ahb_slave slave1(
    .hclk(hclk),
    .hresetn(hresetn),
    .hsel(slave_sel[0]),
    .haddr(addr),
    .hwrite(wr2),
    .hsize(3'b000),
    .hburst(3'b000),
    .hprot(4'b0000),
    .htrans(2'b00),
    .hmastlock(1'b0),
    .hready(hr),
    .hwdata(dina),
    .hreadyout(hreadyout1),
    .hresp(hresp1),
    .hrdata(hrdata1),
	 .rdata_invalid(rdata_invalid1)
  );

  ahb_slave slave2(
    .hclk(hclk),
    .hresetn(hresetn),
    .hsel(slave_sel[1]),
    .haddr(addr),
    .hwrite(wr2),
    .hsize(3'b000),
    .hburst(3'b000),
    .hprot(4'b0000),
    .htrans(2'b00),
    .hmastlock(1'b0),
    .hready(enable),
    .hwdata(dina),
    .hreadyout(hreadyout2),
    .hresp(hresp2),
    .hrdata(hrdata2),
	 .rdata_invalid(rdata_invalid2)
  );
  
    ahb_slave slave3(
    .hclk(hclk),
    .hresetn(hresetn),
    .hsel(slave_sel[2]),
    .haddr(addr),
    .hwrite(wr2),
    .hsize(3'b000),
    .hburst(3'b000),
    .hprot(4'b0000),
    .htrans(2'b00),
    .hmastlock(1'b0),
    .hready(enable),
    .hwdata(dina),
    .hreadyout(hreadyout3),
    .hresp(hresp3),
    .hrdata(hrdata3),
	 .rdata_invalid(rdata_invalid3)
  );
  
  
  Bridge bridge(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel (slave_sel[3]),
  .haddr(addr_to_slave),
  .hwrite(wr2),
  .hready(enable),
  .hwdata(dina),
  .out_addr(b_addr),
  .out_writeData(b_data),
  .out_hwrite(b_writeSignal),
  .out_transferSignal(trans),
  .hreadyout(hreadyout),
  .hresp(hresp)
  );
  
  multiplexer mux(
    .hrdata1(hrdata1),
    .hrdata2(hrdata2),
    .hrdata3(hrdata3),
	 .hrdata4(apbread),
    .sel(sel),
	 .rdata_iv1(rdata_invalid1),
	 .rdata_iv2(rdata_invalid2),
	 .rdata_iv3(rdata_invalid3),
    .hrdata(readedData)
  );
  
  
	Top_Module t_ahb(
    .PCLK(hclk),
    .PRESETn(hresetn),
    .transfer (trans),
    .READ_WRITE(b_writeSignal),
    .apb_write_paddr(b_addr),
    .apb_write_data(b_data),
    .apb_read_paddr(b_addr),
    .PSLVERR(PSLVERR),
    .apb_read_data_out(apbread)
);


SevenSegment ss(
 .clk(clk2),
 .address(addr),
 .data(dina),
 .enable(ENABLE),
 .LED_out(LED_OUT),
 .switch(sw),
 .coming_data(readedData)
);

endmodule

