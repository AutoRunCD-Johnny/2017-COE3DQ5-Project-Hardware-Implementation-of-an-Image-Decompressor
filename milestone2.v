`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module milestone2(
	input logic Clock,
	input logic Resetn,
	input logic enable,
	input logic clean,
	input logic [31:0] dp_read_a[1:0],
	input logic [31:0] dp_read_b[1:0],
	output logic [6:0] dp_addr_a[1:0],
	output logic [6:0] dp_addr_b[1:0],
//	output logic [31:0] dp_write_a[1:0],
//	output logic [31:0] dp_write_b[1:0],
//	output logic dp_we_a[1:0],
//	output logic dp_we_b[1:0],
	output logic [17:0] M2_SRAM_address,
	output logic [15:0] M2_SRAM_write_data,
	output logic IDCT_we_n,
	output logic done,
	output logic fetch
);

M2_state_type M2_state;	

parameter U_OFFSET=38400,
	V_OFFSET=57600;

logic [5:0] counter;//uppper 3b for Ri lower 3b for Ci
logic [5:0] Cb;//1 is one block faster than 0//only use during SRAM RW
logic [4:0] Rb;//only use during SRAM RW
logic [8:0] Ca;//only use during SRAM RW
logic [7:0] Ra;//only use during SRAM RW
logic counter_en;
assign Ra={Rb,counter[4:2]};
assign Ca={1'b0,Cb,counter[1:0]};
//DP-RAM
logic [31:0] read_data_a[1:0];
logic [31:0] read_data_b[1:0];
logic [31:0] write_data_a[1:0];	
logic [31:0] write_data_b[1:0];	
logic write_enable_a[1:0];	
logic write_enable_b[1:0];
logic [4:0] addr_a[1:0];
logic [4:0] addr_b[1:0];

//
logic y_done;//when y finish, the upper limit of Cb helve (40 to 20)
logic uv_done;
//
logic [31:0] C1[1:0];
logic [31:0] C1_w;
assign C1_w={C1[1][23:8],C1[0][23:8]};//the middle 16 bit
logic [31:0] S[1:0];
logic [7:0] S_w[1:0];
logic [31:0] C2_w;
assign C2_w={{8'b0,S_w[1]},{8'b0,S_w[0]}};

//logic [4:0] ram_count[3:0];
//logic [3:0] coe_count;
//logic [31:0] coe_buf[3:0];
//logic coe_flag;
logic [5:0] op_count;
logic [7:0] check_count;
logic [12:0] common_count;
//logic row_done;
//logic row_done_buf;
//assign row_done=&coe_count;
//logic clear;
//logic clear_buf;
logic [5:0] upper_Cb;
assign upper_Cb=(!y_done)?39:19;

//multiplier
logic[63:0] mult[3:0]; 
logic[31:0] mult_32[3:0]; 
logic[31:0] mult_32_buf[3:0];
logic[31:0] op[7:0]; 
assign mult_32[3]=mult[3][31:0];
assign mult_32[2]=mult[2][31:0];
assign mult_32[1]=mult[1][31:0];
assign mult_32[0]=mult[0][31:0];

//multiplication
assign mult[0]=op[0]*op[1]; //R0=A0*B0
assign mult[1]=op[2]*op[3]; //R1=A1*B1
assign mult[2]=op[4]*op[5]; //R2=A2*B2
assign mult[3]=op[6]*op[7]; //R3=A3*B3

//clipping
assign S_w[1]=S[1][31]?0:(|{S[1][30:24]}?255:{S[1][23:16]});
assign S_w[0]=S[0][31]?0:(|{S[0][30:24]}?255:{S[0][23:16]});


enum logic[2:0]{
	CC_0,CC_1,
	CC_2,CC_3,
	CC_4,CC_5
}CC;


// Instantiate RAM0
// 48 locations. 32bit per location
dual_port_RAM1 dual_port_RAM_inst0 (
	.address_a ( addr_a[0] ),
	.address_b ( addr_b[0] ),
	.clock ( Clock ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);

	// Instantiate RAM2
// 32 locations. 32bit per location
dual_port_RAM2 dual_port_RAM_inst1 (
	.address_a ( addr_a[1] ),
	.address_b ( addr_b[1] ),
	.clock ( Clock ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);
logic[15:0] Ct[3:0];

IDCT_mat IDCT_unit(
	//.M2_state(M2_state),
	.counter(check_count),
	.Ct(Ct)
);



always_comb begin
	//default
	M2_SRAM_address=0;
	op[1]=0;op[3]=0;op[5]=0;op[7]=0;
	write_enable_a[0]=0;write_enable_b[0]=0;
	//dp_we_a[1]=0;dp_we_b[1]=0;
	//dp_we_a[0]=0;dp_we_b[0]=0;
	write_enable_a[1]=0;write_enable_b[1]=0;
	write_data_a[0]=0;write_data_b[0]=0;
	//dp_write_a[1]=0;dp_write_b[1]=0;
	//dp_write_a[0]=0;dp_write_b[0]=0;
	write_data_a[1]=0;write_data_b[1]=0;
	IDCT_we_n=1;
	M2_SRAM_write_data=0;
	counter_en=0;
	//clear=0;
	
	op[0]=(Ct[0][15])?{16'hffff,Ct[0][15:0]}:{16'h0,Ct[0][15:0]};
	op[2]=(Ct[1][15])?{16'hffff,Ct[1][15:0]}:{16'h0,Ct[1][15:0]};
	op[4]=(Ct[2][15])?{16'hffff,Ct[2][15:0]}:{16'h0,Ct[2][15:0]};
	op[6]=(Ct[3][15])?{16'hffff,Ct[3][15:0]}:{16'h0,Ct[3][15:0]};
	
	case(M2_state)
	M2_BEGIN_1:begin

	op[1]=(dp_read_a[1][15])?{16'hffff,dp_read_a[1][15:0]}:{16'b0,dp_read_a[1][15:0]};	
	op[3]=(dp_read_a[0][15])?{16'hffff,dp_read_a[0][15:0]}:{16'b0,dp_read_a[0][15:0]};
	op[5]=(dp_read_b[1][15])?{16'hffff,dp_read_b[1][15:0]}:{16'b0,dp_read_b[1][15:0]};
	op[7]=(dp_read_b[0][15])?{16'hffff,dp_read_b[0][15:0]}:{16'b0,dp_read_b[0][15:0]};
	
	M2_SRAM_address={Ra,7'b0}+{Ra,5'b0}+Ca;
	if(y_done)begin
	//160/2 so 80=64+16
		M2_SRAM_address=U_OFFSET+{Ra,6'b0}+{Ra,4'b0}+Ca;
		if(uv_done)
			M2_SRAM_address=V_OFFSET+{Ra,6'b0}+{Ra,4'b0}+Ca;
	end
	
	if(check_count<33 && check_count>0 && common_count>0)begin
	IDCT_we_n=0;
	M2_SRAM_write_data={read_data_a[0][23:16],read_data_a[0][7:0]};
	counter_en=1;
	end
	if(CC==CC_5)begin
	//enable RAM2 write
	write_enable_a[1]=1;
	write_data_a[1]=C1_w;
	end
	end
	

	
	M2_END_0:begin
	
	op[1]=(read_data_a[1][31])?{16'hFFFF,read_data_a[1][31:16]}:{16'b0,read_data_a[1][31:16]};
	op[3]=(read_data_a[1][15])?{16'hFFFF,read_data_a[1][15:0]}:{16'b0,read_data_a[1][15:0]};
	op[5]=(read_data_b[1][31])?{16'hFFFF,read_data_b[1][31:16]}:{16'b0,read_data_b[1][31:16]};
	op[7]=(read_data_b[1][15])?{16'hFFFF,read_data_b[1][15:0]}:{16'b0,read_data_b[1][15:0]};
	
	//counter_en=1;
	//if(check_count>63)begin
	//counter_en=0;
	//clear=1;
	//end
	
	if(CC==CC_5)begin
	//enable RAM1 write
	//dp_we_b[0]=1;
	//dp_write_b[0]=C2_w;
	write_enable_b[0]=1;
	write_data_b[0]=C2_w;
	end
	end
	
	M2_END_1:begin
	M2_SRAM_address=V_OFFSET+{Ra,6'b0}+{Ra,4'b0}+Ca;
		
	if(check_count<33 && check_count>0)begin
	IDCT_we_n=0;
	M2_SRAM_write_data={read_data_a[0][23:16],read_data_a[0][7:0]};
	counter_en=1;
	end
	end
	
	endcase
end


always_ff@(posedge Clock or negedge Resetn)begin	
	if (Resetn == 1'b0) begin
		M2_state<=M2_IDLE;
		//row_done_buf<=0;
		
		C1[1]<=0;C1[0]<=0;
		S[1]<=0;S[0]<=0;
		
		done<=0;fetch<=0;
		CC<=CC_0;
			
		check_count<=0;common_count<=0;
		
		addr_a[0]<=0;addr_b[0]<=0;
		dp_addr_a[0]<=0;dp_addr_b[0]<=0;
		addr_a[1]<=0;addr_b[1]<=0;
		dp_addr_a[1]<=0;dp_addr_b[1]<=0;
		
		op_count<=0;
		mult_32_buf[3]<=0;mult_32_buf[2]<=0;mult_32_buf[1]<=0;mult_32_buf[0]<=0;
	end
	else begin
	//row_done_buf<=row_done;
	
	
	case(M2_state)
	M2_IDLE:begin
		C1[1]<=0;C1[0]<=0;
		S[1]<=0;S[0]<=0;
		
		CC<=CC_0;fetch<=0;
		done<=0;
		
		check_count<=0;common_count<=0;
		
		addr_a[0]<=0;addr_b[0]<=1;
		dp_addr_a[0]<=0;dp_addr_b[0]<=1;
		addr_a[1]<=0;addr_b[1]<=1;
		dp_addr_a[1]<=0;dp_addr_b[1]<=1;
		
	
		op_count<=0;
		mult_32_buf[3]<=0;mult_32_buf[2]<=0;mult_32_buf[1]<=0;mult_32_buf[0]<=0;
		if(!done&&enable)
		M2_state<=M2_BEGIN_1;
	end
	
	M2_BEGIN_1:begin //C1
	
	check_count<=check_count+1;
	dp_addr_a[1]<=dp_addr_a[1]+2;
	dp_addr_b[1]<=dp_addr_b[1]+2;
	dp_addr_a[0]<=dp_addr_a[0]+2;
	dp_addr_b[0]<=dp_addr_b[0]+2;
	
	if(check_count<33  && common_count>0)
	addr_a[0]<=addr_a[0]+1;
	

	if(dp_addr_a[1]==30)begin
	dp_addr_a[1]<=0;
	dp_addr_b[1]<=1;
	dp_addr_a[0]<=0;
	dp_addr_b[0]<=1;
	end
	
	case(CC)
	CC_0:begin 
	CC<=CC_1;
	end
	
	CC_1:begin 
	//storage multiplication result
	mult_32_buf[3]<=mult_32[3];mult_32_buf[2]<=mult_32[2];
	mult_32_buf[1]<=mult_32[1];mult_32_buf[0]<=mult_32[0];
	CC<=CC_2;	
	end
	
	CC_2:begin 
	C1[1]<=mult_32[3]+mult_32[2]+mult_32[1]+mult_32[0]
	+mult_32_buf[3]+mult_32_buf[2]+mult_32_buf[1]+mult_32_buf[0];
	CC<=CC_3;
	end
	
	CC_3:begin 

	//storage multiplication result
	mult_32_buf[3]<=mult_32[3];mult_32_buf[2]<=mult_32[2];
	mult_32_buf[1]<=mult_32[1];mult_32_buf[0]<=mult_32[0];
	CC<=CC_4;
	end
	
	CC_4:begin 
	C1[0]<=mult_32[3]+mult_32[2]+mult_32[1]+mult_32[0]
	+mult_32_buf[3]+mult_32_buf[2]+mult_32_buf[1]+mult_32_buf[0];
	CC<=CC_5;
	end
	
	CC_5:begin
	op_count<=op_count+1;
	//storage multiplication result
	mult_32_buf[3]<=mult_32[3];mult_32_buf[2]<=mult_32[2];
	mult_32_buf[1]<=mult_32[1];mult_32_buf[0]<=mult_32[0];

	addr_a[1]<=addr_a[1]+1;
	CC<=CC_2;
	if(op_count==31)begin
		M2_state<=M2_END_0;
		//counter_en<=1;
		//dp_we_a[1]<=0;dp_we_b[1]<=0;dp_we_a[0]<=0;dp_we_b[0]<=0;
		common_count<=common_count+1;
		op_count<=0;fetch<=~fetch;
		addr_a[0]<=0;addr_b[0]<=0;
		dp_addr_a[0]<=0;dp_addr_b[0]<=1;
		addr_a[1]<=0;addr_b[1]<=1;
		dp_addr_a[1]<=0;dp_addr_b[1]<=1;
		check_count<=0;
		CC<=CC_0;
		end
	end
	
	endcase
	end
	
	
	M2_END_0:begin //C2
	
	check_count<=check_count+1;
	addr_a[1]<=addr_a[1]+2;
	addr_b[1]<=addr_b[1]+2;
	if(addr_a[1]==30)begin
	addr_a[1]<=0;
	addr_b[1]<=1;
	end
	case(CC)
	CC_0:begin

		CC<=CC_1;
	end
	CC_1:begin 
	
		//storage multiplication result
		mult_32_buf[3]<=mult_32[3];mult_32_buf[2]<=mult_32[2];
		mult_32_buf[1]<=mult_32[1];mult_32_buf[0]<=mult_32[0];
		CC<=CC_2;
	end
	
	CC_2:begin 
		
		//
		S[1]<=mult_32[3]+mult_32[2]+mult_32[1]+mult_32[0]
		+mult_32_buf[3]+mult_32_buf[2]+mult_32_buf[1]+mult_32_buf[0];
		
		CC<=CC_3;
	end
	CC_3:begin
		//storage multiplication result
		mult_32_buf[3]<=mult_32[3];mult_32_buf[2]<=mult_32[2];
		mult_32_buf[1]<=mult_32[1];mult_32_buf[0]<=mult_32[0];
		
		
		
		CC<=CC_4;
	end
	CC_4:begin 
		//
		S[0]<=mult_32[3]+mult_32[2]+mult_32[1]+mult_32[0]
		+mult_32_buf[3]+mult_32_buf[2]+mult_32_buf[1]+mult_32_buf[0];

		CC<=CC_5;
	end
	CC_5:begin 
		op_count<=op_count+1;
		
		//storage multiplication result
		mult_32_buf[3]<=mult_32[3];mult_32_buf[2]<=mult_32[2];
		mult_32_buf[1]<=mult_32[1];mult_32_buf[0]<=mult_32[0];
		addr_b[0]<=addr_b[0]+1;
		CC<=CC_2;
		
		if(check_count==129)begin
		op_count<=0;
		M2_state<=M2_BEGIN_1;
		common_count<=common_count+1;
		dp_addr_a[0]<=0;dp_addr_a[1]<=0;
		dp_addr_b[1]<=1;dp_addr_b[0]<=1;
		addr_a[0]<=0;addr_b[0]<=0;
		addr_a[1]<=0;addr_b[1]<=1;
		CC<=CC_0;
		check_count<=0;
		if(common_count==4799)
		M2_state<=M2_END_1;
		end
	end
	endcase
	end 
	
	M2_END_1:begin 
	check_count<=check_count+1;
	addr_a[0]<=addr_a[0]+1;
	if(check_count==32)begin
	M2_state<=M2_done;
	end
	end
	
	M2_done:begin 
		done<=1;
		M2_state<=M2_IDLE;
	end
	
	default: M2_state<=M2_IDLE;
	endcase
	end
end
	
always_ff@(posedge Clock or negedge Resetn)begin
	if(Resetn==1'b0)begin
		Cb<=6'd0;Rb<=5'd0;
		counter<=6'd0;
		y_done<=1'b0;uv_done<=1'b0;
		//clear_buf<=1'b0;
	end
	else begin
	if(clean) begin
		Cb<=6'd0;Rb<=5'd0;
		counter<=6'd0;
		y_done<=1'b0;uv_done<=1'b0;
		//clear_buf<=1'b0;
	end
	if(!done&&enable)begin
		//clear_buf<=clear;
		if(counter_en)
		counter<=counter+6'd1;
		if(counter==31)
		counter<=6'd0;
		if(counter_en &&(counter==31))begin
			if(M2_state==M2_BEGIN_1&&common_count>0)begin
			Cb<=Cb+6'd1;
			if(Cb==upper_Cb)
				Cb<=6'd0;
			end
		end		
		if(counter_en && (counter==31) && (Cb==upper_Cb) && (M2_state==M2_BEGIN_1))begin
			Rb<=Rb+5'd1;
			if(Rb==5'd29)begin
				Rb<=5'd0;
				y_done<=1'b1;
				if(y_done)
					uv_done<=1'b1;
			end
		end
	end
	end
end	


endmodule
