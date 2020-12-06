`timescale 1ns/100ps
`default_nettype none

//`include "define_state.h"


module IDCT_mat(
	//input logic [2:0] M2_state,
	input logic [7:0] counter,
	output logic[15:0] Ct[3:0]
);


always_comb begin
	Ct[3]=0;Ct[2]=0;Ct[1]=0;Ct[0]=0;
	//if(M2_state==2||M2_state==4)begin
	if(counter>0)begin
	Ct[0]=1448;Ct[1]=2008;Ct[2]=1892;Ct[3]=1702;
	if(~counter[0])begin
	Ct[0]=1448;Ct[1]=1137;Ct[2]=783;Ct[3]=399;end
	end
	if(counter>16)begin 
	Ct[0]=1448;Ct[1]=1702;Ct[2]=783;Ct[3]=16'hFE71;
	if(~counter[0])begin
	Ct[0]=16'hFA58;Ct[1]=16'hF828;Ct[2]=16'hF89C;;Ct[3]=16'hFB8F;end
	end
	if(counter>32)begin
	Ct[0]=1448;Ct[1]=1137;Ct[2]=16'hFCF1;Ct[3]=16'hF828;
	if(~counter[0])begin
	Ct[0]=16'hFA58;Ct[1]=399;Ct[2]=1892;Ct[3]=1702;end
	end
	if(counter>48)begin 
	Ct[0]=1448;Ct[1]=399;Ct[2]=16'hF89C;Ct[3]=16'hFB8F;
	if(~counter[0])begin
	Ct[0]=1448;Ct[1]=1702;Ct[2]=16'hFCF1;Ct[3]=16'hF828;end
	end
	if(counter>64)begin 
	Ct[0]=1448;Ct[1]=16'hFE71;Ct[2]=16'hF89C;Ct[3]=1137;
	if(~counter[0])begin
	Ct[0]=1448;Ct[1]=16'hF95A;Ct[2]=16'hFCF1;Ct[3]=2008;end
	end
	if(counter>80)begin 
	Ct[0]=1448;Ct[1]=16'hFB8F;Ct[2]=16'hFCF1;Ct[3]=2008;if(~counter[0])begin
	Ct[0]=16'hFA58;Ct[1]=16'hFE71;Ct[2]=1892;Ct[3]=16'hF95A;end
	end
	if(counter>96)begin 
	Ct[0]=1448;Ct[1]=16'hF95A;Ct[2]=783;Ct[3]=399;if(~counter[0])begin
	Ct[0]=16'hFA58;Ct[1]=2008;Ct[2]=16'hF89C;Ct[3]=1137;end
	end
	if(counter>112)begin
	Ct[0]=1448;Ct[1]=16'hF828;Ct[2]=1892;Ct[3]=16'hF95A;if(~counter[0])begin
	Ct[0]=1448;Ct[1]=16'hFB8F;Ct[2]=783;Ct[3]=16'hFE71;end
	end
	//end
	/*if(M2_state==3||M2_state==5)begin
	if(counter>2)begin
	Ct[0]=1448;Ct[1]=2008;Ct[2]=1892;Ct[3]=1702;if(~counter[0])begin
	Ct[0]=1448;Ct[1]=1137;Ct[2]=783;Ct[3]=399;end
	end
	if(counter>18)begin 
	Ct[0]=1448;Ct[1]=1702;Ct[2]=783;Ct[3]=16'hFE71;if(~counter[0])begin
	Ct[0]=16'hFA58;Ct[1]=16'hF828;Ct[2]=16'hF89C;;Ct[3]=16'hFB8F;end
	end
	if(counter>34)begin
	Ct[0]=1448;Ct[1]=1137;Ct[2]=16'hFCF1;Ct[3]=16'hF828;if(~counter[0])begin
	Ct[0]=16'hFA58;Ct[1]=399;Ct[2]=1892;Ct[3]=1702;end
	end
	if(counter>50)begin 
	Ct[0]=1448;Ct[1]=399;Ct[2]=16'hF89C;Ct[3]=16'hFB8F;if(~counter[0])begin
	Ct[0]=1448;Ct[1]=1702;Ct[2]=16'hFCF1;Ct[3]=16'hF828;end
	end
	if(counter>66)begin 
	Ct[0]=1448;Ct[1]=16'hFE71;Ct[2]=16'hF89C;Ct[3]=1137;if(~counter[0])begin
	Ct[0]=1448;Ct[1]=16'hF95A;Ct[2]=16'hFCF1;Ct[3]=2008;end
	end
	if(counter>82)begin 
	Ct[0]=1448;Ct[1]=16'hFB8F;Ct[2]=16'hFCF1;Ct[3]=2008;if(~counter[0])begin
	Ct[0]=16'hFA58;Ct[1]=16'hFE71;Ct[2]=1892;Ct[3]=15'hF95A;end
	end
	if(counter>98)begin 
	Ct[0]=1448;Ct[1]=16'hF95A;Ct[2]=783;Ct[3]=399;if(~counter[0])begin
	Ct[0]=16'hFA58;Ct[1]=2008;Ct[2]=16'hF89C;Ct[3]=1137;end
	end
	if(counter>114)begin
	Ct[0]=1448;Ct[1]=16'hF828;Ct[2]=1892;Ct[3]=16'hF95A;if(~counter[0]) begin
	Ct[0]=1448;Ct[1]=16'hFB8F;Ct[2]=783;Ct[3]=16'hFE71;end
	end*/

	//end
end

endmodule