class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));
	i2cmb_env_configuration configuration;
	i2c_transaction coverage_transaction;

	bit[1:0] reg_addr;
	bit[7:0] reg_data;
	bit op;
	bit[7:0] read_data;
	bit[7:0] wb_data;

	typedef struct{
	    bit done;
	    bit Nack;
	    bit arbit;
	    bit error;
	    bit r;
	    bit[1:0] cmd;
	} CMDR_REG;

	typedef struct{
	    bit enable;
	    bit interrupt;
	    bit bus_busy;
	    bit bus_capt;
	    bit [3:0] bus_id;
	} CSR_REG;


	CMDR_REG CMDR_bits;
	CSR_REG CSR_bits;



	covergroup i2cmb_operation_cg();
		option.name = get_full_name();
		//covergroup to check dut have both read and write functionality
		DUT_read_operation: coverpoint op {bins Wr = {0}; bins Rr = {1};} 
	endgroup : i2cmb_operation_cg

	covergroup i2cmb_DPR_cg();
		option.name = get_full_name();
		DPR_Data_Value: coverpoint reg_data { option.auto_bin_max = 4; }
		
	endgroup : i2cmb_DPR_cg
	
	covergroup i2cmb_CSR_cg();
		option.name = get_full_name();
		CSR_Enable: coverpoint CSR_bits.enable;
		CSR_Interrupt_Enable: coverpoint CSR_bits.interrupt;
		CSR_Bus_Busy: coverpoint CSR_bits.bus_busy;
		CSR_Bus_Captured: coverpoint CSR_bits.bus_capt;
		CSR_Bus_ID: coverpoint CSR_bits.bus_id { option.auto_bin_max = 1; }
	endgroup : i2cmb_CSR_cg
	


	covergroup i2cmb_CMDR_cg();
		option.name = get_full_name();
		
		CMDR_Done: coverpoint CMDR_bits.done iff(op==1);
		CMDR_Nak: coverpoint CMDR_bits.Nack iff(op==1);
		CMDR_Arbitration_Lost: coverpoint CMDR_bits.arbit iff(op==1);
		CMDR_Error_Indication: coverpoint CMDR_bits.error iff(op==1);
			
	endgroup : i2cmb_CMDR_cg

	covergroup i2cmb_regblock_cg();
		option.name = get_full_name();
		register_address: coverpoint reg_addr;
	endgroup : i2cmb_regblock_cg





	
	function void set_configuration(i2cmb_env_configuration cfg);
  		configuration = cfg;
	endfunction

  	function new(string name = "", ncsu_component_base  parent = null);
    	super.new(name,parent);
   		i2cmb_operation_cg = new; 
   		i2cmb_DPR_cg = new;
   		i2cmb_CSR_cg = new;
   		i2cmb_CMDR_cg = new;
   		i2cmb_regblock_cg = new;
  	endfunction

  	virtual function void nb_put(T trans);
    	// $display({get_full_name()," ",trans.convert2string()});
    	// reg_type = reg_type_t'(trans.addr);
    	//header_type = header_type_t'(trans.header[63:60]);
    	//loopback    = configuration.loopback;
    	//invert      = configuration.inveprt;
    	
    	reg_addr = trans.wb_address;
    	reg_data = trans.wb_data;
    	op = trans.op;
    	wb_data = trans.wb_data[0];



		CSR_bits.enable = reg_data[7];
		CSR_bits.interrupt = reg_data[6];
		CSR_bits.bus_busy = reg_data[5];
		CSR_bits.bus_capt = reg_data[4];
		CSR_bits.bus_id = reg_data[3:0];

		CMDR_bits.done = reg_data[7];
		CMDR_bits.Nack 	=reg_data[6];
		CMDR_bits.arbit	=reg_data[5];
		CMDR_bits.error	=reg_data[4];
		CMDR_bits.r	=reg_data[3];
		CMDR_bits.cmd = reg_data[2:0];

		i2cmb_CSR_cg.sample();    		
    	i2cmb_CMDR_cg.sample();
		i2cmb_DPR_cg.sample();
		i2cmb_operation_cg.sample();
		i2cmb_regblock_cg.sample();

  	endfunction
	
endclass : i2cmb_coverage