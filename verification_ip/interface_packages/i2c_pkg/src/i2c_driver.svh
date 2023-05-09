class i2c_driver extends ncsu_component#(.T(i2c_transaction));
	
	bit transfer_completed = 0;
	i2c_transaction i2c_trans ;
	function new(string name="",ncsu_component#(T) parent = null);
		super.new(name, parent);
	endfunction : new

	virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH) bus;
	i2c_configuration configuration;

	function void set_configuration(i2c_configuration cfg);
		configuration = cfg;	 	
	endfunction : set_configuration

 	virtual task bl_put(T trans);
 		//TODO: provide read data if trans.op is read 
 		// $display("outside while trans.op",trans.op);

 			// if(trans.op)
 			// begin
 		// $display({get_full_name()," this is i2c driver ",trans.convert2string()});
 		// $display("i2c driver trans.op",trans.op);
 		bit transfer_completed = 0;
 		bus.wait_for_i2c_transfer(trans.op,trans.i2c_write_data);
 		if(trans.op == 1)	bus.provide_read_data(trans.i2c_data,transfer_completed);
 		// $display("provide provide_read_data called",trans.op);
	endtask

endclass : i2c_driver