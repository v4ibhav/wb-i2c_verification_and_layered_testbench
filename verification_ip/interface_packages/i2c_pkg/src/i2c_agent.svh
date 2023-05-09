// TODO : start from here 

class i2c_agent extends ncsu_component#(.T(i2c_transaction));

  i2c_configuration configuration;
  i2c_driver driver;
  i2c_monitor monitor;
  i2c_coverage coverage_i2c;
  ncsu_component #(T) subscribers[$];

  // virtual wb_if bus;
  virtual i2c_if#(I2C_ADDR_WIDTH,I2C_DATA_WIDTH) bus;


  function new(string name="",ncsu_component_base parent = null);
    super.new(name, parent);
    if ( !(ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH,I2C_DATA_WIDTH))::get(get_full_name(), this.bus))) begin;
      $display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction : set_configuration

  virtual function void build();
    driver = new("driver",this);
    driver.set_configuration(configuration);
    driver.build();
    driver.bus = this.bus;

    // if(configuration.collect_coverage_i2c) begin
    //   coverage_i2c = new("coverage_i2c",this);
    //   coverage_i2c.set_configuration(configuration);
    //   coverage_i2c.build();
    //   connect_subscriber(coverage_i2c);
    // end

    coverage_i2c = new("coverage_i2c",this);
    coverage_i2c.set_configuration(configuration);
    coverage_i2c.build();
    connect_subscriber(coverage_i2c);
    
    monitor = new("monitor",this);
    monitor.set_configuration(configuration);
    monitor.set_agent(this);
    monitor.enable_transaction_viewing = 1;
    monitor.build();
    monitor.bus = this.bus;
  endfunction : build

  virtual function void nb_put(T trans);
    foreach (subscribers[i]) subscribers[i].nb_put(trans);
  endfunction : nb_put

  virtual task bl_put(T trans);
    driver.bl_put(trans);
  endtask : bl_put

  // virtual task bl_get(output T trans);
  //   driver.bl_get(trans);
  // endtask

  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction : connect_subscriber


  virtual task run();
    fork
      monitor.run();
    join_none
  endtask
    
endclass : i2c_agent