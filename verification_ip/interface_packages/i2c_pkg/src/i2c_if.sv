// typedef enum logic {WRITE,READ} i2c_op_t;
// typedef enum logic[2:0] {IDLE ,START, STOP, ACTION} i2c_control_t;

import operation::*;
interface i2c_if #(
	int I2C_ADDR_WIDTH = 7,
	int I2C_DATA_WIDTH = 8,
	int NUM_I2C_BUSSES = 1
	)
(
	input tri [NUM_I2C_BUSSES-1:0] scl,
	input triand [NUM_I2C_BUSSES-1:0] sda_i,
	output bit [NUM_I2C_BUSSES-1:0] sda_o
);
bit drive_bus_bit;
bit drive_data;

parameter bit ACK = 1'b0;
parameter bit NACK = 1'b1;

assign sda_o = drive_bus_bit ? drive_data : sda_i; 
bit repeated_start = 0;
i2c_control_t control;


task wait_for_i2c_transfer (output i2c_op_t op, 
							output bit [I2C_DATA_WIDTH-1:0] write_data []
							);

	bit RW_bit;
	bit [I2C_ADDR_WIDTH-1:0] address;
	bit [I2C_DATA_WIDTH-1:0] address_data;
	control = IDLE;
	if(!repeated_start)
	begin
		while(control != START)
		begin
			@(negedge sda_i)
			if(scl)	begin  //scl is positive
				control = START;
			end
		end
	end
	else if(repeated_start) begin
		write_data.delete();
	end
	repeated_start = 0;
	//First time start, get the address from the data line.
	for(int i = 6;i>=0;i--)
	begin
		@( posedge scl) address[i] = sda_i;
	end
	//Find out whether we need to read or write.
	@(posedge scl)
	RW_bit = sda_i;
	//The slave will drive now and sent the ACK bit.
	@(posedge scl) 
		drive_bus_bit = 1'b1;
		drive_data = ACK;
	//Write.	
	if(RW_bit == WRITE)	begin
		op = WRITE; //setting the op for the first time
		fork
			forever begin
				@(posedge sda_i)
				if(scl)	begin
					repeated_start = 0;
					control = STOP;
					// //$display("----WAIT I2C TASK STOP----");
					write_data.delete();
					break;
				end
			end

			forever begin
				@(negedge sda_i)
				if(scl)	begin
					// //$display("----REPEATED START----");
					control = START;
					repeated_start = 1;
					break;
				end
			end

			forever begin
				for(int k = 7; k>= 0;k--)
				begin
					@(posedge scl)
					drive_bus_bit = 0;
					address_data[k] = sda_i;
				end
				write_data = new[write_data.size()+1](write_data);
				write_data[write_data.size()-1] = address_data;
				//$display("the data written in the array is ====> %d",address_data); 

 
				@(posedge scl)
				drive_bus_bit = 1;
				drive_data = ACK;
				control = ACTION;
				repeated_start = 0;
				//$display("the data array ====> %p",write_data); 
			end
		join_any
		disable fork;
	end

	else if(RW_bit == READ)	begin
		op = READ; //setting the op 
		control = ACTION;
	end
	// //$display("End wait_for_i2c_transfer");


endtask

