		//everything is transaction so it should have enough information that
class i2c_transaction extends ncsu_transaction;	
	`ncsu_register_object(i2c_transaction);

	//some value that is about information
	i2c_op_t op;  //this is readenable bit
	bit[I2C_ADDR_WIDTH-1:0] i2c_address;
	bit[I2C_DATA_WIDTH-1:0] i2c_data[];
	bit[I2C_DATA_WIDTH-1:0] i2c_write_data[];


	function new(string name="");
		super.new(name);		
	endfunction : new
	

	virtual function string convert2string();
	//TODO : not done yet what to put?
		foreach (i2c_data[i]) begin
			return {super.convert2string(),$sformatf("I2C_ADDRESS:0x%x I2C_DATA :0x%x OPERATION:0x%x",i2c_address, i2c_data[i], op)};
		end
	endfunction : convert2string

	function bit compare(i2c_transaction rhs);
		return ((this.i2c_address == rhs.i2c_address) &&
		 		(this.i2c_data 	 == rhs.i2c_data) &&
		 		(this.op 		 == rhs.op));
	endfunction : compare

	// virtual function void addtowave();
	// 	//
	// endfunction : addtowave
endclass : i2c_transaction