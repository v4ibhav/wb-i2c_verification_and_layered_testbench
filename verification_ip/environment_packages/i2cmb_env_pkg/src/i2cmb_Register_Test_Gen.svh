class i2cmb_Register_Test_Gen extends ncsu_component#(.T(ncsu_transaction));
	  //agents instances
	wb_agent p0_wb_agent;
	i2c_agent p1_i2c_agent;

	//transactions
	wb_transaction	wb_trans;
	i2c_transaction	i2c_trans;
	string trans_name;

	bit [7:0] local_data_test_1[4];
	bit [7:0] local_data_test_2[4];
	bit [7:0] local_data_test_3[4];
	bit [7:0] local_data_test_4[4];
	bit [7:0] local_data_test_5[4];

	bit [WB_DATA_WIDTH-1:0] original_data[4];
   bit [WB_DATA_WIDTH-1:0] post_transaction_data[4];

	bit [7:0] data_test_3_w[];
	bit [7:0] data_test_3_r[];

	bit [7:0] local_read_data [];
	bit [7:0] local_write_data [];
	int local_read_size;
	int local_write_size;

	int i = 0;
	int k = 0;
	i2c_op_t op;
	bit [7:0] i2c_write_data [];
	int j =0;
	int dont_skip_stop;
	static int test_type = 0;

  	function new(string name = "", ncsu_component_base  parent = null); 
    	super.new(name,parent);
  	endfunction

	function void set_wb_agent(wb_agent agent);
	  this.p0_wb_agent = agent;
	endfunction

	function void set_i2c_agent(i2c_agent agent );
		this.p1_i2c_agent = agent;
	endfunction : set_i2c_agent


	task i2c_run(bit [7:0] read_data []);
		$cast(i2c_trans, ncsu_object_factory::create("i2c_transaction"));
		i2c_trans.i2c_data = read_data;
		p1_i2c_agent.bl_put(i2c_trans);
	endtask : i2c_run

	
	task wbrun(bit [1:0] addr, bit [7:0] data, bit op );
		$cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
		this.wb_trans.wb_address = addr;
		this.wb_trans.op  =op;
		if(op == 0) this.wb_trans.wb_data = data;
		
		// if(test_type == 1)
		// begin
		p0_wb_agent.bl_put(this.wb_trans);

		local_read_size = local_read_data.size()+1;
		local_read_data = new[local_read_size](local_read_data);
		local_read_data[local_read_size-1] = this.wb_trans.wb_data;	
		


	endtask 


	task wb_wait_operation();
		logic [7:0] temp_data;
		p0_wb_agent.wait_for_interrupt_fn();
	endtask : wb_wait_operation


	task register_aliasing_test();
		$display(" ==============Register Aliasing Test Start==============");
		
		//start the core
		wbrun(0,8'b11xxxxxx,0);
      	local_read_data.delete();
		wbrun(0,8'hxx,1);
		wbrun(1,8'hxx,1);
		wbrun(2,8'hxx,1);		
		wbrun(3,8'hxx,1);

		local_read_data.delete();
		wbrun(1,8'h65,0);
		local_read_data.delete();	

		wbrun(0,8'hxx,1);
		wbrun(1,8'hxx,1);
		wbrun(2,8'hxx,1);
		wbrun(3,8'hxx,1);


		local_data_test_1 = local_read_data;
		local_read_data.delete();
		local_write_data.delete();

		if(local_data_test_1[0] == 8'b11000000 &&
         local_data_test_1[1] == 8'b00000000 &&
         local_data_test_1[2] == 8'b10000000 &&
         local_data_test_1[3] == 8'b00000000   ) begin
         $display(" ==============connected! DUT Register Aliasing Test VERTIFIED!!==============");
      end 
      else 
      begin
      	$display(" ==============failed! DUT Register Aliasing Test NOT MATCHING!!==============");
      end

	endtask

	task register_default_test();
		$display(" ==============Register Default Test Start==============");


		wbrun(0,2'hxx,1);
		wbrun(1,2'hxx,1);
		wbrun(2,2'hxx,1);
		wbrun(3,2'hxx,1);
		local_data_test_2 = local_read_data;
		if(local_data_test_2[0] == 8'b00000000 &&
         local_data_test_2[1] == 8'b00000000 &&
         local_data_test_2[2] == 8'b10000000 &&
         local_data_test_2[3] == 8'b00000000   ) begin
         $display(" ==============connected! DUT Register Default Test VERTIFIED!!==============");

      end
      else begin
      	$display(" ==============failed! DUT Register Default Test NOT MATCHING!!==============");


      end
      // local_data_test_1 = new[4];
	// 	local_data_test_2 = new[4];
      local_read_data.delete();
      local_write_data.delete();
	endtask : register_default_test



	task register_access_test();
		$display(" ==============Register Access Test Start==============");

		wbrun(0,8'b11xxxxxx,0);
		wbrun(0,2'hxx,1);
		wbrun(1,2'hxx,1);
		wbrun(2,2'hxx,1);
		wbrun(3,2'hxx,0);

		local_read_data.delete();
		wbrun(1,2'h11,1);
		local_read_data.delete();

		wbrun(0,8'hxx,1);
		wbrun(1,8'hxx,1);
		wbrun(2,8'hxx,1);
		wbrun(3,8'hxx,1);

		local_data_test_3 = local_read_data;
		local_write_data.delete();
		local_read_data.delete();

		if(local_data_test_3[0] == 8'b11000000 &&
         local_data_test_3[1] == 8'b00000000 &&
         local_data_test_3[2] == 8'b10000000 &&
         local_data_test_3[3] == 8'b00000000   ) begin
         $display(" ==============connected! DUT Register Access Test VERTIFIED!!==============");
      end
      else begin
      	$display(" ==============failed! DUT Register Access Test NOT MATCHING!!==============");
      end
      $display("END TEST");	
	endtask : register_access_test





	task register_reset_test();
		$display(" ==============Register Access Test Start==============");

		$display(" =========Test : After resetting and not enabling=====\n =========the core write to dpr is not possible and=====\n =========other register value gets reset============");
	

		$cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
		wb_trans.wb_address = 0;
		wb_trans.op = 1;
		p0_wb_agent.bl_put(wb_trans);
		local_data_test_4[0] = wb_trans.wb_data;

		$cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
      	wb_trans.wb_address = 1;
      	wb_trans.op = 0;//change
      	p0_wb_agent.bl_put(wb_trans);
      	local_data_test_4[1] = wb_trans.wb_data;

		$cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
      	wb_trans.wb_address = 2;
      	wb_trans.op = 1;
      	p0_wb_agent.bl_put(wb_trans);
      	local_data_test_4[2] = wb_trans.wb_data;

		$cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
      	wb_trans.wb_address = 3;
      	wb_trans.op = 1;
      	p0_wb_agent.bl_put(wb_trans);
      	local_data_test_4[3] = wb_trans.wb_data;


      	//check values
      	if(	local_data_test_4[0] == 8'b00000000 &&
         	local_data_test_4[1] == 8'b00000000 &&
         	local_data_test_4[2] == 8'b10000000 &&
         	local_data_test_4[3] == 8'b00000000   ) begin
         $display(" ==============connected! DUT Register Reset Test VERTIFIED!!==============");

      	end
      	else begin
      	$display(" ==============failed! DUT Register Reset Test NOT MATCHING!!==============");

      	end

	endtask : register_reset_test

	task i2cmb_register_test();
		// RT_run(1);
		// RT_run(1);
	endtask 


endclass