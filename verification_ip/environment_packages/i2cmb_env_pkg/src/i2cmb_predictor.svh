class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));


/*
description of predictor:
- predictor is a component that is responsible for predicting the outcome of a transaction
- predictor is not a part of the environment, but a part of the testbench
I need to find all the transistion:
  start => CMDR ==100
  stop  = 
  address =
  data = 

  start-->address-->data-->stop

*/
  i2cmb_scoreboard scoreboard;
  i2c_transaction output_trans;
  i2c_transaction send_trans;

  i2cmb_env_configuration configuration;

  i2c_transaction pridicted_i2ctrans;

  bit[7:0] wb_data_mask = 8'b0000_0001;
  bit repeated_start_bit;
  //enum states 
  typedef enum logic[2:0] {IDLE, START, REPEATED_START, ADDRESS, DATA, STOP} State;
  State state = IDLE;

  //put your variables here
  int read_arr_size;
  int write_arr_size;
  bit[I2C_DATA_WIDTH-1:0] read_data[];
  bit[I2C_DATA_WIDTH-1:0] write_data[];



  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(i2cmb_scoreboard scoreboard);
      this.scoreboard = scoreboard;
  endfunction

  virtual function void nb_put(T trans);
    // if(predicting_func(trans)) scoreboard.nb_transport(pridicted_i2ctrans, output_trans);
    // if(transition_test register_reset_test register_aliasing_test register_default_test register_access_test)
    case (state)
    IDLE:
    begin
      //check if start condition is met
      

      if((trans.wb_address == 2)) begin
        // //$display("State = got start condition");
        state = START;
      end
      else begin
        //$display("State = IDLE");
      end
    end

    START:
    begin
      if((trans.wb_address == 2) && (trans.wb_data == 3'b100)) 
      begin
        //$display("State = START");
        state = ADDRESS;
      end
    end

    ADDRESS:
    begin
      if(trans.wb_address == 1)
      begin
        //$display("State = ADDRESS");
        pridicted_i2ctrans = new("pridicted_i2ctrans");
        pridicted_i2ctrans.i2c_address = trans.wb_data>>1;
        //$display("inside the address %h",pridicted_i2ctrans.i2c_address);
        if(trans.wb_data[0])  pridicted_i2ctrans.op = READ;  
        else pridicted_i2ctrans.op = WRITE;
        state = DATA;
      end
    end

    DATA:
    //data can get repeated start, stop
    begin
      //if write
      if((trans.wb_address == 2) && (trans.wb_data == 3'b101))
        begin
          //$display("STOP seen ",);
          scoreboard.nb_transport(pridicted_i2ctrans,output_trans);
          read_data.delete();
          write_data.delete();
          state = IDLE;
        end
      if((trans.wb_address == 2) && (trans.wb_data == 3'b100))
      begin
        //$display("=====REPEATED_START condition=====");
        scoreboard.nb_transport(pridicted_i2ctrans,output_trans);
        state = ADDRESS;
      end
      if((trans.wb_address == 1) && pridicted_i2ctrans.op == WRITE)
      begin
        //$display("=====write=====");
        read_data.delete();
        write_arr_size =write_data.size()+1;
        write_data = new[write_arr_size](write_data);
        write_data[write_arr_size-1] = trans.wb_data;
        pridicted_i2ctrans.i2c_data = write_data;
        // //$display("inside the write pridicted_i2ctrans == %p,%d",priFdicted_i2ctrans.i2c_data,pridicted_i2ctrans.op);
        //check for repeated start
        //check for stop
      end

      //else if read
      else if((trans.wb_address == 1) && pridicted_i2ctrans.op == READ)
      begin
        //$display("=====read=====");
        write_data.delete();
        read_arr_size = read_data.size()+1;
        read_data = new[read_arr_size](read_data);
        read_data[read_arr_size-1] = trans.wb_data;
        pridicted_i2ctrans.i2c_data = read_data;
        // //$display("insied the read pridicted_i2ctrans == %p,%d",pridicted_i2ctrans.i2c_data,pridicted_i2ctrans.op);
      end 
      // if((trans.wb_address == 2) && (trans.wb_data == 3'b100))
      // begin
      //   state = REPEATED_START;
      // end
      //check for the repeated start
       
    end

    // REPEATED_START:
    // begin
    //   //$display("REPEATED_START",);
    //   scoreboard.nb_transport(pridicted_i2ctrans, output_trans);
    //   //delete accumulated data
    //   state = ADDRESS;
    // end
    endcase
  endfunction
endclass : i2cmb_predictor







