class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

	i2c_configuration configuration;
	// virtual wb_if bus;
	virtual i2c_if#(I2C_ADDR_WIDTH,I2C_DATA_WIDTH) bus;


	T i2c_monitored_trans;
	ncsu_component #(T) agent;

	function new(string name="",ncsu_component#(T) parent = null);
		super.new(name,parent);
	endfunction : new

	function void set_configuration(i2c_configuration cfg);
		configuration = cfg;
	endfunction : set_configuration

	function void set_agent(ncsu_component#(T) agent);
		this.agent = agent;
	endfunction : set_agent

	virtual task run();
		//TODO this task will run the monitor tasks;
		// bus.wait_for_reset();
		forever	begin
			i2c_monitored_trans = new("i2c_monitored_trans");
			// if(enable_transaction_viewing)	begin
				// i2c_monitored_trans.start_time = $time;
			// end
			bus.monitor(i2c_monitored_trans.i2c_address,
						i2c_monitored_trans.op,
						i2c_monitored_trans.i2c_data);
			// ncsu_info(" i2c_monitor::run()", $sformatf("%s  i2c_ADDRESS:0x%h i2c_DATA :0x%p OPERATION:0x%x",get_full_name(),
            //      		i2c_monitored_trans.i2c_address,
			// 			i2c_monitored_trans.i2c_data,
			// 			i2c_monitored_trans.op) ,NCSU_NONE);
			// $display("%s i2c_monitor::run() i2c_ADDRESS:0x%h i2c_DATA :0x%p OPERATION:0x%x",
            //      		get_full_name(),
            //      		i2c_monitored_trans.i2c_address,
			// 			i2c_monitored_trans.i2c_data,
			// 			i2c_monitored_trans.op);
			this.agent.nb_put(i2c_monitored_trans);
			// if(enable_transaction_viewing)	begin
			// i2c_monitored_trans.end_time = $time;
			// end
		end
	endtask
	

endclass : i2c_monitor