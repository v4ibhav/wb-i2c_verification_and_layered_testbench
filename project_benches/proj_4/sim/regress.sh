make	cli 	GEN_TRANS_TYPE=transition_test			TEST_SEED=543210
make	run_cli 	GEN_TRANS_TYPE=register_reset_test			TEST_SEED=543210
make	run_cli 	GEN_TRANS_TYPE=register_aliasing_test		TEST_SEED=543210
make	run_cli 	GEN_TRANS_TYPE=register_default_test		TEST_SEED=543210
make	run_cli 	GEN_TRANS_TYPE=register_access_test			TEST_SEED=543210
make 	run_cli 	GEN_TRANS_TYPE=i2cmb_random_write_test 		TEST_SEED=random
make 	run_cli 	GEN_TRANS_TYPE=i2cmb_random_read_test 		TEST_SEED=random
make 	run_cli 	GEN_TRANS_TYPE=i2cmb_random_read_write_test TEST_SEED=random
make 	run_cli 	GEN_TRANS_TYPE=i2cmb_direct_test 				TEST_SEED=random

make merge_coverage