//////////////////////////////////////////////////////////////////////////////////////////////////
task monitor(output bit[I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data[]);
	//bit reading if it is read or write	
	bit [7:0] l_data;
	bit monitor_rw;
	data.delete();
	control = IDLE;
	if(!repeated_start)
	begin
		while(control != START)
			begin
				@(negedge sda_i)
				if(scl)	begin
					control = START;
					////$display("hit the start"); 
					// //$display("----MONITOR START----");

				end
			end
	end
	repeated_start = 0;
	@(negedge scl)
	for(int x = 6;x>=0;x--) begin
		@(negedge scl)
		begin
		addr[x] = sda_i;
		end
	end

	@(negedge scl) 
	// //$display("at first nextedge after loop check for the  read or write bit");
	monitor_rw = sda_i;
	//$diplay("at the next edge action");
	//set the op
	if(monitor_rw == READ)	begin
		@(negedge scl)
		op = READ;
		// ////$display("INSIDE THE MONITOR AND IT IS READ");
	end
	else if(monitor_rw == WRITE)begin
		@(negedge scl)
		op = WRITE;
		// ////$display("INSIDE THE MONITOR AND IT IS WRITE");

	end

	fork
		forever begin
			@(posedge sda_i)
			if(scl)	begin
				repeated_start = 0;
				control = STOP;
				//////$display("STOP condition met");
				break;
			end
		end

		forever begin
			@(negedge sda_i)
			if(scl)	begin
				// //$display("---- MONITOR REPEATED START----");
				control = START;
				repeated_start = 1;
				break;
			end
		end

		forever begin
			forever begin
				for(int k = 7; k>= 0;k--)
				begin
					@(negedge scl)
					// drive_bus_bit = 0;/
					l_data[k] = sda_o;
				end
				data = new[data.size()+1](data);
				data[data.size()-1] = l_data;
				// ////$display("data size is :%0d", data.size());
				@(negedge scl);
				// drive_bus_bit = 1;
				// drive_data = ACK;
				// control = ACTION;
				// repeated_start = 0;
				// ////$display("the data inside the address is :%d",write_data); 
			end
		end		
	join_any
	disable fork;
endtask

//////////////////////////////////////////////////////////////////////////////////////////////////
task provide_read_data( input bit [I2C_DATA_WIDTH-1:0] read_data[], 
						output bit transfer_complete
						);
	int transfer_status;
	bit temp_ack;
	control = START;
	//taversing through packed+unpacked array
	////$display("INSIDE THE PROVIDE READ DATA FUNCTION");
	// ////$display("Read data provide size is %0d", read_data.size());

	for(int i = 0; i < read_data.size();i++) 
	begin
		//$display("the data is = %0d" ,read_data[i]);
		// foreach (read_data[i][j]) begin
		for(int j = I2C_DATA_WIDTH-1;j>=0;j--)	begin
			@(posedge scl)
			drive_bus_bit = 1;
			drive_data = read_data[i][j];
		end
		
		@(posedge scl)
		drive_bus_bit = 0;
		temp_ack = sda_i;
		

		if(temp_ack == ACK)	begin
		transfer_status = 0;
		continue;
		end
		else if(temp_ack == NACK)	begin
			fork
			forever begin
				@(posedge sda_i)
				if(scl)	begin
					repeated_start = 0;
					control = STOP;
					drive_bus_bit = 0;
					transfer_status = 1;
					// //$display("----PROVIDE READ DATA TASK STOP----");

					//////$display("STOP condition met");
					break;
				end
			end
			// forever begin
			// 	for(int k = 7; k>= 0;k--)
			// 	begin
			// 		@(posedge scl)
			// 		drive_bus_bit = 0;
			// 		address_data[k] = sda_i;
			// 	end
			// 	write_data = new[write_data.size()+1](write_data);
			// 	write_data[write_data.size()-1] = address_data;

			// 	@(posedge scl)
			// 	drive_bus_bit = 1;
			// 	drive_data = ACK;
			// 	control = ACTION;
			// 	repeated_start = 0;
			// 	////$display("the data inside the address is :%d",write_data); 
			// end

			forever begin
				@(negedge sda_i)
				if(scl)	begin
					// //$display("Provide read data repeated start");
					// //$display("----REPEATED START----");

					control = START;
					repeated_start = 1;
					transfer_status = 1'b1;
					break;
				end
			end
			join_any
			disable fork;
			end
		//check the status of the transfer
		if(transfer_status) begin
				////$display("end of for loop ");
				break; //break from the loop
		end
	end
	transfer_complete = transfer_status;
endtask

endinterface











