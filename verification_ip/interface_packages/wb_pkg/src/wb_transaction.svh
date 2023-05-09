//everything is transaction so it should have enough information that


class wb_transaction extends ncsu_transaction;	
	`ncsu_register_object(wb_transaction);

	//some value that is about information
	bit op; //read or write
	bit[WB_ADDR_WIDTH-1:0] wb_address;
	bit[WB_DATA_WIDTH-1:0] wb_data;

	function new(string name="");
		super.new(name);		
	endfunction : new
	

	virtual function string convert2string();
	//TODO : not done yet what to put?
		return {super.convert2string(),$sformatf("WB_ADDRESS:0x%x WB_DATA :0x%x OPERATION:0x%x",
			wb_address, wb_data, op)};
	endfunction : convert2string

	// function bit compare(wb_transaction rhs);
	// 	return ((this.wb_address == rhs.wb_address) &&
	// 	 		(this.wb_data 	 == rhs.wb_data) &&
	// 	 		(this.op 		 == rhs.op));
	// endfunction : compare

	virtual function void addtowave();
		//
	endfunction : addtowave
endclass : wb_transaction