class i2cmb_Direct_Test_Gen extends ncsu_component#(.T(ncsu_transaction));
  
  `define ASSIGNMENT1;
	`define ASSIGNMENT2;
	`define ASSIGNMENT3;
/*------------------------------------------------------------------------------
--	This will generate all the data previously done by the top.sv
--  generator is connected to agents and will send data in terms of
	transaction
--
------------------------------------------------------------------------------*/
  //agents instances
  wb_agent p0_wb_agent;
  i2c_agent p1_i2c_agent;

  //transactions
  wb_transaction	wb_trans;
  i2c_transaction	i2c_trans;
  string trans_name;

  bit [7:0] local_data_test_1[];
	bit [7:0] local_data_test_2[];
	bit [7:0] data_test_3_w[];
	bit [7:0] data_test_3_r[];

	bit [7:0] read_data [];

	int i = 0;
	int k = 0;
	i2c_op_t op;
	bit [7:0] i2c_write_data [];
	int j =0;
	int dont_skip_stop;
	bit write_randomize = 0;

	static bit read_with_nack_flag = 0;


//create new object of generator
  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction
 //

//generator set_agent tasks
	function void set_wb_agent(wb_agent agent);
	  this.p0_wb_agent = agent;
	endfunction
	//generator set i2c task
	function void set_i2c_agent(i2c_agent agent );
		this.p1_i2c_agent = agent;
	endfunction : set_i2c_agent
	//

//i2c_run
	task i2c_run(bit [7:0] read_data []);
		$cast(i2c_trans, ncsu_object_factory::create("i2c_transaction"));
		i2c_trans.i2c_data = read_data;
		p1_i2c_agent.bl_put(i2c_trans);
	endtask : i2c_run

	//wb_run
	task wb_run(bit [1:0] addr, bit [7:0] data, bit op );
		$cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
		this.wb_trans.wb_address = addr;
		this.wb_trans.op  =op;
		if(op == WRITE) this.wb_trans.wb_data = data;
		
		p0_wb_agent.bl_put(wb_trans);

	endtask : wb_run

	task wb_run_setup();
		//setting up the bus and core
	  wb_run(1'b0,8'b11xxxxxx,0);
	  	//$display("set up the bus",);		
		wb_run(1'b1,8'h09,0);
		//$display("Bus ID is 0:");
		wb_run(2,8'bxxxxx110,0);
		//$display(" Write byte xxxxx110 to the CMDR. This is Set Bus command.");
		wb_wait_operation();
	endtask : wb_run_setup

	
	
	//wb_wait operation

	//****THIS IS WORKING******
	// task wb_wait_operation();
	// 	bit WB_DON;
	// 	// forever	begin
	// 	// 	p0_wb_agent.wait_for_interrupt(WB_DON);
	// 	// 	if(WB_DON) break;
	// 	// end
	// endtask : wb_wait_operation
// **************

//I AM TRYING TO RUN THIS
	task wb_wait_operation();
		logic [7:0] temp_data;
		// $display("this is working 1",);
		p0_wb_agent.wait_for_interrupt_fn();
		// $display("this is working 2",);
		wb_run(2,temp_data,1);	
	endtask : wb_wait_operation







task direct_test_run();

	fork
		begin:Testbench
			wb_run_setup();
			`ifdef ASSIGNMENT1
					$display("****************************************************************************");
					$display("Direct Test 1 : Writing 0-31 inside the i2c");
					$display("****************************************************************************");
					local_data_test_1 = new[32];
					repeat(32) begin
						local_data_test_1[i] = i;
						i = i+1;
					end
					i = 0;
					wb_write_generation(local_data_test_1,1,write_randomize,8'h44);
			`endif


			`ifdef ASSIGNMENT2
					$display("");
					$display("****************************************************************************");
					$display("Direct Test 2 : Read 32 values from the i2c_bus");
					$display("****************************************************************************");
					// $display("");
					local_data_test_2 = new[32];
					repeat(32)	begin
						local_data_test_2[j] = j+100;
						j++;		
					end
					wb_read_generation(0,local_data_test_2,1,8'hB1);
				`endif

			`ifdef ASSIGNMENT3
					$display("");
					$display("****************************************************************************");
					$display("Direct Test 3 Alternate write then read");
					$display("****************************************************************************");
					dont_skip_stop = 1'b0;
					data_test_3_r = new[1];
					data_test_3_w = new[1];

					// $display("");
					repeat(64)	begin
						data_test_3_w[0] = k+64;
						//$display("k = %d before wb write is called",k);
						wb_write_generation(data_test_3_w,dont_skip_stop,write_randomize,8'h10);	
						//$display("k = %d after wb write is called",k);
						k++;
						if(k == 63) dont_skip_stop = 1'b1;
				// //$display("skip_stop",);
						wb_read_generation(1,data_test_3_r,dont_skip_stop,8'h45);
					end
					dont_skip_stop = 1'b1;
					// $display("");
					$display("****************************************************************************");
					$display("****************************************************************************");
					$display("**************************SIMULATION HAS FINISHED***************************");
					$display("****************************************************************************");
					$display("****************************************************************************");

			`endif
		end:Testbench
///forked///////

		begin:FLOW
			int iter_j = 0;

			forever begin
			`ifdef ASSIGNMENT1 
				i2c_run(read_data);

			`endif

			`ifdef ASSIGNMENT2 
				read_data = new[32];
				for(int i = 0;i <32; i++)
				begin
					read_data[i] = i+100;
				end
				i2c_run(read_data);
			`endif

			`ifdef ASSIGNMENT3 
					repeat(128)	begin
						i2c_run(i2c_write_data);
						read_data = new[1];
						read_data[0] = 63-iter_j;
						iter_j++;
						i2c_run(read_data);
					end

			`endif
			end
		end:FLOW

	join_any
	// $display("joined",);
endtask 



//data generat
	//address to write on should be in 4 differet
	//wb write generation
	task wb_write_generation(bit [7:0] data_test_1[], bit dont_skip_stop,bit write_randomize,bit[7:0] inaddress);
		// //$display("Waited",);
		// bit[7:0] inaddress = 8'hA0;
		wb_run(2,8'bxxxxx100,0);//
		// $display(" . Write byte “xxxxx100” to the CMDR. This is Start command.");
		wb_wait_operation();
		wb_run(1, inaddress,0);
		wb_run(2, 8'bxxxx0001,0);
		// $display("Wait for interrupt or until DON bit of CMDR reads '1'.");
		wb_wait_operation();
		for(int i = 0; i<data_test_1.size();i++)
		begin
			wb_run(1,data_test_1[i],0);
			// $display("%d data send",i+1);
			wb_run(2, 8'bxxxxx001,0);

			wb_wait_operation();
			// $display("wait for cmdr to 1",);
			//wb_monitoring();
		end
			//$display("dont skip stop command",);
			// $display("wait for cmdr to 1");
		if(dont_skip_stop)begin
			//$display("wait stop command inside not reached",);

			wb_run(2, 8'bxxxxx101,0);
			//$display("wait stop command",);
			wb_wait_operation();
			// $display("wait stop command seen");
			//wb_monitoring();
		end
	endtask : wb_write_generation

	//wb read generation
	task wb_read_generation(int flag,bit [7:0] data_test_2[], bit dont_skip_stop,bit[7:0] inaddress);
		logic [7-1:0] temp_data;
		automatic int flag_value = 31;
		if(read_with_nack_flag) begin
			// $display("=====================================READ WITH NACK FLAG IS 1================================================",);
		end
		wb_run(2,8'bxxxx_x100,0);
		// //$display("this is happening 1",);
		wb_wait_operation();
		// //$display("this is happening 2",);

		wb_run(1,inaddress,0);
		// //$display("this is happening 3",);
		
		wb_run(2,8'bxxxx_x001,0);
		
		// //$display("this is happening 4",);
		wb_wait_operation();
		// //$display("this is happening 4.1",);

		//wb_monitoring();
		if(flag)	flag_value = 0;
		for(int j = 0; j<flag_value;j++)
		begin
			wb_run(2, 8'bxxxx_x010,0);
		// //$display("this is happening 4.2",);

			wb_wait_operation();
		// //$display("this is happening 4.3",);

			wb_run(1, data_test_2[flag_value],1);
		// //$display("this is happening 4.4",);


		end
		//$display("loop is finished");
		if(read_with_nack_flag)
			begin
				wb_run(2,8'bxxxx_x010,0);
				read_with_nack_flag =0;
			end
		else wb_run(2,8'bxxxx_x011,0);
		// //$display("this is happening 5",);
		wb_wait_operation();
		//wb_monitoring();
		wb_run(1, data_test_2[flag_value],1);
		// //$display("this is happening 6",);

		if(dont_skip_stop)
		begin
			wb_run(2,8'bxxxx_x101,0);
		// //$display("this is happening 7",);
		
			wb_wait_operation();
			// $finish;
		// //$display("this is happening 8",);

		end
	endtask : wb_read_generation





	task i2cmb_random_read_test();
		fork
			begin:WB_FLOW
				wb_run_setup();
				$display("****************************************************************************");
				$display("*************Randrom Read Test Starts***************************************");
				$display("****************************************************************************");
				local_data_test_2 = new[32];
				// read_data = new[1];
				repeat(32) begin
					local_data_test_2[j] = j+100;
					j++;
				end
				wb_read_generation(0,local_data_test_2,1,8'h13);

			end

			begin:I2C_FLOW
				forever begin
					read_data = new[32];
					for(int i = 0;i <32; i++)
					begin
						// read_data[i] = $urandom_range(100,132);
						read_data[i] = $urandom_range(0,127);

					end
					i2c_run(read_data);
				end
					
				end

		join_any
	endtask


	task i2cmb_random_write_test();
		fork
			// local_data_test_1 = new[1];
			// local_data_test_2 = new[1];

			begin:I2C_FLOW
				forever begin
					read_data = new[32];
					i2c_run(read_data);					
				end
			end

			begin
				wb_run_setup();
				write_randomize = 1;
				$display("****************************************************************************");
				$display("Random Write Test Starts");
				$display("****************************************************************************");
				local_data_test_1 = new[32];
				repeat(32) begin
					local_data_test_1[i] = $urandom_range(0,64);
					i = i+1;
				end
				i = 0;
				wb_write_generation(local_data_test_1,1,write_randomize,8'hB4);
			end

		join_any
	endtask

	task i2cmb_random_read_write_test();
		fork
			begin


					dont_skip_stop = 1'b0;
					data_test_3_r = new[1];
					data_test_3_w = new[1];

					// $display("");
					wb_run_setup();
					write_randomize = 1;
					$display("****************************************************************************");
					$display("Random Write and Read Test Starts");
					$display("****************************************************************************");
				
					repeat(64)	
					begin
						data_test_3_w[0] = $urandom_range(64,200);
						// $display("k = %d before wb write is called",k);
						wb_write_generation(data_test_3_w,dont_skip_stop,write_randomize,8'hF0);	
						// $display("k = %d after wb write is called",k);
						k++;
						if(k == 63) dont_skip_stop = 1'b1;
						// $display("skip_stop",);
						data_test_3_r[0] = $urandom_range(0,127);
						wb_read_generation(1,data_test_3_r,dont_skip_stop,8'hF1);
					end
					dont_skip_stop = 1'b1;
				
			end
			begin
					forever
					begin
						int iter_j = 0;
						repeat(128)	
						begin
						i2c_run(i2c_write_data);
						read_data = new[1];
						read_data[0] = 63-iter_j;
						iter_j++;
						i2c_run(read_data);
					end
					end
			end
		join_any
	endtask 


		task FSM_transition_test();
				$display("FSM_transistion_test START");
				wb_run_setup();		


			fork
				begin
						$display("Repeated Start Test");
						local_data_test_1 = new[32];
						repeat(32)begin
							local_data_test_1[i] = i;
							i = i+1;
						end
						i=0;
						wb_run(2,8'bxxxxx100,0);//
						// wb_wait_operation();
						wb_write_generation(local_data_test_1,1,write_randomize,8'h18);				
				end
				begin
					forever
					begin
						i2c_run(read_data);
					end
				end
			join_any


			fork
				begin
					$display("Read with NACK Test");
					local_data_test_2 = new[32];
					repeat(32)	begin
						local_data_test_2[j] = j+100;
						j++;		
					end
					read_with_nack_flag = 1;
					wb_read_generation(0,local_data_test_2,1,8'h49);
				end
				
				begin
				forever
					begin
							read_data = new[32];
							for(int i = 0;i <32; i++)
							begin
								read_data[i] = i+100;
							end
							i2c_run(read_data);
						end		
				end
			join_any


			fork
				begin
					$display("Start==>Address==>STOP");
					wb_run(2,8'bxxxxx100,0);
					wb_wait_operation();
					wb_run(1, 8'h44,0);
					wb_run(2, 8'bxxxx0001,0);
					wb_wait_operation();
					wb_run(2, 8'bxxxxx101,0);
					wb_wait_operation();
				end
				begin
					forever
					begin
						i2c_run(read_data);
					end
				end
			join_any

			fork
				wb_run_setup();
				begin
					$display("Reading data with rightmost bit = 0");
					local_data_test_2 = new[1];
					local_data_test_2[0] = 12;
					wb_read_generation(0,local_data_test_2,1,8'h12);
				end
				begin
					forever
					begin
						i2c_run(read_data);
					end
				end
			join_any

		endtask : FSM_transition_test



	task i2cmb_direct_test();
		direct_test_run();
	endtask
	
endclass
