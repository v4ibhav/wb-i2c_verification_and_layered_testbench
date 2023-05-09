class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));

  T trans_in;
  T trans_out;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual function void nb_transport(input T input_trans, output T output_trans);
    this.trans_in = input_trans;
    output_trans = trans_out;
    // ncsu_info(" i2c_scoreboard predicted data:", $sformatf("%s  i2c_ADDRESS:0x%h i2c_DATA :0x%p OPERATION:0x%x",get_full_name(),
    //                 trans_in.i2c_address,
    //         trans_in.i2c_data,
    //         trans_in.op) ,NCSU_NONE);
  endfunction

  virtual function void nb_put(T trans);
// foreach (trans.i2c_data[i]) begin
//         $display( "Scoreboard: nb_put: actual transaction  addr: 0x%h data: 0x%d op: 0x%d", trans.i2c_address, trans.i2c_data[i],trans.op);
//     end
    if ( this.trans_in.compare(trans)) $display({get_full_name()," ==============connected! DUT Transaction VERTIFIED!!=============="});
    else  begin
      $display({get_full_name()," ==============failed! Transaction Verification NOT MATCHING!!=============="});
    end

  endfunction
endclass : i2cmb_scoreboard
