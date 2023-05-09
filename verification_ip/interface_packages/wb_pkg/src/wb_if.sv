interface wb_if       #(
      int ADDR_WIDTH = 32,                                
      int DATA_WIDTH = 16                                
      )
(
  // System sigals
  input wire clk_i,
  input wire rst_i,
  input wire irq_i,
  // Master signals
  output reg cyc_o,
  output reg stb_o,
  input wire ack_i,
  output reg [ADDR_WIDTH-1:0] adr_o,
  output reg we_o,
  // Slave signals
  input wire cyc_i,
  input wire stb_i,
  output reg ack_o,
  input wire [ADDR_WIDTH-1:0] adr_i,
  input wire we_i,
  // Shred signals
  output reg [DATA_WIDTH-1:0] dat_o,
  input wire [DATA_WIDTH-1:0] dat_i
  );

    logic read_transfer;
    logic write_transfer;
    typedef struct{
        bit done;
        bit Nack;
        bit arbit;
        bit error;
        bit r;
        bit[1:0] cmd;
    } CMDR_REG;

    typedef struct{
        bit enable;
        bit interrupt;
        bit bus_busy;
        bit bus_capt;
        bit [3:0] bus_id;
    } CSR_REG;
    bit wb_read = 1'b0;
    bit wb_write = 1'b1;


    assign read_transfer = cyc_o & stb_o & (we_o==wb_read) & ack_i;
    assign write_transfer = cyc_o & stb_o & (we_o==wb_write) & ack_i;
    CMDR_REG CMDR_bits;
    CSR_REG CSR_bits;

  initial reset_bus();


// ****************************************************************************              
   task wait_for_reset();
       if (rst_i !== 0) @(negedge rst_i);
   endtask

// ****************************************************************************              
   task wait_for_num_clocks(int num_clocks);
       repeat (num_clocks) @(posedge clk_i);
   endtask

// ****************************************************************************              
   task wait_for_interrupt();
       @(posedge irq_i);
   endtask

// ****************************************************************************              
   task reset_bus();
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        we_o <= 1'b0;
        adr_o <= 'b0;
        dat_o <= 'b0;
   endtask

// ****************************************************************************              
  task master_write(
                   input bit [ADDR_WIDTH-1:0]  addr,
                   input bit [DATA_WIDTH-1:0]  data
                   );  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= data;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b1;
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        @(posedge clk_i);

endtask        

// ****************************************************************************              
task master_read(
                 input bit [ADDR_WIDTH-1:0]  addr,
                 output bit [DATA_WIDTH-1:0] data
                 );                                                  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= 'bx;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b0;
        @(posedge clk_i);
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        data = dat_i;

endtask        

// ****************************************************************************              
     task master_monitor(
                   output bit [ADDR_WIDTH-1:0] addr,
                   output bit [DATA_WIDTH-1:0] data,
                   output bit we                    
                  );
                         
          while (!cyc_o) @(posedge clk_i);                                                  
          while (!ack_i) @(posedge clk_i);
          addr = adr_o;
          we = we_o;
          if (we_o) begin
            data = dat_o;
          end else begin
            data = dat_i;
          end
          while (cyc_o) @(posedge clk_i);                                                  
     endtask 

// ****************************************************************************              
///checking for IRQ is set is false after interrupt generation in same cycle 

    always_comb begin
        if(adr_o==2'b00 && write_transfer)begin
            CSR_bits.enable    = dat_o[7];
            CSR_bits.interrupt = dat_o[6];
            CSR_bits.bus_busy = 1'b0;
            CSR_bits.bus_capt = 1'b0;
            CSR_bits.bus_id = 3'b000;


        end 
        else CSR_bits = CSR_bits;
    end
          
    //checking for overlapping sequences  
    sequence seq_1;
        !CSR_bits.interrupt;
    endsequence
    sequence seq_2;
        !irq_i;
    endsequence
    property IRQ_is_set;
        @(posedge clk_i)    seq_1 |->seq_2;
    endproperty

    assert property(IRQ_is_set) 
        else begin
            $display("=======WARNING!!====Interrupt Misbehaved=========");
            $finish;
        end

// ****************************************************************************              
//checking if reserved bit are accessed
    always_comb begin
        if(adr_o== 2'b10 && read_transfer)
        begin
            CMDR_bits.done  =dat_o[7]; 
            CMDR_bits.Nack  =dat_o[6];
            CMDR_bits.arbit =dat_o[5];
            CMDR_bits.error =dat_o[4];
            CMDR_bits.r     =dat_o[3];
            CMDR_bits.cmd   = dat_o[2:0];
        end 
        else CMDR_bits = CMDR_bits;
    end
    property CMDR_bit_set;
        @(posedge clk_i) !CMDR_bits.r;
    endproperty
    assert property(CMDR_bit_set) else
    begin
            $display("=======WARNING!!====CMDR bits HACKED=========");
         $finish;      
    end


endinterface
