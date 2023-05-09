//my first package ever
//these package are just like libraries in C++
//all we need is to import them in where we want
//also add them into makefile

package operation;
    typedef enum bit {WRITE = 1'b0, READ = 1'b1} i2c_op_t;
    typedef enum logic[2:0] {IDLE ,START, STOP, ACTION} i2c_control_t;


endpackage 
