
/*------------------------------------------------------------------------------
--  i2cmb_Direct_Test gen contains generation for data  and random stimulus
------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
--  i2cmb_Register_Test contain register tests
------------------------------------------------------------------------------*/






// class i2cmb_generator extends ncsu_component#(.T(ncsu_transaction));
  
//   `define ASSIGNMENT1;
// 	`define ASSIGNMENT2;
// 	`define ASSIGNMENT3;
// /*------------------------------------------------------------------------------
// --	This will generate all the data previously done by the top.sv
// --  generator is connected to agents and will send data in terms of
// 	transaction
// --
// ------------------------------------------------------------------------------*/
//   //agents instances
//   wb_agent p0_wb_agent;
//   i2c_agent p1_i2c_agent;

//   //transactions
//   wb_transaction	wb_trans;
//   i2c_transaction	i2c_trans;
//   string trans_name;

//   bit [7:0] local_data_test_1[];
// 	bit [7:0] local_data_test_2[];
// 	bit [7:0] data_test_3_w[];
// 	bit [7:0] data_test_3_r[];

// 	bit [7:0] read_data [];

// 	int i = 0;
// 	int k = 0;
// 	i2c_op_t op;
// 	bit [7:0] i2c_write_data [];
// 	int j =0;
// 	int dont_skip_stop;


// //create new object of generator
//   function new(string name = "", ncsu_component_base  parent = null); 
//     super.new(name,parent);
//   endfunction
//  //



// //generator set_agent tasks
// 	function void set_wb_agent(wb_agent agent);
// 	  this.p0_wb_agent = agent;
// 	endfunction
// 	//generator set i2c task
// 	function void set_i2c_agent(i2c_agent agent );
// 		this.p1_i2c_agent = agent;
// 	endfunction : set_i2c_agent
// 	//

// //i2c_run
// 	task i2c_run(bit [7:0] read_data []);
// 		$cast(i2c_trans, ncsu_object_factory::create("i2c_transaction"));
// 		i2c_trans.i2c_data = read_data;
// 		p1_i2c_agent.bl_put(i2c_trans);
// 	endtask : i2c_run



// task run();

// 	fork
// 		begin:Testbench
// 			wb_run_setup();
// 			`ifdef ASSIGNMENT1
// 					$display("****************************************************************************");
// 					$display("Assignment 1 : Writing 0-31 inside the i2c");
// 					$display("****************************************************************************");
// 					local_data_test_1 = new[32];
// 					repeat(32) begin
// 						local_data_test_1[i] = i;
// 						i = i+1;
// 					end
// 					i = 0;
// 					wb_write_generation(local_data_test_1,1);
// 			`endif


// 			`ifdef ASSIGNMENT2
// 					$display("");
// 					$display("****************************************************************************");
// 					$display("Assignment 2 : Read 32 values from the i2c_bus\n return: incrementing value form 100 to 131");
// 					$display("****************************************************************************");
// 					// $display("");

// 					repeat(32)	begin
// 						local_data_test_2[j] = j+100;
// 						j++;		
// 					end
// 					wb_read_generation(0,local_data_test_2,1);
// 				`endif

// 			`ifdef ASSIGNMENT3
// 					$display("");
// 					$display("****************************************************************************");
// 					$display("Assignment 3 Alternate write then read");
// 					$display("****************************************************************************");
// 					dont_skip_stop = 1'b0;
// 					data_test_3_r = new[1];
// 					data_test_3_w = new[1];

// 					// $display("");
// 					repeat(64)	begin
// 						data_test_3_w[0] = k+64;
// 						//$display("k = %d before wb write is called",k);
// 						wb_write_generation(data_test_3_w,dont_skip_stop);	
// 						//$display("k = %d after wb write is called",k);
// 						k++;
// 						if(k == 63) dont_skip_stop = 1'b1;
// 				// //$display("skip_stop",);
// 						wb_read_generation(1,data_test_3_r,dont_skip_stop);
// 					end
// 					dont_skip_stop = 1'b1;
// 					// $display("");
// 					$display("****************************************************************************");
// 					$display("****************************************************************************");
// 					$display("**************************SIMULATION HAS FINISHED***************************");
// 					$display("****************************************************************************");
// 					$display("****************************************************************************");

// 			`endif
// 		end:Testbench
// ///forked///////

// 		begin:FLOW
// 			int iter_j = 0;

// 			forever begin
// 			`ifdef ASSIGNMENT1 
// 				i2c_run(read_data);

// 			`endif

// 			`ifdef ASSIGNMENT2 
// 				read_data = new[32];
// 				for(int i = 0;i <32; i++)
// 				begin
// 					read_data[i] = i+100;
// 				end
// 				i2c_run(read_data);
// 			`endif

// 			`ifdef ASSIGNMENT3 
// 					repeat(128)	begin
// 						i2c_run(i2c_write_data);
// 						read_data = new[1];
// 						read_data[0] = 63-iter_j;
// 						iter_j++;
// 						i2c_run(read_data);
// 					end

