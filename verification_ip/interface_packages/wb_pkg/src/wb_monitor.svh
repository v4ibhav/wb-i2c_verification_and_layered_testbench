class wb_monitor extends ncsu_component#(.T(wb_transaction));

	wb_configuration configuration;
	ncsu_component #(T) agent;
	// virtual wb_if bus;
	virtual wb_if#(WB_ADDR_WIDTH,WB_DATA_WIDTH) bus;


	T monitored_trans;
	// ncsu_component #(T) agent;

	function new(string name="",ncsu_component_base parent = null);
		super.new(name,parent);
	endfunction : new

	function void set_configuration(wb_configuration cfg);
		configuration = cfg;
	endfunction : set_configuration

	function void set_agent(ncsu_component#(T) agent);
		this.agent = agent;
	endfunction : set_agent

	virtual task run();
		//TODO this task will run the monitor tasks;
		bus.wait_for_reset();
		forever	begin
			monitored_trans = new("monitored_trans");
			if(enable_transaction_viewing)	begin
			// 	monitored_trans.start_time = $time;
			// end
			bus.master_monitor(monitored_trans.wb_address,
						monitored_trans.wb_data,
						monitored_trans.op);
			// ncsu_info(" wb_monitor::run()", $sformatf("%s  wb_ADDRESS:0x%h wb_DATA :0x%p OPERATION:0x%x",get_full_name(),
            //      		monitored_trans.wb_address,
			// 			monitored_trans.wb_data,
			// 			monitored_trans.op) ,NCSU_NONE);
			this.agent.nb_put(monitored_trans);
			// if(enable_transaction_viewing)	begin
			// monitored_trans.end_time = $time;
			end
		end

	endtask
	
	task wb_interrupt_check(output bit WB_DON);
		bit [WB_DATA_WIDTH-1:0] temp_data;
		bus.master_read(2,temp_data);
		WB_DON = temp_data[7];
	endtask

	task wb_interrupt_check_fn();
	    bus.wait_for_interrupt();
  endtask : wb_interrupt_check_fn

	

endclass : wb_monitor