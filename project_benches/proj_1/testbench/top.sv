
`timescale 1ns / 10ps
import operation::*;
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
bit completed;

// ****************************************************************************
// Clock generator
initial begin: clk_gen
	clk = 1'b0;
    forever
	begin
		#5
		clk = ~clk;
	end  
end: clk_gen

//******************************************************************************
//below data is dynamic careful
bit [WB_DATA_WIDTH-1:0]	data_test_1[];
bit [WB_DATA_WIDTH-1:0]	data_test_2[];


// ****************************************************************************
// Reset generator
initial begin: rst_gen
	#113 rst = 0; 
end: rst_gen
// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript

bit [WB_ADDR_WIDTH-1:0] wb_addr;
bit [WB_DATA_WIDTH-1:0] wb_data;
bit wb_we;

task wb_monitoring();
	wb_bus.master_monitor(wb_addr, wb_data, wb_we);
	$display("WB side monitor :=  addr - %h, data - %h, we - %h", wb_addr, wb_data, wb_we);
endtask
// ****************************************************************************

initial begin : Testbench
	//calls all the assignments needed to be done sequentially
	/*assignment 1 is to write 0-31 (32 times ) 
		so call write function 32 times and give write 
		value in each of them*/
	 
	
	automatic int i = 0;
	automatic int j = 0;
	automatic int k = 0;
	flag = 0;

	data_test_1 = new[32];
	data_test_2 = new[32];
	data_test_3_r = new[1];
	data_test_3_w = new[1];

	#500
	wb_bus.master_write(1'b0,8'b11xxxxxx);	
	$display("Bus ID is 0:");
	wb_bus.master_write(1'b1,8'h0);
	wb_bus.master_write(2,8'bxxxxx110); 
	wait_operation();
	$display("setting the bus command");
	//wb_monitoring();
	repeat(32) begin
		data_test_1[i] = i;
		i = i+1;
	end
//////////////////////////////////////////////////////////////////////////////////////////////////

	//now we have data from 0 to 31 inside data[i]
	//call the write function 
		//flags
	// ! task_complete = 0;
	// $display("");
	$display("****************************************************************************");
	$display("Assigment 1 : Writing 0-31 inside the i2c");
	$display("****************************************************************************");
	write_operation(data_test_1);
	
//////////////////////////////////////////////////////////////////////////////////////////////////
	$display("");
	$display("****************************************************************************");
	$display("Assignment 2 : Read 32 values from the i2c_bus\n return: incrementing value form 100 to 131");
	$display("****************************************************************************");
	$display("");
	//Flags 
	// wait(!task_complete);
	// task_complete =0;
	//ASSIGNMENT 2 
	repeat(32)	begin
		data_test_2[j] = j+100;
		j++;		
	end
	read_operation(data_test_2);
//////////////////////////////////////////////////////////////////////////////////////////////////
	$display("");
	$display("****************************************************************************");
	$display("Assignment 3 Alternate write then read");
	$display("****************************************************************************");
	dont_skip_stop = 1'b0;
	$display("");
	repeat(64)	begin
		data_test_3_w[0] = k+64;
		write_operation(data_test_3_w);
		k++;
		if(k == 63) dont_skip_stop = 1'b1;
		read_operation(data_test_3_r);
	end
	dont_skip_stop = 1'b1;
	$display("");
	$display("****************************************************************************");
	$display("****************************************************************************");
	$display("**************************SIMULATION HAS FINISHED***************************");
	$display("****************************************************************************");
	$display("****************************************************************************");
	$finish();
	//2 Assignmets are done
end :Testbench


bit [I2C_DATA_WIDTH-1:0] i2c_write_data [];
bit [I2C_DATA_WIDTH-1:0] read_data [];
int iter_i = 0;
int iter_j = 0;
//create simulation flow working in the background
initial begin: Flow
	// forever begin
		//assignment 1
	fork
	forever begin
	i2c_bus.wait_for_i2c_transfer(op,i2c_write_data);

	//assignment 2
	read_data = new[32];
	for(int i = 0;i <32; i++)
	begin
		read_data[i] = i+100;
	end
	while(op != READ)
	begin
		i2c_bus.wait_for_i2c_transfer(op, i2c_write_data);	
	end
	i2c_bus.provide_read_data(read_data, completed);	

	//assignment 3
	read_data = new[1];
	flag = 1;
	repeat(128)	begin
		i2c_bus.wait_for_i2c_transfer(op,i2c_write_data);
		if(op)	
		begin
			read_data[0] = 63-iter_j;
			iter_j++;
			i2c_bus.provide_read_data(read_data,completed);
		end
	end
	end
	join_none
end: Flow

logic [WB_DATA_WIDTH-1:0] temp_data;
task wait_operation();
	forever 
		begin
			wb_bus.master_read(2, temp_data);
			if(temp_data[7]) break;
		end
endtask

task write_operation(
					bit [WB_DATA_WIDTH-1:0]	data_test_1[]
					);
	//$display("inside the write operation");
	wb_bus.master_write(2,8'bxxxxx100); 
	wait_operation();
	$display("Set the Start Command");
	//wb_monitoring();
	//$display("Setting the I2C Slave address to 8'h22");
	wb_bus.master_write(1, 8'h44);
	wb_bus.master_write(2, 8'bxxxxx001);
	wait_operation();
	$display("Set the Slave address");
	//wb_monitoring();
	
	for(int i = 0; i<data_test_1.size();i++)
	begin
		wb_bus.master_write(1,data_test_1[i]);
		wb_bus.master_write(2, 8'bxxxxx001);
		wait_operation();
		//wb_monitoring();
	end
	//$display("Write the stop bit 31 bytes of data has been send to the i2c");
	if(dont_skip_stop)begin
		wb_bus.master_write(2, 8'bxxxxx101);
		wait_operation();
		//wb_monitoring();
	end
endtask
					
bit [WB_DATA_WIDTH-1:0]	data_test_10000[];

task read_operation(
					bit [WB_DATA_WIDTH-1:0]	data_test_2[]
					);
	//this read operation first will be running test 2 only
	automatic int flag_value = 31;
	wb_bus.master_write(2,8'bxxxx_x100);
	wait_operation();
	//send the read command
	wb_bus.master_write(1,8'h45);
	// //send the write command 
	wb_bus.master_write(2,8'bxxxx_x001);
	wait_operation();
	//wb_monitoring();
	// //read the values
	if(flag)	flag_value = 0;
	for(int j = 0; j<flag_value;j++)
	begin
		wb_bus.master_write(2, 8'bxxxx_x010);
		wait_operation();
		wb_bus.master_read(1, data_test_2[j]);
		//wb_monitoring();

	end
	//$display("loop is finished");
	// //read command
	wb_bus.master_write(2,8'bxxxx_x011);
	wait_operation();
	//wb_monitoring();

	wb_bus.master_read(1, temp_data);
	// //stop command
	//$display("stop command ");
	if(dont_skip_stop)
	begin
		wb_bus.master_write(2,8'bxxxx_x101);
		wait_operation();
		//wb_monitoring();
	end
endtask

//********************************************************************************
bit operation;
bit [I2C_ADDR_WIDTH-1:0] i2c_addr;
bit  [I2C_DATA_WIDTH-1:0] i2c_data[];
initial begin : I2C_Monitor
   forever begin
      i2c_bus.monitor(i2c_addr, operation, i2c_data);
	  if(operation)	begin
		$display("----MONITOR----");
		$display("operation is Read");
	  end
	  else begin
		$display("operation is Write");
	  end
      if(operation == WRITE) begin
	 	$display("I2C_BUS WRITE Transfer: addr - %h, data - %p", i2c_addr, i2c_data);
      end
      else if(operation == READ) begin
	 	$display("I2C_BUS READ  Transfer: addr - %h, data - %p", i2c_addr, i2c_data);
      end
   end
end: I2C_Monitor
//********************************************************************************
// ****************************************************************************
// Instantiate the I2c slave Bus Functional Model
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
endmodule

