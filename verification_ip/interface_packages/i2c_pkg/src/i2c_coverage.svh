// i2c_coverage.svh
class i2c_coverage extends ncsu_component#(.T(i2c_transaction));

	bit [I2C_ADDR_WIDTH-1:0] addr;
	bit [I2C_DATA_WIDTH-1:0] data;
	i2c_op_t op;
	i2c_configuration configuration;
	// i2c_coverage coverage;
	covergroup i2c_operation_cg();
		option.name = get_full_name();
		// option.per_instance =  1;

		i2c_address_cp	:		coverpoint addr { option.auto_bin_max = 4; } 
		i2c_data_cp	:		coverpoint data {option.auto_bin_max = 4;}
		op_cp 		:		coverpoint op{bins Wr = {0}; bins Rr = {1};}

		addrXop:		cross i2c_address_cp, op_cp;
		
	endgroup : i2c_operation_cg


	function new(string name="", ncsu_component #(T) parent = null);
		super.new(name,parent);
		i2c_operation_cg = new;
	endfunction

	function void set_configuration(i2c_configuration cfg);
		configuration = cfg;
	endfunction

	virtual function void nb_put(T trans);
		addr = trans.i2c_address;
		data = trans.i2c_data[0];
		op 	 = trans.op;

		i2c_operation_cg.sample();

	endfunction : nb_put

endclass