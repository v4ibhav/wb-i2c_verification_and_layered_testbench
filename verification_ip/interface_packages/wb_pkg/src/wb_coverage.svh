class wb_coverage extends ncsu_component#(.T(wb_transaction));
	
	bit [WB_ADDR_WIDTH-1:0] addr;
	bit [WB_DATA_WIDTH-1:0] data;
	bit op;
	wb_configuration configuration;

	covergroup wb_operation_cg();
		option.name = get_full_name();
		// option.per_instance =  1;
		
		wb_address_cp:	coverpoint addr{bins csr = {2'b00}; bins dpr = {2'b01};bins cmdr = {2'b10};}
		wb_data_cp:		coverpoint data {option.auto_bin_max = 4;}
		wb_operation_cp:	coverpoint op {bins Wr = {0}; bins Rr = {1};}
		addrXop:	cross wb_address_cp, wb_operation_cp ;
		
	endgroup : wb_operation_cg


	function new(string name="", ncsu_component #(T) parent = null);
		super.new(name,parent);
		wb_operation_cg = new;
	endfunction

	function void set_configuration(wb_configuration cfg);
		configuration = cfg;
	endfunction

	virtual function void nb_put(T trans);
		addr = trans.wb_address;
		data = trans.wb_data;
		op 	 = trans.op;

		// ncsu_info(" wb_monitor::run()", $sformatf("%s  wb_ADDRESS:0x%h wb_DATA :0x%p OPERATION:0x%x",get_full_name(),
        //          		monitored_trans.wb_address,
		// 				monitored_trans.wb_data,
		// 				monitored_trans.op) ,NCSU_NONE);

		wb_operation_cg.sample();	

	endfunction : nb_put
	

endclass