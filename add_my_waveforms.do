

# add waves to waveform
add wave Clock_50
add wave -divider {some label for my divider}
add wave uut/top_state
add wave -unsigned uut/SRAM_address
#add wave -unsigned uut/M1_SRAM_address
add wave -hexadecimal uut/SRAM_read_data
add wave uut/SRAM_we_n
#add wave uut/CSC_we_n
add wave -hexadecimal uut/SRAM_write_data
#add wave -decimal uut/M1_SRAM_write_data
add wave uut/M1_enable
add wave uut/M1_done
add wave uut/M3_enable
add wave uut/M3_done
#add wave -unsigned uut/tb_counter
#add wave -unsigned uut/common_counter
#add wave -unsigned uut/t_rounds
#add wave -hexadecimal uut/y_buf_t
#add wave -hexadecimal uut/u_buf_t
#add wave -hexadecimal uut/v_buf_t
#add wave -hexadecimal uut/u_even_t
#add wave -hexadecimal uut/tb_u_shift
#add wave -hexadecimal uut/tb_v_shift
#add wave -decimal uut/u_str_t
#add wave -decimal uut/RGB_odd_t
#add wave -decimal uut/RGB_odd_w_t
#add wave -decimal uut/u_odd_t
#add wave -decimal uut/op_t;
#add wave -decimal uut/mult_t;

#add wave uut/tb_counter_en;
#add wave -unsigned uut/tb_counter;
#add wave -unsigned uut/tb_common_count;
#add wave -unsigned uut/tb_check_count;
#add wave -unsigned uut/tb_Ca;
#add wave -decimal uut/op_t;
#add wave -unsigned uut/tb_op_count;
#add wave -hexadecimal uut/tb_write_data_a;
#add wave -hexadecimal uut/tb_write_data_b;
#add wave uut/tb_write_enable_a;
#add wave uut/tb_write_enable_b;
#add wave -unsigned uut/tb_addr_a;
#add wave -unsigned uut/tb_addr_b;

add wave uut/M3_unit/M3_state;
add wave uut/M3_unit/M2_unit/M2_state;
add wave uut/M3_unit/M2_enable;
add wave -binary uut/M3_unit/buffer;
add wave -unsigned uut/M3_unit/remain;
add wave -binary uut/M3_unit/header;
add wave -unsigned uut/M3_unit/check;
add wave -unsigned uut/M3_unit/Q_mat;
add wave -unsigned uut/M3_unit/dp_count;
add wave -unsigned uut/M3_unit/M2_unit/counter;
add wave -unsigned uut/M3_unit/M2_unit/check_count;
add wave uut/M3_unit/M2_unit/CC;
add wave -decimal uut/M3_unit/M2_unit/Ct;
add wave -unsigned uut/M3_unit/M2_unit/Rb;
add wave -unsigned uut/M3_unit/M2_unit/Cb;
add wave -unsigned uut/M3_unit/M2_unit/common_count;
add wave -unsigned uut/M3_unit/addr_a;
add wave -unsigned uut/M3_unit/addr_b;
add wave -unsigned uut/M3_unit/M2_unit/addr_a;
add wave -unsigned uut/M3_unit/M2_unit/addr_b;
add wave -decimal uut/M3_unit/read_data_a;
add wave -decimal uut/M3_unit/read_data_b;
add wave uut/M3_unit/write_enable_a;
add wave -decimal uut/M3_unit/write_data_a;
add wave uut/M3_unit/write_enable_b;
add wave -decimal uut/M3_unit/write_data_b;
add wave -decimal uut/M3_unit/raw_write;
add wave -unsigned uut/M3_unit/block_counter;
add wave -decimal uut/M3_unit/M2_unit/op;
add wave -decimal uut/M3_unit/M2_unit/C1_w;
add wave -decimal uut/M3_unit/M2_unit/C2_w;

