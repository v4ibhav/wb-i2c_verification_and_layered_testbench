class i2c_configuration extends ncsu_configuration;
	function new(string name="");
		super.new(name);
	endfunction : new

	virtual function string convert2string();
		return{super.convert2string};
	endfunction : convert2string
	
endclass : i2c_configuration