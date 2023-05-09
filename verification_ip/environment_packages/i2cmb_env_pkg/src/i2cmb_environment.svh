class i2cmb_environment extends ncsu_component;
	
	/*------------------------------------------------------------------------------
	-- After test is created we created a new env and gen
	-- env will be getting trasaction from the generator 
	-- inside i2cmb environment two agents are created, predictor and scbd created.
	-- wb_agent is connected to the predictor(which is connected to the scbd) and coverage(not used).
	-- i2c_agent is connected to the scbd
	------------------------------------------------------------------------------*/
	i2cmb_env_configuration configuration;
	wb_agent 	p0_wb_agent;
	i2c_agent 	p1_i2c_agent;
 
	i2cmb_predictor		pred;
	i2cmb_scoreboard	scbd;
	i2cmb_coverage		coverage;

	function  new(string name= "", ncsu_component_base parent = null);
		super.new(name,parent);		
	endfunction : new

	function void set_configuration(i2cmb_env_configuration cfg);
		configuration = cfg;
	endfunction : set_configuration
	
	virtual function void build();
		p0_wb_agent = new("p0_wb_agent",this);
		p0_wb_agent.set_configuration(configuration.wb_agent_config);
		p0_wb_agent.build();
		
		p1_i2c_agent = new("p1_i2c_agent",this);
		p1_i2c_agent.set_configuration(configuration.i2c_agent_config);
		p1_i2c_agent.build();

		pred  = new("pred", this);
	    pred.set_configuration(configuration);
	    pred.build();

	    scbd  = new("scbd", this);
	    scbd.build();
	    
	    coverage = new("coverage", this);
	    coverage.set_configuration(configuration);
	    coverage.build();
	    
	    p0_wb_agent.connect_subscriber(coverage);
	    p0_wb_agent.connect_subscriber(pred);
	    p0_wb_agent.connect_subscriber(coverage);	    	    
	    pred.set_scoreboard(scbd);	
	    p1_i2c_agent.connect_subscriber(scbd);
	endfunction : build

  	function wb_agent get_wb_agent();
    	return p0_wb_agent;
	endfunction

  	function i2c_agent get_i2c_agent();
    	return p1_i2c_agent;
  	endfunction

  	virtual task run();
     	p0_wb_agent.run();
     	p1_i2c_agent.run();
  	endtask
endclass : i2cmb_environment
