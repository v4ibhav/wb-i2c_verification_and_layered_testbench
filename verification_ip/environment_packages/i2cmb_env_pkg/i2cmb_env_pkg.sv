package i2cmb_env_pkg;

	import ncsu_pkg::*;
	import wb_pkg::*;
	import i2c_pkg::*;
	import operation::*;
	
	
	// `include "ncsu_macros.svh"
	`include "src/i2cmb_env_configuration.svh"
	`include "src/i2cmb_scoreboard.svh"
	`include "src/i2cmb_predictor.svh"
	`include "src/i2cmb_coverage.svh"
	`include "src/i2cmb_environment.svh"
	// `include "src/i2cmb_generator.svh"
	`include "src/i2cmb_Direct_Test_Gen.svh"
	`include "src/i2cmb_Register_Test_Gen.svh"
	// `include "src/i2cmb_Rand_Read_Test_Gen.svh"
	// `include "src/i2cmb_Rand_Write_Test_Gen.svh"
	// `include "src/i2cmb_Rand_Read_Write_Test_Gen.svh"

	//include newly created files here
	// `include "src/i2cmb_Direct_Test.svh"
	`include "src/i2cmb_test.svh"


endpackage : i2cmb_env_pkg

