`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module milestone1(
	input logic Clock,
	input logic Resetn,
	input logic enable,
	input logic [15:0] SRAM_read_data,
	output logic [15:0] M1_SRAM_write_data,
	output logic CSC_we_n,
	output logic done,
	output logic [17:0] M1_SRAM_address
	//test output
	/*
	output logic [17:0] tb_counter[2:0],
	output logic [17:0] common_counter,
	output logic[15:0] y_buf_t,
	output logic[15:0] u_buf_t,
	output logic[7:0] v_buf_t,
	output logic[31:0] u_odd_t,
	output logic[31:0] u_even_t,
	output logic[7:0] tb_u_shift[5:0],
	output logic[7:0] tb_v_shift[5:0],
	output logic[31:0] RGB_odd_t[2:0],
	output logic[7:0] RGB_odd_w_t[2:0],
	output logic[31:0] op_t[7:0],
	output logic[31:0] mult_t[3:0],
	output logic[17:0] t_rounds,
	output logic[31:0] u_str_t
	*/
);

M1_state_type M1_state;	
// Define the offset for RGB and UV in the memory		
parameter U_OFFSET = 18'd38400,
	  V_OFFSET = 18'd57600,
	  RGB_OFFSET = 18'd146944;

// Data counter for address
logic [17:0] counter[2:0]; //2 for y, 1 for uv 0 for RGB	
//test variable
//assign tb_counter=counter;


//flags
logic flag,lead_out;
//logic [17:0] flag_1;
logic [17:0] rounds;//assign t_rounds=rounds;
assign lead_out=(rounds==159)?1:0;
//multiplier
logic[63:0] mult[3:0]; 
logic[31:0] mult_32[3:0]; //assign mult_t=mult_32;
logic[31:0] op[7:0]; //assign op_t=op;
assign mult_32[3]=mult[3][31:0];
assign mult_32[2]=mult[2][31:0];
assign mult_32[1]=mult[1][31:0];
assign mult_32[0]=mult[0][31:0];
//YUV buffers & registers
logic[15:0] y_buf;//assign y_buf_t=y_buf;
logic[15:0] u_buf;//assign u_buf_t=u_buf;
logic[7:0] v_buf;//assign v_buf_t=v_buf;
logic[7:0] u_shift[5:0];//assign tb_u_shift=u_shift;
logic[7:0] v_shift[5:0];//assign tb_v_shift=v_shift;
logic[31:0] u_odd;//assign u_odd_t=u_odd;
logic[31:0] u_even;//assign u_even_t=u_even;
logic[31:0] v_odd;
logic[31:0] v_even;
logic[31:0] u_str;//assign u_str_t=u_str;
logic[31:0] v_str;
//CSC registers
logic[31:0] RGB_even[2:0];
logic[7:0] RGB_even_w[2:0];
logic[31:0] y_coe_e;
logic[31:0] RGB_odd[2:0];//assign RGB_odd_t=RGB_even;
logic[7:0] RGB_odd_w[2:0];//assign RGB_odd_w_t=RGB_odd_w;
logic[31:0] y_coe_o;

//multiplication
assign mult[0]=op[0]*op[1]; //u_odd 
assign mult[1]=op[2]*op[3]; //v_odd
assign mult[2]=op[4]*op[5]; //RGB_odd
assign mult[3]=op[6]*op[7]; //RGB_even

//RGB_clipping
assign RGB_even_w[2]=RGB_even[2][31]?0:(|{RGB_even[2][30:24]}?255:{RGB_even[2][23:16]});
assign RGB_even_w[1]=RGB_even[1][31]?0:(|{RGB_even[1][30:24]}?255:{RGB_even[1][23:16]});
assign RGB_even_w[0]=RGB_even[0][31]?0:(|{RGB_even[0][30:24]}?255:{RGB_even[0][23:16]});
assign RGB_odd_w[2]=RGB_odd[2][31]?0:(|{RGB_odd[2][30:24]}?255:{RGB_odd[2][23:16]});
assign RGB_odd_w[1]=RGB_odd[1][31]?0:(|{RGB_odd[1][30:24]}?255:{RGB_odd[1][23:16]});
assign RGB_odd_w[0]=RGB_odd[0][31]?0:(|{RGB_odd[0][30:24]}?255:{RGB_odd[0][23:16]});

//operand switch & SRAM_write_data switch
always_comb begin
	op[0]=0;op[1]=0;op[2]=0;op[3]=0;
	op[4]=0;op[5]=0;op[6]=0;op[7]=0;
	M1_SRAM_write_data=0;
	case(M1_state)
	S_LEAD_IN_7:begin 
	op[0]=21;op[1]={24'b0,u_shift[0]};
	op[2]=21;op[3]={24'b0,v_shift[0]};
	end
	S_LEAD_IN_8:begin 
	op[0]=52;op[1]={24'b0,u_shift[0]};
	op[2]=52;op[3]={24'b0,v_shift[0]};
	end
	S_LEAD_IN_9:begin 
	op[0]=159;op[1]={24'b0,u_shift[0]};
	op[2]=159;op[3]={24'b0,v_shift[0]};
	end
	S_LEAD_IN_10:begin
	op[0]=159;op[1]={24'b0,u_shift[0]};
	op[2]=159;op[3]={24'b0,v_shift[0]};
	end
	S_LEAD_IN_11:begin 
	op[0]=52;op[1]={24'b0,u_shift[0]};
	op[2]=52;op[3]={24'b0,v_shift[0]};
	end
	S_LEAD_IN_12:begin 
	op[0]=21;op[1]={24'b0,u_shift[0]};
	op[2]=21;op[3]={24'b0,v_shift[0]};
	end
	S_COMMON_0:begin 
	op[0]=21;op[1]={24'b0,u_shift[0]};
	op[2]=21;op[3]={24'b0,v_shift[0]};
	op[4]=(y_buf[7:0]-16);op[5]=76284;
	op[6]=(y_buf[15:8]-16);op[7]=76284;
	M1_SRAM_write_data={RGB_even_w[2],RGB_even_w[1]};
	end
	S_COMMON_1:begin 
	op[0]=52;op[1]={24'b0,u_shift[0]};
	op[2]=52;op[3]={24'b0,v_shift[0]};
	op[4]=(u_str[23:8]-128);op[5]=132251; //u and v only select 16 bit in  middle
	op[6]=(u_even-128);op[7]=132251;
	end
	S_COMMON_2:begin
	op[0]=159;op[1]={24'b0,u_shift[0]};
	op[2]=159;op[3]={24'b0,v_shift[0]};
	op[4]=(u_str[23:8]-128);op[5]=25624; //u and v only select 16 bit in  middle
	op[6]=(u_even-128);op[7]=25624;
	end
	S_COMMON_3:begin 
	op[0]=159;op[1]={24'b0,u_shift[0]};
	op[2]=159;op[3]={24'b0,v_shift[0]};
	op[4]=(v_str[23:8]-128);op[5]=53281; //u and v only select 16 bit in  middle
	op[6]=(v_even-128);op[7]=53281;
	
	end
	S_COMMON_4:begin 
	op[0]=52;op[1]={24'b0,u_shift[0]};
	op[2]=52;op[3]={24'b0,v_shift[0]};
	op[4]=(v_str[23:8]-128);op[5]=104595; //u and v only select 16 bit in  middle
	op[6]=(v_even-128);op[7]=104595;
	M1_SRAM_write_data={RGB_odd_w[1],RGB_odd_w[0]};
	end
	S_COMMON_5:begin 
	op[0]=21;op[1]={24'b0,u_shift[0]};
	op[2]=21;op[3]={24'b0,v_shift[0]};
	M1_SRAM_write_data={RGB_even_w[0],RGB_odd_w[2]};
	end
	
	S_LEAD_OUT_0:begin 
	op[4]=(y_buf[7:0]-16);op[5]=76284;
	op[6]=(y_buf[15:8]-16);op[7]=76284;
	M1_SRAM_write_data={RGB_even_w[2],RGB_even_w[1]};
	end
	S_LEAD_OUT_1:begin 
	op[4]=(u_str[23:8]-128);op[5]=132251; //u and v only select 16 bit in  middle
	op[6]=(u_even-128);op[7]=132251;
	end
	S_LEAD_OUT_2:begin 
	op[4]=(u_str[23:8]-128);op[5]=25624; //u and v only select 16 bit in  middle
	op[6]=(u_even-128);op[7]=25624;
	end
	S_LEAD_OUT_3:begin 
	op[4]=(v_str[23:8]-128);op[5]=53281; //u and v only select 16 bit in  middle
	op[6]=(v_even-128);op[7]=53281;
	end
	S_LEAD_OUT_4:begin 
	op[4]=(v_str[23:8]-128);op[5]=104595; //u and v only select 16 bit in  middle
	op[6]=(v_even-128);op[7]=104595;
	M1_SRAM_write_data={RGB_odd_w[1],RGB_odd_w[0]};
	end
	S_LEAD_OUT_5:begin 
	M1_SRAM_write_data={RGB_even_w[0],RGB_odd_w[2]};
	end
	S_LEAD_OUT_6:begin 
	M1_SRAM_write_data={RGB_even_w[2],RGB_even_w[1]};
	end
	endcase
end

always_ff @ (posedge Clock or negedge Resetn) begin
	if (Resetn == 1'b0) begin
		M1_state <= M1_IDLE;
	
		M1_SRAM_address <= 18'd0;
		
		done<=0;
		
		flag<=1;//flag_1<=0;
		rounds<=0;
		//M1_SRAM_write_data<=0;
		CSC_we_n<=1;
		counter[2]<=0;counter[1]<=0;counter[0]<=0;
		
		y_buf<=0;
		u_buf<=0;
		v_buf<=0;
		u_shift[5]<=0;u_shift[4]<=0;u_shift[3]<=0;
		u_shift[2]<=0;u_shift[1]<=0;u_shift[0]<=0;
		v_shift[5]<=0;v_shift[4]<=0;v_shift[3]<=0;
		v_shift[2]<=0;v_shift[1]<=0;v_shift[0]<=0;
		u_odd<=0;u_even<=0;
		v_odd<=0;v_even<=0;
		u_str=0;
		v_str=0;
		
		RGB_even[2]<=0;RGB_even[1]<=0;RGB_even[0]<=0;
		y_coe_e<=0;
		RGB_odd[2]<=0;RGB_odd[1]<=0;RGB_odd[0]<=0;
		y_coe_o<=0;
		//test
		//common_counter<=0;
	end else begin
			case (M1_state)
			M1_IDLE: begin
			M1_SRAM_address <= 18'd0;
			done<=0;
			//M1_SRAM_write_data<=0;
			CSC_we_n<=1;
			flag<=1;//flag_1<=0;
			rounds<=0;
			counter[2]<=0;counter[1]<=0;counter[0]<=0;
			y_buf<=0;
			u_buf<=0;
			v_buf<=0;
			u_shift[5]<=0;u_shift[4]<=0;u_shift[3]<=0;
			u_shift[2]<=0;u_shift[1]<=0;u_shift[0]<=0;
			v_shift[5]<=0;v_shift[4]<=0;v_shift[3]<=0;
			v_shift[2]<=0;v_shift[1]<=0;v_shift[0]<=0;
			u_odd<=0;u_even<=0;
			v_odd<=0;v_even<=0;
			u_str=0;
			v_str=0;
			RGB_even[2]<=0;RGB_even[1]<=0;RGB_even[0]<=0;
			y_coe_e<=0;
			RGB_odd[2]<=0;RGB_odd[1]<=0;RGB_odd[0]<=0;
			y_coe_o<=0;
			//test
			//common_counter<=0;
			
			if(!done&&enable)
			M1_state<=S_LEAD_IN_0;
			end
			

			S_LEAD_IN_0:begin 
			M1_SRAM_address<=U_OFFSET+counter[1]+1;
			
			M1_state<=S_LEAD_IN_1;
			end 
			
			S_LEAD_IN_1:begin 
			M1_SRAM_address<= V_OFFSET+counter[1]+1;
			
			M1_state<=S_LEAD_IN_2;
			end 
			
			S_LEAD_IN_2:begin 
			M1_SRAM_address<=U_OFFSET+counter[1];
			y_buf<= SRAM_read_data;
			
			M1_state<=S_LEAD_IN_3;
			end 
			
			S_LEAD_IN_3:begin
			M1_SRAM_address<=V_OFFSET+counter[1];
			u_buf<=SRAM_read_data;
			
			M1_state<=S_LEAD_IN_4;
			end 
			
			S_LEAD_IN_4:begin
			
			v_shift[1]<=SRAM_read_data[15:8];
			v_shift[0]<=SRAM_read_data[7:0];
			u_shift[1]<=u_buf[15:8];
			u_shift[0]<=u_buf[7:0];
			
			M1_state<=S_LEAD_IN_5;
			end

			S_LEAD_IN_5:begin 
			u_buf<=SRAM_read_data;
			u_shift[5]<=SRAM_read_data[15:8];
			u_shift[4]<=SRAM_read_data[15:8];
			u_shift[3]<=SRAM_read_data[15:8];
			u_shift[2]<=SRAM_read_data[7:0];
			M1_state<=S_LEAD_IN_6;
			end 
			
			S_LEAD_IN_6:begin
			v_shift[5]<=SRAM_read_data[15:8];
			v_shift[4]<=SRAM_read_data[15:8];
			v_shift[3]<=SRAM_read_data[15:8];
			v_shift[2]<=SRAM_read_data[7:0];
			M1_state<=S_LEAD_IN_7;
			end 
			
			S_LEAD_IN_7:begin 
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=21;op[1]<={24'b0,u_shift[0]};
			op[2]<=21;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=mult_32[0];v_odd<=mult_32[1];
			
			M1_state<=S_LEAD_IN_8;
			end 
			
			S_LEAD_IN_8:begin 
			M1_SRAM_address<=U_OFFSET+counter[1]+2;
			counter[1]<=counter[1]+2;
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=52;op[1]<={24'b0,u_shift[0]};
			op[2]<=52;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd-mult_32[0]+128;v_odd<=v_odd-mult_32[1]+128;
			
			M1_state<=S_LEAD_IN_9;
			end 
			
			S_LEAD_IN_9:begin 
			M1_SRAM_address<=V_OFFSET+counter[1];
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=159;op[1]<={24'b0,u_shift[0]};
			op[2]<=159;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd+mult_32[0];v_odd<=v_odd+mult_32[1];
			
			M1_state<=S_LEAD_IN_10;
			end 
			
			S_LEAD_IN_10:begin 
			
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=159;op[1]<={24'b0,u_shift[0]};
			op[2]<=159;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd+mult_32[0];v_odd<=v_odd+mult_32[1];
			
			M1_state<=S_LEAD_IN_11;
			end 
			
			S_LEAD_IN_11:begin 
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=52;op[1]<={24'b0,u_shift[0]};
			op[2]<=52;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd-mult_32[0];v_odd<=v_odd-mult_32[1];
			//
			u_buf<=SRAM_read_data;
			
			M1_state<=S_LEAD_IN_12;
			end
			
			S_LEAD_IN_12:begin
			v_buf<=SRAM_read_data[7:0];
			//
			counter[2]<=counter[2]+1;
			//insert new value
			u_shift[0]<=u_buf[15:8];v_shift[0]<=SRAM_read_data[15:8];
			/*
			op[0]<=21;op[1]<={24'b0,u_shift[0]};
			op[2]<=21;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd+mult_32[0];v_odd<=v_odd+mult_32[1];
			//storage even UV
			u_even<={24'b0,u_shift[4]};v_even<={24'b0,v_shift[4]};
			
			M1_state<=S_COMMON_0;
			end
			
			
			S_COMMON_0:begin 
			//common_counter<=common_counter+1;
			//read mode
			CSC_we_n<=1;
			M1_SRAM_address<=counter[2];
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			//
			
			rounds<=rounds+1;
			/*
			op[0]<=21;op[1]<={24'b0,u_shift[0]};
			op[2]<=21;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=mult_32[0];v_odd<=mult_32[1];
			//storage previous odd value
			u_str<=u_odd;v_str<=v_odd;
			//RGB_odd
			//op[4]<=(y_buf[7:0]-16);op[5]<=76284;
			y_coe_o<=mult_32[2];
			RGB_odd[0]<=mult_32[2];
			//RGB_even
			//op[6]<=(y_buf[15:8]-16);op[7]<=76284;
			y_coe_e<=mult_32[3];
			RGB_even[0]<=mult_32[3];
			/*
			if(flag&&rounds<155)
			v_buf<=SRAM_read_data[7:0];
			
			if(rounds>0)begin
			CSC_we_n<=0;//write mode
			M1_SRAM_address<=counter[0]+RGB_OFFSET-2;
			M1_SRAM_write_data<={RGB_even_w[2],RGB_even_w[1]};
			counter[0]<=counter[0]+1;
			end*/
			
			if(!flag)
			counter[1]<=counter[1]+1;
			
			M1_state<=S_COMMON_1;
			end
			
			S_COMMON_1:begin
			//common_counter<=common_counter+1;
			
			//counter[0]<=counter[0]+1;
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=52;op[1]<={24'b0,u_shift[0]};
			op[2]<=52;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd-mult_32[0]+128;v_odd<=v_odd-mult_32[1]+128;
			//RGB_odd
			//op[4]<=(u_str[23:8]-128);op[5]<=132251; //u and v only select 16 bit in  middle
			RGB_odd[0]<=mult_32[2]+RGB_odd[0];
			//RGB_even
			//op[6]<=(u_even-128);op[7]<=132251;
			RGB_even[0]<=mult_32[3]+RGB_even[0];
			//
			
			
			if(!flag)
			M1_SRAM_address<=counter[1]+U_OFFSET;
			
			M1_state<=S_COMMON_2;
			end
			
			S_COMMON_2:begin
			//common_counter<=common_counter+1;
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=159;op[1]<={24'b0,u_shift[0]};
			op[2]<=159;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd+mult_32[0];v_odd<=v_odd+mult_32[1];
			//RGB_odd
			//op[4]<=(u_str[23:8]-128);op[5]<=25624; //u and v only select 16 bit in  middle
			RGB_odd[1]<=y_coe_o-mult_32[2];
			//RGB_even
			//op[6]<=(u_even-128);op[7]<=25624;
			RGB_even[1]<=y_coe_e-mult_32[3];
			if(!flag)
			M1_SRAM_address<=counter[1]+V_OFFSET;
			
			M1_state<=S_COMMON_3;
			end
			
			S_COMMON_3:begin
			//common_counter<=common_counter+1;
			y_buf<=SRAM_read_data;
			counter[2]<=counter[2]+1;
			//write mode
			CSC_we_n<=0;
			M1_SRAM_address<=counter[0]+RGB_OFFSET+2;
			counter[0]<=counter[0]+1;
			//M1_SRAM_write_data<={RGB_odd_w[1],RGB_odd_w[0]};
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=159;op[1]<={24'b0,u_shift[0]};
			op[2]<=159;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd+mult_32[0];v_odd<=v_odd+mult_32[1];
			//RGB_odd
			//op[4]<=(v_str[23:8]-128);op[5]<=53281; //u and v only select 16 bit in  middle
			RGB_odd[1]<=RGB_odd[1]-mult_32[2];
			//RGB_even
			//op[6]<=(v_even-128);op[7]<=53281;
			RGB_even[1]<=RGB_even[1]-mult_32[3];

			M1_state<=S_COMMON_4;
			end
			
			S_COMMON_4:begin
			//common_counter<=common_counter+1;
			//write mode
			CSC_we_n<=0;
			M1_SRAM_address<=counter[0]+RGB_OFFSET;
			counter[0]<=counter[0]+1;
			//M1_SRAM_write_data<={RGB_even_w[0],RGB_odd_w[2]};
			//shift
			u_shift[5]<=u_shift[0];u_shift[4]<=u_shift[5];
			u_shift[3]<=u_shift[4];u_shift[2]<=u_shift[3];
			u_shift[1]<=u_shift[2];u_shift[0]<=u_shift[1];
			v_shift[5]<=v_shift[0];v_shift[4]<=v_shift[5];
			v_shift[3]<=v_shift[4];v_shift[2]<=v_shift[3];
			v_shift[1]<=v_shift[2];v_shift[0]<=v_shift[1];
			/*
			op[0]<=52;op[1]<={24'b0,u_shift[0]};
			op[2]<=52;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd-mult_32[0];v_odd<=v_odd-mult_32[1];
			//RGB_odd
			//op[4]<=(v_str[23:8]-128);op[5]<=104595; //u and v only select 16 bit in  middle
			RGB_odd[2]<=y_coe_o+mult_32[2];
			//RGB_even
			//op[6]<=(v_even-128);op[7]<=104595;
			RGB_even[2]<=y_coe_e+mult_32[3];
			//
			if(!flag)
			u_buf<=SRAM_read_data;
			
			M1_state<=S_COMMON_5;
			end
			
			S_COMMON_5:begin
			//common_counter<=0;
			//write mode
			CSC_we_n<=0;
			M1_SRAM_address<=counter[0]+RGB_OFFSET-2;
			//M1_SRAM_write_data<={RGB_even_w[2],RGB_even_w[1]};
			counter[0]<=counter[0]+1;
			/*
			op[0]<=21;op[1]<={24'b0,u_shift[0]};
			op[2]<=21;op[3]<={24'b0,v_shift[0]};*/
			u_odd<=u_odd+mult_32[0];v_odd<=v_odd+mult_32[1];
			//even value storage
			u_even<={24'b0,u_shift[4]};v_even<={24'b0,v_shift[4]};
			//u value update
			u_shift[0]<=u_buf[15:8];v_shift[0]<=SRAM_read_data[15:8];
			if(flag)begin
			//u_buf<=SRAM_read_data;
			u_shift[0]<=u_buf[7:0];v_shift[0]<=v_buf;
			end
			
			if(!flag&&rounds<155)
			v_buf<=SRAM_read_data[7:0];
			if(lead_out)
			M1_state<=S_LEAD_OUT_0;
			else begin
			M1_state<=S_COMMON_0;
			if(rounds<155)
			flag<=~flag;
			end
			end
			
			S_LEAD_OUT_0:begin 
			CSC_we_n<=1;//read mode
			M1_SRAM_address<=counter[2];
			//clear rounds and flag_1
			rounds<=0;
			//flag_1<=0;
			//
			//counter[2]<=counter[2]+1;
			//storage previous odd value
			u_str<=u_odd;v_str<=v_odd;
			//RGB_odd
			//op[4]<=(y_buf[7:0]-16);op[5]<=76284;
			y_coe_o<=mult_32[2];
			RGB_odd[0]<=mult_32[2];
			//RGB_even
			//op[6]<=(y_buf[15:8]-16);op[7]<=76284;
			y_coe_e<=mult_32[3];
			RGB_even[0]<=mult_32[3];
			//
			
			M1_state<=S_LEAD_OUT_1;
			end 
						
			S_LEAD_OUT_1:begin
			
			//RGB_odd
			//op[4]<=(u_str[23:8]-128);op[5]<=132251; //u and v only select 16 bit in  middle
			RGB_odd[0]<=mult_32[2]+RGB_odd[0];
			//RGB_even
			//op[6]<=(u_even-128);op[7]<=132251;
			RGB_even[0]<=mult_32[3]+RGB_even[0];
			//
			
			M1_state<=S_LEAD_OUT_2;
			end 

			S_LEAD_OUT_2:begin 
			//RGB_odd
			//op[4]<=(u_str[23:8]-128);op[5]<=25624; //u and v only select 16 bit in  middle
			RGB_odd[1]<=y_coe_o-mult_32[2];
			//RGB_even
			//op[6]<=(u_even-128);op[7]<=25624;
			RGB_even[1]<=y_coe_e-mult_32[3];
			
			M1_state<=S_LEAD_OUT_3;
			end 
			
			S_LEAD_OUT_3:begin 
			//write mode
			CSC_we_n<=0;
			M1_SRAM_address<=counter[0]+RGB_OFFSET+2;
			counter[0]<=counter[0]+1;
			//RGB_odd
			//op[4]<=(v_str[23:8]-128);op[5]<=53281; //u and v only select 16 bit in  middle
			RGB_odd[1]<=RGB_odd[1]-mult_32[2];
			//RGB_even
			//op[6]<=(v_even-128);op[7]<=53281;
			RGB_even[1]<=RGB_even[1]-mult_32[3];
			//
			M1_state<=S_LEAD_OUT_4;
			end 
			
			S_LEAD_OUT_4:begin 
			//write mode
			CSC_we_n<=0;
			M1_SRAM_address<=counter[0]+RGB_OFFSET;
			counter[0]<=counter[0]+1;
			//M1_SRAM_write_data<={RGB_odd_w[1],RGB_odd_w[0]};
			//RGB_odd
			//op[4]<=(v_str[23:8]-128);op[5]<=104595; //u and v only select 16 bit in  middle
			RGB_odd[2]<=y_coe_o+mult_32[2];
			//RGB_even
			//op[6]<=(v_even-128);op[7]<=104595;
			RGB_even[2]<=y_coe_e+mult_32[3];
			
			M1_state<=S_LEAD_OUT_5;
			end 
			
			S_LEAD_OUT_5:begin 
			//write mode
			CSC_we_n<=0;
			M1_SRAM_address<=counter[0]+RGB_OFFSET-2;
			counter[0]<=counter[0]+1;
			//M1_SRAM_write_data<={RGB_even_w[0],RGB_odd_w[2]};
			
			M1_state<=S_LEAD_OUT_6;
			end 
			
			S_LEAD_OUT_6:begin 
			CSC_we_n<=1;
			counter[1]<=counter[1]+1;
			//M1_SRAM_write_data<={RGB_even_w[2],RGB_even_w[1]};
			M1_SRAM_address<=counter[2];
			
			M1_state<=S_LEAD_IN_0;
			if(counter[2]>=U_OFFSET)
			M1_state<=S_FINISH_FILL_SRAM;
			end 
			
			
			
			S_FINISH_FILL_SRAM:begin
			CSC_we_n <= 1'b1;
			done<=1;
			
			M1_state<=M1_IDLE;
			end
			
			default: M1_state<=M1_IDLE;
		endcase
	end
end	
			
			
endmodule
