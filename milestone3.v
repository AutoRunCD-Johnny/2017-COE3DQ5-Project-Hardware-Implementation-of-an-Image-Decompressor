`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module milestone3(
	input logic Clock,
	input logic Resetn,
	input logic enable,
	input logic [15:0] SRAM_read_data,
	output logic [17:0] M3_SRAM_address,
	output logic [15:0] M3_SRAM_write_data,
	output logic IDCT_we_n,
	output logic done
	//test
	
);
M3_state_type M3_state;	

logic [5:0] remain;
logic [47:0] buffer;
logic [2:0] header;
logic [12:0] block_counter;
logic [17:0] sram_count;
logic [5:0] dp_count;
logic [2:0] Q_mat[1:0];
logic [15:0] raw_write;
logic [2:0] check; //the check is a counter use for delay to make seqential go correctly(like we expect).
logic [3:0] d;

//DP_RAM
logic [31:0] read_data_a[1:0];
logic [31:0] read_data_b[1:0];
logic [31:0] write_data_a[1:0];	//assign tb_write_data_a=write_data_a;
logic [31:0] write_data_b[1:0];	//assign tb_write_data_b=write_data_b;
logic write_enable_a[1:0];	//assign tb_write_enable_a=write_enable_a;
logic write_enable_b[1:0]; //assign tb_write_enable_b=write_enable_b;
logic [6:0] addr_a[1:0];//assign tb_addr_a=addr_a;
logic [6:0] addr_b[1:0];//assign tb_addr_b=addr_b;	


//M2 variable
logic [17:0] M2_SRAM_address;
logic M2_enable;
logic M2_done;
logic [31:0] dp_read_a[1:0];
logic [31:0] dp_read_b[1:0];
logic [6:0] dp_addr_a[1:0];
logic [6:0] dp_addr_b[1:0];
//logic [31:0] dp_write_a[1:0];
//logic [31:0] dp_write_b[1:0];
//logic dp_we_a[1:0];
//logic dp_we_b[1:0];
logic fetch;
logic fetch_buf;

milestone2 M2_unit(
	.Clock(Clock),
	.Resetn(Resetn),
	.enable(M2_enable),
	.clean(done),
	.dp_read_a(dp_read_a),
	.dp_read_b(dp_read_b),
	.dp_addr_a(dp_addr_a),
	.dp_addr_b(dp_addr_b),
	//.dp_write_a(dp_write_a),
	//.dp_write_b(dp_write_b),
	//.dp_we_a(dp_we_a),
	//.dp_we_b(dp_we_b),
	.M2_SRAM_address(M2_SRAM_address),
	.M2_SRAM_write_data(M3_SRAM_write_data),
	.IDCT_we_n(IDCT_we_n),
	.done(M2_done),
	.fetch(fetch)
);

// Instantiate RAM3
// 128 locations. 32bit per location
dual_port_RAM3 dual_port_RAM_inst1 (
	.address_a ( addr_a[1]),
	.address_b ( addr_b[1]),
	.clock ( Clock ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);



// Instantiate RAM0
// 32 locations. 32bit per location
dual_port_RAM0 dual_port_RAM_inst0 (
	.address_a ( addr_a[0][4:0] ),
	.address_b ( addr_b[0][4:0] ),
	.clock ( Clock ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);
	

always_comb begin
	header=buffer[47:45];
	raw_write=0;
	M3_SRAM_address=sram_count+76800;
	//
	addr_a[1]=0;addr_b[1]=64+dp_count;
	addr_a[0]=0;
	write_enable_a[1]=0;write_enable_a[0]=0;
	write_data_a[1]=0;write_data_a[0]=0;
	dp_read_a[0]=read_data_a[0];
	dp_read_b[0]=read_data_b[0];
	addr_b[0]=dp_addr_b[0];
	write_data_b[0]=0;
	write_enable_b[1]=0;write_enable_b[0]=0;
	case(M3_state)
	M3_wait:begin
	if(check==0)begin
	M3_SRAM_address=M2_SRAM_address;
	dp_read_a[1]=read_data_a[1];
	dp_read_b[1]=read_data_b[1];
	addr_a[1]=dp_addr_a[1];
	addr_b[1]=dp_addr_b[1];
	addr_a[0]=dp_addr_a[0];
	end
	end
	
	M3_done:begin
	if(!M2_done)begin
	M3_SRAM_address=M2_SRAM_address;
	end
	end
	
	M3_decode:begin
	if(header==0 || header==1)begin //9 bit signed
	raw_write={buffer[45:37]}<<(Q_mat[0]);
	if(buffer[45])
	raw_write={7'h7F,buffer[45:37]}<<(Q_mat[0]);
	end
	
	if(header==2 || header==3)begin // 4bit signed
	raw_write={buffer[45:42]}<<(Q_mat[0]);
	if(buffer[45])
	raw_write={12'hFFF,buffer[45:42]}<<(Q_mat[0]);
	end
	
	if(header==4)begin //neg 1
	raw_write=16'hFFFF<<Q_mat[0];
	end
	
	if(header==5)begin //pos 1
	raw_write=16'b1<<Q_mat[0];
	end
	
	if(header==6||header==7)begin // 0
	raw_write=16'h0;
	end
	//write the S' into DP-RAM
	if(read_data_b[1][0]==0)begin  //ram3 store even S'
	write_data_a[1]={16'h0,raw_write};
	addr_a[1]=read_data_b[1][7:1];
	write_enable_a[1]=1;
	end
	if(read_data_b[1][0]==1)begin //odd s'
	write_data_a[0]={16'h0,raw_write};
	addr_a[0]=read_data_b[1][7:1];
	write_enable_a[0]=1;
	end

	end
	endcase
	
end


always_ff@(posedge Clock or negedge Resetn)begin
	if(Resetn==1'b0)begin
	remain<=0;
	buffer<=0;
	dp_count<=0;
	d<=0;
	M2_enable<=0;
	block_counter<=0;
	sram_count<=0;
	check<=0;
	Q_mat[1]<=0;
	done<=0;
	fetch_buf<=0;
	end
	else begin
	fetch_buf<=fetch;
	case(M3_state)
	M3_IDLE:begin 
	remain<=0;
	buffer<=0;
	dp_count<=0;
	d<=0;
	M2_enable<=0;
	block_counter<=0;
	sram_count<=0;
	check<=0;
	Q_mat[1]<=0;
	done<=0;
	
	if(!done&&enable)
	M3_state<=M3_head;
	end
	
	M3_head:begin
	check<=check+1;
	if(sram_count<4)
	sram_count<=sram_count+1;
	/*if(check==0&&SRAM_read_data!=8'hde)
	
	if(check==1&&SRAM_read_data!=8'had)
	
	if(check==2&&SRAM_read_data!=8'hbe)
	
	if(check==3&&SRAM_read_data!=8'hef)
	*/
	if(check==4)
	Q_mat[1]<=SRAM_read_data[15];
	if(check==5)begin
	sram_count<=sram_count+1;
	M3_state<=M3_fetch;
	check<=0;
	end
	end
	
	M3_fetch:begin 
	/*remain<=remain+16; //before ir was 32bit shitf register
	if(sram_count<5)
	sram_count<=sram_count+1;
	if(!remain)
	buffer[31:16]<=SRAM_read_data;
	else begin
	buffer[15:0]<=SRAM_read_data;
	dp_count<=dp_count+1;
	M3_state<=M3_decode;
	end*/
	check<=check+1;
	if(sram_count<6)
	sram_count<=sram_count+1;
	if(check==1)
	buffer[47:32]<=SRAM_read_data;
	if(check==2)
	buffer[31:16]<=SRAM_read_data;
	if(check==3)begin
	buffer[15:0]<=SRAM_read_data;
	check<=0;
	remain<=48;
	dp_count<=dp_count+1;
	M3_state<=M3_decode;
	sram_count<=sram_count+1;
	end
	end
	
	M3_buf:begin 
	check<=check+1;
	if(check==0)begin
	sram_count<=sram_count+1;
	remain<=remain+16;
	buffer<=buffer+({32'b0,SRAM_read_data}<<(32-remain));
	end
	if(check<=1)
	sram_count<=sram_count+1;
	
	if(check==3)begin
	remain<=remain+16;
	buffer<=buffer+({32'b0,SRAM_read_data}<<(32-remain));
	//end
	//if(check==4)begin
	M3_state<=M3_decode;
	dp_count<=dp_count+1;
	check<=0;
	end
	end
	
	M3_decode:begin 
	dp_count<=dp_count+1;
	if(header==0 || header==1)begin 
	buffer<=buffer<<11;
	remain<=remain-11;
	if(remain-11<=16)begin
	M3_state<=M3_buf;
	dp_count<=dp_count;
	end
	
	end
	
	if(header==2 || header==3)begin 
	buffer<=buffer<<6;
	remain<=remain-6;
	if(remain-6<=16)begin
	M3_state<=M3_buf;
	dp_count<=dp_count;
	end
	end
	
	if(header==4 || header==5)begin 
	d<=d+1;
	if(((buffer[44:43]==0)?3:buffer[44:43]-1)==d)begin
	d<=0;
	buffer<=buffer<<5;
	remain<=remain-5;
	if(remain-5<=16)begin
	M3_state<=M3_buf;
	dp_count<=dp_count;
	end
	end
	end
	
	if(header==6)begin 
	d<=d+1;
	if(((buffer[44:42]==0)?7:buffer[44:42]-1)==d)begin
	d<=0;
	buffer<=buffer<<6;
	remain<=remain-6;
	if(remain-6<=16)begin
	M3_state<=M3_buf;
	dp_count<=dp_count;
	end
	end
	end
	
	if(header==7)begin 
	dp_count<=dp_count+1;
	if(read_data_b[1]==63)begin
	buffer<=buffer<<3;
	remain<=remain-3;
	/*if(remain-3<=16)begin
	M3_state<=M3_buf;
	dp_count<=dp_count;
	end*/
	end
	end
	
	if(read_data_b[1]==63)begin
	M3_state<=M3_wait;
	dp_count<=0;
	M2_enable<=1;
	end
	
	if(block_counter==2400)
	M3_state<=M3_done;
	end
	
	
	
	M3_wait:begin
	if(fetch!=fetch_buf)begin
	check<=check+1;
	block_counter<=block_counter+1;
	//M2_enable<=0;
	end
	if(check==1)
	check<=check+1;
	if(check==2)
	check<=check+1;
	if(check==3)begin
	check<=0;
	if(remain>16)begin
	M3_state<=M3_decode;
	dp_count<=dp_count+1;
	end
	else
	M3_state<=M3_buf;
	end
	end
	
	M3_done:begin
	if(M2_done)begin
	M3_state<=M3_IDLE;
	done<=1;
	M2_enable<=0;
	end
	end
	
	default: M3_state<=M3_IDLE;
	endcase
	end
end

//Q matrix
always_comb begin
	Q_mat[0]=0;
	if(Q_mat[1])begin
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==0)
		Q_mat[0]=3;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==1)
		Q_mat[0]=1;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==2)
		Q_mat[0]=1;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==3)
		Q_mat[0]=1;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==4)
		Q_mat[0]=2;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==5)
		Q_mat[0]=2;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==6)
		Q_mat[0]=3;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==7)
		Q_mat[0]=3;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==8)
		Q_mat[0]=4;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==9)
		Q_mat[0]=4;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==10)
		Q_mat[0]=4;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==11)
		Q_mat[0]=5;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==12)
		Q_mat[0]=5;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==13)
		Q_mat[0]=5;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==14)
		Q_mat[0]=5;
	end
	else begin
	if(read_data_b[1][6:3]+read_data_b[1][2:0]==0)
		Q_mat[0]=3;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==1)
		Q_mat[0]=2;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==2)
		Q_mat[0]=3;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==3)
		Q_mat[0]=3;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==4)
		Q_mat[0]=4;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==5)
		Q_mat[0]=4;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==6)
		Q_mat[0]=5;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==7)
		Q_mat[0]=5;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==8)
		Q_mat[0]=6;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==9)
		Q_mat[0]=6;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==10)
		Q_mat[0]=6;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==11)
		Q_mat[0]=6;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==12)
		Q_mat[0]=6;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==13)
		Q_mat[0]=6;
		if(read_data_b[1][6:3]+read_data_b[1][2:0]==14)
		Q_mat[0]=6;
	end
end

endmodule