module lab22(//input Count,
			output reg [7:0] DATA_R, DATA_G, DATA_B,// RGB資料輸出
			output reg [2:0] COMM,// 列掃描控制訊號
			output reg [2:0] s = 3'b000,// 當前方塊的類型
			output reg [2:0] s4 = 3'b000,// 用於隨機生成方塊的變數
			input left, right, change, down,// 用戶輸入方向鍵
			output enable,// 顯示使能訊號
			output IH,// 頂部指示燈
			output testled,// 測試指示燈
			output reg [0:7] level = 8'b00000000,// 等級顯示
			output reg [0:6] z = 7'b0000001,// 7段顯示器資料
			input CLK// 系統時鐘
);
			assign enable = 1'b1; // 啟用顯示
			int now = 0;// 當前計數
			reg newblock;// 新方塊標誌
			int level_n = 0;// 等級數值 // 空白列
	var bit [0:7] blank = 8'b11111111;
	// 定義各種字元顯示資料		
	var bit [7:0][7:0] blank_Char = '{8'b11111111,
												8'b11111111,
												8'b11111111,
												8'b11111111,
												8'b11111111,
												8'b11111111,
												8'b11111111,
												8'b11111111};
	//結束圖形
	var bit [0:7][0:7] windows_Char = '{8'b01111111,
													8'b10111001,
													8'b11011001,
													8'b11101111,
													8'b11101111,
													8'b11011001,
													8'b10111001,
													8'b01111111};
	var bit [0:10][0:11] front_Char = '{12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111};
	var bit [0:10][0:11] blank_front_Char = '{12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111,
															12'b111111111111};
	var bit [0:10][0:11] back_Char = '{12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111};
	var bit [0:10][0:11] backup_Char = '{12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111};
	var bit [0:10][0:11] back_test_Char = '{12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111};
	var bit [0:10][0:11] front_test_Char = '{12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111};
	var bit [0:10][0:11] back_test_two_Char = '{12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111,
													12'b111111111111};
	var bit [0:10][0:11] over_Char = '{12'b111111111111,
													12'b111111111111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111110111,
													12'b111111111111};
	// 定義方塊形狀資料
	parameter logic [0:3] tetris [0:111] = '{//I
													  4'b0111,
													  4'b0111,
													  4'b0111,
													  4'b0111,
													  
													  4'b1111,
													  4'b1111,
													  4'b1111,
													  4'b0000,
													  
													  4'b0111,
													  4'b0111,
													  4'b0111,
													  4'b0111,
													  
													  4'b1111,
													  4'b1111,
													  4'b1111,
													  4'b0000,
													  //J
													  4'b1011,
													  4'b1011,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0111,
													  4'b0001,
													  4'b1111,
													  
													  4'b0011,
													  4'b0111,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b0001,
													  4'b1101,
													  4'b1111,
													  //L
													  4'b0111,
													  4'b0111,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0001,
													  4'b0111,
													  4'b1111,
													  
													  4'b0011,
													  4'b1011,
													  4'b1011,
													  4'b1111,
													  
													  4'b1111,
													  4'b1101,
													  4'b0001,
													  4'b1111,
													  //O
													  4'b1111,
													  4'b0011,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0011,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0011,
													  4'b0011,
													  4'b1111,
													  
													  4'b1111,
													  4'b0011,
													  4'b0011,
													  4'b1111,
													  //S
													  4'b1111,
													  4'b1001,
													  4'b0011,
													  4'b1111,
													  
													  4'b0111,
													  4'b0011,
													  4'b1011,
													  4'b1111,
													  
													  4'b1111,
													  4'b1001,
													  4'b0011,
													  4'b1111,
													  
													  4'b0111,
													  4'b0011,
													  4'b1011,
													  4'b1111,
													  //T
													  4'b1111,
													  4'b1011,
													  4'b0001,
													  4'b1111,
													  
													  4'b0111,
													  4'b0011,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b0001,
													  4'b1011,
													  4'b1111,
													  
													  4'b1011,
													  4'b0011,
													  4'b1011,
													  4'b1111,
													  //Z
													  4'b1111,
													  4'b0011,
													  4'b1001,
													  4'b1111,
													  
													  4'b1011,
													  4'b0011,
													  4'b0111,
													  4'b1111,
													  
													  4'b1111,
													  4'b0011,
													  4'b1001,
													  4'b1111,
													  
													  4'b1011,
													  4'b0011,
													  4'b0111,
													  4'b1111};
	
	// 模組宣告
	divfreq F0 (CLK, CLK_div);// 時鐘分頻，用於控制畫面更新
	divfreq2 F1 (CLK, CLK_div2);// 生成隨機數
	divfreq_change F4 (CLK, CLK_div_change); // 控制方塊加速下降
	byte cnt;// 用於掃描的計數器
	int x; // 方塊的水平位置
	int y;// 方塊的垂直位置
	byte tmp_x;// 暫存水平位置
	byte tmp_y;// 暫存垂直位置
	reg flag1; // 控制標誌
	reg [0:1] rotate = 2'b00;// 方塊旋轉狀態
	int over;// 遊戲結束標誌
	int clean_flag;// 清除行的標誌

	// 初始化模組
	initial
		begin
			cnt = 0;
			DATA_R = 8'b11111111;
			DATA_G = 8'b11111111;
			DATA_B = 8'b11111111;
			IH = 0;
			newblock <= 0;// 沒有新方塊
			x = 5; // 方塊初始水平位置
			y = 9; // 方塊初始垂直位置
			tmp_x = 0;
			tmp_y = 0;
			rotate = 0; // 初始旋轉角度
			flag1 <= 1'b1;
			s <= s4%7; // 設定方塊類型
			over = 0;  // 遊戲未結束
			z <= 7'b0000001;  // 初始等級顯示
			level_n = 0;  // 等級初始值
		end
	
	// 時鐘分頻控制畫面更新
	always @(posedge CLK_div)
		begin
			if(cnt >= 7)
				cnt <= 0;
			else
				cnt <= cnt+1;
			COMM <= cnt;
			
			
			if(newblock)
			begin
				//testled <= 1'b0;
				back_Char <= back_Char&front_Char;
				s <= s4%7; //get new block
				
				
				//clean whole line
				for(int j=0;j<8;j++)
				begin
					
					clean_flag = 1;
					for(int i=2;i<10;i++)
						if(back_Char[i][j]==1'b1)
							clean_flag = 0;
					
					//if((~clean_Char&~back_Char)==(~clean_Char)) //old
					if(clean_flag)
					begin
						for(int i=0;i<11;i++)
							begin
								for(int element=j;element<7;element++)
									back_Char[i][element] <= back_Char[i][element+1];
								back_Char[i][7] <= 1'b1;
							end
						//level max -> level up (speed up)
						if(level == 8'b11111111)//if you want to level up quickly, change to 8'b10000000 will level up very fast and easy
						begin
							level_n = level_n + 1;
							level <= 8'b00000000;
							
						end
						//level plus
						else
							level <= {1'b1, level[0:6]};
					end
				end
				
				//game over
				if(~over_Char&~back_Char) //vector "every bit AND", a quickly way
				begin
					front_Char <= blank_front_Char;
					back_Char <= blank_front_Char;
					over = 1;
					level <= 8'b00000000;
					level_n = 0;
				end
				
			end
			
			//清除畫面
			front_Char <= blank_front_Char;
			//判斷遊戲是否結束
			if(over==0)
			begin
			 //繪製當前方塊
			for(int i=0;i<4;i++)
				begin
					front_Char[x+i][y+:4] <= tetris[s*16+i+rotate*4];
				end
			end
			
			
			//印出顏色
			DATA_B <= front_Char[cnt+2][0:7];
			DATA_G <= back_Char[cnt+2][0:7];
			
			//print level number
			//Hexadecimal to 7SEG
			if(level_n==0)
				z <= 7'b0000001;
			else if(level_n==1)
				z <= 7'b1001111;
			else if(level_n==2)
				z <= 7'b0010010; 
			else if(level_n==3)
				z <= 7'b0000110;
			else if(level_n==4)
				z <= 7'b1001100;
			else if(level_n==5)
				z <= 7'b0100100; 
			else if(level_n==6)
				z <= 7'b0100000;
			else if(level_n==7)
				z <= 7'b0001111;
			else if(level_n==8)
				z <= 7'b0000000;
			else if(level_n==9)
				z <= 7'b0000100;
			else
				z <= 7'b0000000;
			
			//print GAME OVER :(
			if(over>0&&over<50000)
			begin
				//1藍色，0紅加綠=黃
				DATA_B <= ~windows_Char[cnt];
				DATA_G <= windows_Char[cnt];
				DATA_R <= windows_Char[cnt];
				over++;
			end
			else if(over>=50000)
			begin
				DATA_B <= 8'b11111111;
				over=0;
			end
			//檢查方塊是否與遊戲背景中的其他區塊碰撞
			for(int i=0;i<11;i++)
			begin
				back_test_Char[i] <= {1'b0, back_Char[i][0:7],3'b111};
				back_test_two_Char[i] <= {2'b00, back_Char[i][0:5],4'b1111};
				front_test_Char[i] <= {front_Char[i][0:8],3'b111};
			end
			
		end
	always @(posedge CLK_div2)// 快速添加數字作為隨機基數
		begin
			s4 <= s4 ;
		end
		
	always @(posedge CLK_div_change)
		begin
			if(over==0)
			begin
				int count = 0;
				int dcount = 0;
				int slow = 0;
				//user input
				if(slow > 10)
				begin
					slow = 0;
					if(change)
					begin
						rotate <= rotate + 1'b1;// 處理旋轉輸入
					end
					else if(left && front_Char[2]==12'b111111111111)
						x = x - 1; // 處理向左移動
					else if(right && front_Char[9]==12'b111111111111)
						x = x + 1; // 處理向右移動
				end
				else
					slow++;
				
				if(newblock==1)
					newblock<=0;
					//快速將方塊向下移動一格。
				else if(down && y>0 &&~(~front_test_Char&~back_test_two_Char) && dcount == 0)
				begin
					y = y - 1;
					dcount = 1;
					count = 0;
				end
				//自動下落
				else if(count>40 - 4*level_n)
				begin
					count <= 0;
					dcount = 1;
					
					if(~front_test_Char&~back_test_Char)
						begin
							newblock <= 1;
							x = 5;
							y = 9;
							rotate <= 0;
						end	
					else if(y>0)
						y = y - 1;
					else
					begin
						newblock <= 1;
						x = 5;
						y = 9;
						rotate <= 0;
				end
			end
			else
				count++;
			
			// 防止操作過快
			if(dcount>20&&~(~front_test_Char&~back_test_two_Char))
				dcount = 0;
			else if(~(~front_test_Char&~back_test_two_Char))
				dcount = dcount + 1;
			else
				dcount = 0;
			
			//修正邊界溢出問題
			if(x==1 && tetris[s*16+rotate*4]!=4'b1111)
				x = x + 1;
			if(x==0 && s==0 && (rotate==0||rotate==2))
				x = x + 2;
			else if(x==-1 && s==0 && (rotate==0||rotate==2))
				x = x + 3;
		
			end
		end
		
endmodule

// 時鐘分頻模組，控制畫面更新速度
module divfreq(input CLK, output reg CLK_div);
reg [24:0] Count;
always @(posedge CLK)
begin
	if(Count > 2000)//2000
		begin
			Count <= 25'b0;
			CLK_div <= ~CLK_div;
		end
		else
			Count <= Count + 1'b1;
end
endmodule

// 隨機數生成模組
module divfreq2(input CLK, output reg CLK_div2);
reg [24:0] Count;
always @(posedge CLK)
begin
	if(Count >= 333)
		begin
			Count <= 25'b0;
			CLK_div2 <= ~CLK_div2;
		end
		else
			Count <= Count + 1'b1;
end
endmodule

// 控制方塊快速下降的分頻模組
module divfreq_change(input CLK, output reg CLK_div_change);
reg [24:0] Count;
always @(posedge CLK)
begin
	if(Count >= 50000)
		begin
			Count <= 25'b0;
			CLK_div_change <= ~CLK_div_change;
		end
		else
			Count <= Count + 1'b1;
end
endmodule