// 			`endif
// 			end
// 		end:FLOW

// 	join_any
// 	// $display("joined",);
// endtask : run



// //data generation
// //wb_run
// 	task wb_run(bit [1:0] addr, bit [7:0] data, bit op );
// 		$cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
// 		this.wb_trans.wb_address = addr;
// 		this.wb_trans.wb_data = data;
// 		this.wb_trans.op  =op;
		
// 		p0_wb_agent.bl_put(wb_trans);

// 	endtask : wb_run

// 	task wb_run_setup();
// 		//setting up the bus and core
// 	  wb_run(1'b0,8'b11xxxxxx,0);
// 	  	//$display("set up the bus",);		
// 		wb_run(1'b1,8'h0,0);
// 		//$display("Bus ID is 0:");
// 		wb_run(2,8'bxxxxx110,0);
// 		//$display(" Write byte xxxxx110 to the CMDR. This is Set Bus command.");
// 		wb_wait_operation();
// 	endtask : wb_run_setup

	
	
// 	//wb_wait operation

// 	//****THIS IS WORKING******
// 	// task wb_wait_operation();
// 	// 	bit WB_DON;
// 	// 	// forever	begin
// 	// 	// 	p0_wb_agent.wait_for_interrupt(WB_DON);
// 	// 	// 	if(WB_DON) break;
// 	// 	// end
// 	// endtask : wb_wait_operation
// // **************

// //I AM TRYING TO RUN THIS
// 	task wb_wait_operation();
// 		logic [7:0] temp_data;
// 		// $display("this is working 1",);
// 		p0_wb_agent.wait_for_interrupt_fn();
// 		// $display("this is working 2",);
// 		wb_run(2,temp_data,1);	
// 	endtask : wb_wait_operation

// 	//wb write generation
// 	task wb_write_generation(bit [7:0] data_test_1[], bit dont_skip_stop);
// 		// //$display("Waited",);
// 		wb_run(2,8'bxxxxx100,0);//
// 		//$display(" . Write byte “xxxxx100” to the CMDR. This is Start command.");
// 		wb_wait_operation();
// 		wb_run(1, 8'h44,0);
// 		wb_run(2, 8'bxxxx0001,0);
// 		//$display("Wait for interrupt or until DON bit of CMDR reads '1'.");
// 		wb_wait_operation();
// 		for(int i = 0; i<data_test_1.size();i++)
// 		begin
// 			wb_run(1,data_test_1[i],0);
// 			// //$display("%d data send",i+1);
// 			wb_run(2, 8'bxxxxx001,0);

// 			wb_wait_operation();
// 			//$display("wait for cmdr to 1",);
// 			//wb_monitoring();
// 		end
// 			//$display("dont skip stop command",);
// 			// $display("wait for cmdr to 1");
// 		if(dont_skip_stop)begin
// 			//$display("wait stop command inside not reached",);

// 			wb_run(2, 8'bxxxxx101,0);
// 			//$display("wait stop command",);
// 			wb_wait_operation();
// 			// $display("wait stop command seen");
// 			//wb_monitoring();
// 		end
// 	endtask : wb_write_generation

// 	//wb read generation
// 	task wb_read_generation(int flag,bit [7:0] data_test_2[], bit dont_skip_stop);
// 		logic [7-1:0] temp_data;
// 		automatic int flag_value = 31;
// 		wb_run(2,8'bxxxx_x100,0);
// 		// //$display("this is happening 1",);
// 		wb_wait_operation();
// 		// //$display("this is happening 2",);

// 		wb_run(1,8'h45,0);
// 		// //$display("this is happening 3",);
		
// 		wb_run(2,8'bxxxx_x001,0);
		
// 		// //$display("this is happening 4",);
// 		wb_wait_operation();
// 		// //$display("this is happening 4.1",);

// 		//wb_monitoring();
// 		if(flag)	flag_value = 0;
// 		for(int j = 0; j<flag_value;j++)
// 		begin
// 			wb_run(2, 8'bxxxx_x010,0);
// 		// //$display("this is happening 4.2",);

// 			wb_wait_operation();
// 		// //$display("this is happening 4.3",);

// 			wb_run(1, data_test_2[flag_value],1);
// 		// //$display("this is happening 4.4",);


// 		end
// 		//$display("loop is finished");
// 		wb_run(2,8'bxxxx_x011,0);
// 		// //$display("this is happening 5",);
// 		wb_wait_operation();
// 		//wb_monitoring();
// 		wb_run(1, data_test_2[flag_value],1);
// 		// //$display("this is happening 6",);

// 		if(dont_skip_stop)
// 		begin
// 			wb_run(2,8'bxxxx_x101,0);
// 		// //$display("this is happening 7",);
		
// 			wb_wait_operation();
// 			// $finish;
// 		// //$display("this is happening 8",);

// 		end
// 	endtask : wb_read_generation




// endclass
