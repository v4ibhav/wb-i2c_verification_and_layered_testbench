class i2cmb_env_configuration extends ncsu_configuration;
	
	

	wb_configuration wb_agent_config;
	i2c_configuration i2c_agent_config;
	string test_name;

	function new(string name ="");
		super.new(name);
		// env_conf
		wb_agent_config = new("wb_agent_config");
		i2c_agent_config = new("i2c_agent_config");

		//dont know what to do abou covergroup maybe later

		
	endfunction : new

endclass : i2cmb_env_configuration