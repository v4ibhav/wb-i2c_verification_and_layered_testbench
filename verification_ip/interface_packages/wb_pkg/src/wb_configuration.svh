class wb_configuration extends ncsu_configuration;
	bit irq_enable_check = 1;
	bit cmdr_is_set      = 1;

	function new(string name="");
		super.new(name);
	endfunction : new

	virtual function string convert2string();
		return{super.convert2string};
	endfunction : convert2string
	
endclass : wb_configuration