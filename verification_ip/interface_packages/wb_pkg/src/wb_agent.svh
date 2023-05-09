// TODO : start from here 

class wb_agent extends ncsu_component#(.T(wb_transaction));

  wb_configuration configuration;
  wb_driver driver;
  wb_monitor monitor;
  wb_coverage coverage_wb;
  ncsu_component #(T) subscribers[$];

  // virtual wb_if bus;
  virtual wb_if#(WB_ADDR_WIDTH,WB_DATA_WIDTH) bus;


  function new(string name="",ncsu_component_base parent = null);
    super.new(name, parent);
    if ( !(ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH,WB_DATA_WIDTH))::get(get_full_name(), this.bus))) begin;
      $display("wb_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction : set_configuration

  virtual function void build();
    driver = new("driver",this);
    driver.set_configuration(configuration);
    driver.build();
    driver.bus = this.bus;

    // if(configuration.collect_coverage_wb) begin
    //   coverage_wb = new("coverage_wb",this);
    //   coverage_wb.set_configuration(configuration);
    //   coverage_wb.build();
    //   connect_subscriber(coverage_wb);
    // end
    coverage_wb = new("coverage_wb",this);
    coverage_wb.set_configuration(configuration);

    coverage_wb.build();
    connect_subscriber(coverage_wb);

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

  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction : connect_subscriber

  task wait_for_interrupt(output bit WB_DON);
    monitor.wb_interrupt_check(WB_DON);
  endtask : wait_for_interrupt
  
  task wait_for_interrupt_fn();
    monitor.wb_interrupt_check_fn();
  endtask : wait_for_interrupt_fn




  virtual task run();
    fork
      monitor.run();
    join_none
  endtask

    
endclass : wb_agent