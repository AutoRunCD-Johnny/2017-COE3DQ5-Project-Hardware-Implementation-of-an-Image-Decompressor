`ifndef DEFINE_STATE

// This defines the states
typedef enum logic [2:0] {
	S_IDLE,
	S_ENABLE_UART_RX,
	S_WAIT_UART_RX,
	//new top state
	S_M3,
	S_M2,
	S_M1
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

//milestone 1 state
typedef enum logic[4:0]{
	//interpolation & CSC	
	M1_IDLE,
	S_LEAD_IN_0,S_LEAD_IN_1,S_LEAD_IN_2,
	S_LEAD_IN_3,S_LEAD_IN_4,S_LEAD_IN_5,
	S_LEAD_IN_6,S_LEAD_IN_7,S_LEAD_IN_8,
	S_LEAD_IN_9,S_LEAD_IN_10,S_LEAD_IN_11,
	S_LEAD_IN_12,
	
	S_COMMON_0,S_COMMON_1,S_COMMON_2,
	S_COMMON_3,S_COMMON_4,S_COMMON_5,
		
	S_LEAD_OUT_0,S_LEAD_OUT_1,S_LEAD_OUT_2,
	S_LEAD_OUT_3,S_LEAD_OUT_4,S_LEAD_OUT_5,
	S_LEAD_OUT_6,
	
	S_FINISH_FILL_SRAM
} M1_state_type;

//milestone 2 state
typedef enum logic[2:0]{	
	M2_IDLE,
	
	M2_BEGIN_0,M2_BEGIN_1,
	
	M2_COMMON_0,M2_COMMON_1,
		
	M2_END_0,M2_END_1,
	
	M2_done
} M2_state_type;

//milestone 3 state
typedef enum logic[2:0]{
	M3_IDLE,
	M3_head,
	M3_fetch,
	M3_buf,
	M3_decode,
	M3_wait,
	M3_done
}M3_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

`define DEFINE_STATE 1
`endif
