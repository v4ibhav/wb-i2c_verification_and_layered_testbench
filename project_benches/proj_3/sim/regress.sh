make     cli 	GEN_TRANS_TYPE=i2cmb_direct_test 				TEST_SEED=543210
make run_cli 	GEN_TRANS_TYPE=i2cmb_register_test 				TEST_SEED=random
make run_cli 	GEN_TRANS_TYPE=i2cmb_random_write_test 		TEST_SEED=random
make run_cli 	GEN_TRANS_TYPE=i2cmb_random_read_test 			TEST_SEED=random
make run_cli 	GEN_TRANS_TYPE=i2cmb_random_read_write_test 	TEST_SEED=random

make merge_coverage
