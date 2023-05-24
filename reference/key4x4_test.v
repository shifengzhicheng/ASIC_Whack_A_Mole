//======================================================
// Module name: key4x4_test.v
// 描述: 检测开发板上的四乘四的矩阵键盘K1~K164, 当检测到按键按下时,相应的LED灯翻转
//======================================================
`timescale 1ns / 1ps
module key4x4_test  (
							clk,              // 开发板上输入时钟: 50Mhz
							rst_n,            // 开发板上复位按键
							key_in_y,         // 输入矩阵键盘的列信号(KEY0~KEY3)
							key_out_x,        // 输出矩阵键盘的行信号(KEY4~KEY7)							
							led_out           // 输出LED灯,用于矩阵键盘板上16个LED(LED1~LED16)
						);

//========================================================
// PORT declarations
//========================================================						
input        clk; 
input        rst_n;
input  [3:0] key_in_y;
output reg [3:0] key_out_x;
output [15:0] led_out;

//寄存器定义
reg [19:0] count;

//==============================================
// 输出矩阵键盘的行信号，20ms扫描矩阵键盘一次,采样频率小于按键毛刺频率，相当于滤除掉了高频毛刺信号。
//==============================================
always @(posedge clk or negedge rst_n)     //检测时钟的上升沿和复位的下降沿
begin
   if(!rst_n) begin               //复位信号低有效
      count <= 20'd0;        //计数器清0
      key_out_x <= 4'b1111;  
   end		
   else begin
	      if(count == 20'd0)           //0ms扫描第一行矩阵键盘
            begin
               key_out_x <= 4'b1110;   //开始扫描第一行矩阵键盘,第一行输出0
					count <= count + 20'b1; //计数器加1
            end
         else if(count == 20'd249_999) //5ms扫描第二行矩阵键盘,5ms计数(50M/200-1=249_999)
            begin
               key_out_x <= 4'b1101;   //开始扫描第二行矩阵键盘,第二行输出0
					count <= count + 20'b1; //计数器加1
            end				
			else if(count ==20'd499_999)   //10ms扫描第三行矩阵键盘,10ms计数(50M/100-1=499_999)
            begin
               key_out_x <= 4'b1011;   //扫描第三行矩阵键盘,第三行输出0
					count <= count + 20'b1; //计数器加1
            end	
			else if(count ==20'd749_999)   //15ms扫描第四行矩阵键盘,15ms计数(50M/67.7-1=749_999)
            begin
               key_out_x <= 4'b0111;   //扫描第四行矩阵键盘,第四行输出0
					count <= count + 20'b1; //计数器加1
            end				
         else if(count ==20'd999_999)  //20ms计数(50M/50-1=999_999)
			   begin
               count <= 0;             //计数器为0
            end	
	      else
				count <= count + 20'b1;    //计数器加1
			
   end
end
//====================================================
// 采样列的按键信号
//====================================================
reg [3:0] key_h1_scan;    //第一行按键扫描值KEY
reg [3:0] key_h1_scan_r;  //第一行按键扫描值寄存器KEY
reg [3:0] key_h2_scan;    //第二行按键扫描值KEY
reg [3:0] key_h2_scan_r;  //第二行按键扫描值寄存器KEY
reg [3:0] key_h3_scan;    //第三行按键扫描值KEY
reg [3:0] key_h3_scan_r;  //第三行按键扫描值寄存器KEY
reg [3:0] key_h4_scan;    //第四行按键扫描值KEY
reg [3:0] key_h4_scan_r;  //第四行按键扫描值寄存器KEY
always @(posedge clk)
	begin
		if(!rst_n) begin               //复位信号低有效
			key_h1_scan <= 4'b1111;     
			key_h2_scan <= 4'b1111;          
			key_h3_scan <= 4'b1111;          
			key_h4_scan <= 4'b1111;        
		end		
		else begin
		  if(count == 20'd124_999)           //2.5ms扫描第一行矩阵键盘值
			   key_h1_scan<=key_in_y;         //扫描第一行的矩阵键盘值
		  else if(count == 20'd374_999)      //7.5ms扫描第二行矩阵键盘值
			   key_h2_scan<=key_in_y;         //扫描第二行的矩阵键盘值
		  else if(count == 20'd624_999)      //12.5ms扫描第三行矩阵键盘值
			   key_h3_scan<=key_in_y;         //扫描第三行的矩阵键盘值
		  else if(count == 20'd874_999)      //17.5ms扫描第四行矩阵键盘值
			   key_h4_scan<=key_in_y;         //扫描第四行的矩阵键盘值 
		end
end

//====================================================
// 按键信号锁存一个时钟节拍
//====================================================
always @(posedge clk)
   begin
		 key_h1_scan_r <= key_h1_scan;   	
		 key_h2_scan_r <= key_h2_scan; 
		 key_h3_scan_r <= key_h3_scan; 
		 key_h4_scan_r <= key_h4_scan;  
	end 
   
wire [3:0] flag_h1_key = key_h1_scan_r[3:0] & (~key_h1_scan[3:0]);  //当检测到按键有下降沿变化时，代表该按键被按下，按键有效 
wire [3:0] flag_h2_key = key_h2_scan_r[3:0] & (~key_h2_scan[3:0]);  //当检测到按键有下降沿变化时，代表该按键被按下，按键有效 
wire [3:0] flag_h3_key = key_h3_scan_r[3:0] & (~key_h3_scan[3:0]);  //当检测到按键有下降沿变化时，代表该按键被按下，按键有效 
wire [3:0] flag_h4_key = key_h4_scan_r[3:0] & (~key_h4_scan[3:0]);  //当检测到按键有下降沿变化时，代表该按键被按下，按键有效 

//=====================================================
// LED灯控制,按键按下时,相关的LED输出翻转
//=====================================================
reg [15:0] temp_led;
always @ (posedge clk or negedge rst_n)      //检测时钟的上升沿和复位的下降沿
begin
    if (!rst_n)                 //复位信号低有效
         temp_led <= 16'd0;     //LED灯控制信号输出为低, LED灯全灭
    else
         begin            
             if ( flag_h1_key[0] ) temp_led[0] <= ~temp_led[0];   //按键第一行的KEY1值变化时，LED1将做亮灭翻转
             if ( flag_h1_key[1] ) temp_led[1] <= ~temp_led[1];   //按键第一行的KEY2值变化时，LED2将做亮灭翻转
             if ( flag_h1_key[2] ) temp_led[2] <= ~temp_led[2];   //按键第一行的KEY3值变化时，LED3将做亮灭翻转
             if ( flag_h1_key[3] ) temp_led[3] <= ~temp_led[3];   //按键第一行的KEY4值变化时，LED4将做亮灭翻转
				 if ( flag_h2_key[0] ) temp_led[4] <= ~temp_led[4];   //按键第二行的KEY5值变化时，LED5做亮灭翻转
             if ( flag_h2_key[1] ) temp_led[5] <= ~temp_led[5];   //按键第二行的KEY6值变化时，LED6将做亮灭翻转
             if ( flag_h2_key[2] ) temp_led[6] <= ~temp_led[6];   //按键第二行的KEY7值变化时，LED7将做亮灭翻转
             if ( flag_h2_key[3] ) temp_led[7] <= ~temp_led[7];   //按键第二行的KEY8值变化时，LED8将做亮灭翻转
				 if ( flag_h3_key[0] ) temp_led[8] <= ~temp_led[8];   //按键第三行的KEY9值变化时，LED9将做亮灭翻转
             if ( flag_h3_key[1] ) temp_led[9] <= ~temp_led[9];   //按键第三行的KEY10值变化时，LED10将做亮灭翻转
             if ( flag_h3_key[2] ) temp_led[10] <= ~temp_led[10];   //按键第三行的KEY11值变化时，LED11将做亮灭翻转
             if ( flag_h3_key[3] ) temp_led[11] <= ~temp_led[11];   //按键第三行的KEY12值变化时，LED12将做亮灭翻转
				 if ( flag_h4_key[0] ) temp_led[12] <= ~temp_led[12];   //按键第四行的KEY13值变化时，LED13将做亮灭翻转
             if ( flag_h4_key[1] ) temp_led[13] <= ~temp_led[13];   //按键第四行的KEY14值变化时，LED14将做亮灭翻转
             if ( flag_h4_key[2] ) temp_led[14] <= ~temp_led[14];   //按键第四行的KEY15值变化时，LED15将做亮灭翻转
             if ( flag_h4_key[3] ) temp_led[15] <= ~temp_led[15];   //按键第四行的KEY16值变化时，LED16将做亮灭翻转
         end
end
 
 assign led_out = temp_led;

	 
            
endmodule
