class wb_driver extends ncsu_component#(.T(wb_transaction));
	
	function new(string name="",ncsu_component_base parent = null);
		super.new(name, parent);		
	endfunction : new

	virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH) bus;
	wb_configuration configuration;
	wb_transaction wb_trans;

	function void set_configuration(wb_configuration cfg);
		configuration = cfg;	 	
	endfunction : set_configuration

 	virtual task bl_put(T trans);
 		//TODO: put in the blocking put
	    // $display({get_full_name()," ",trans.convert2string()});
	    // $display("trans is ",trans.op);
	    
 		if (!trans.op)	bus.master_write(trans.wb_address,trans.wb_data);
 		else if(trans.op)	bus.master_read(trans.wb_address,trans.wb_data);
	endtask
	


endclass : wb_driver