
`timescale 1ns / 10ps
import operation::*;
import ncsu_pkg::*;
import wb_pkg::*;
import i2cmb_env_pkg::*;


module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;
parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;

bit [WB_DATA_WIDTH-1:0]	data_test_3_r[];
bit [WB_DATA_WIDTH-1:0]	data_test_3_w[];

wire [NUM_I2C_BUSSES-1:0] sda_i;
wire [NUM_I2C_BUSSES-1:0] sda_o;
wire cyc;
wire stb;
wire we;

bit flag = 1'b0;
bit dont_skip_stop = 1'b1;
bit must_not_skip = 1'b0;
bit task_complete = 1'b0;

wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;

tri ack;
tri [NUM_I2C_BUSSES-1:0] scl;
triand  [NUM_I2C_BUSSES-1:0] sda;

assign sda_o = sda;
// typedef enum logic {WRITE,READ} i2c_op_t;
i2c_op_t op;

bit  clk;
bit  rst = 1'b1;
bit completed = 0;
//******************************************************************************
//below data is dynamic careful
bit [WB_DATA_WIDTH-1:0]	data_test_1[];
bit [WB_DATA_WIDTH-1:0]	data_test_2[];
bit [WB_ADDR_WIDTH-1:0] wb_addr;
bit [WB_DATA_WIDTH-1:0] wb_data;
bit wb_we;
//******************************************************************************

// ****************************************************************************
// Clock generator function
initial begin: clk_gen
	clk = 1'b0;
    forever
	begin
		#5
		clk = ~clk;
	end  
end: clk_gen

// ****************************************************************************
// Reset generator
initial begin: rst_gen
	#113 rst = 0; 
end: rst_gen
// ****************************************************************************

i2c_if #(
	.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
	.I2C_DATA_WIDTH(I2C_DATA_WIDTH),
	.NUM_I2C_BUSSES(NUM_I2C_BUSSES)
	)
i2c_bus(
	.scl(scl),
	.sda_i(sda_o),
	.sda_o(sda_i)
);

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  .irq_i(irq),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );


// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda_i),        // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

//it is happening
i2cmb_test test1;
initial begin: test_flow
	ncsu_config_db#(virtual wb_if#(2,8))::set("test_bench.env.p0_wb_agent",wb_bus);
	ncsu_config_db#(virtual i2c_if)::set("test_bench.env.p1_i2c_agent",i2c_bus);

	test1 = new("test_bench",null);
	wait(rst);
	test1.run();
  $finish;
	
end: test_flow



endmodule

