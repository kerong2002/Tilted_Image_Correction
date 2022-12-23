clear all 
clc
close all;
% ----------------------------------------------------採集與讀取圖像
[fn,pn,fi] = uigetfile('*.jpg','請選擇所要識別的圖片'); %讀取圖像
%-----------------------------------------------------fn表示圖片的名字，pn表示圖片的路徑，fi表示選擇的文件類型
bw = imread([pn fn]);                                 % 讀取圖像 參數爲圖像名稱和圖像路徑
subplot(121), imshow(rgb2gray(bw));                             %顯示圖像函數/%顯示原始圖像
title('原始圖像');                                     %顯示原始圖像 
take=rgb2gray(bw);
qingxiejiao = rando_get(bw)                           %調用函數，獲取傾斜角
bw1 = imrotate(bw,qingxiejiao,'bilinear','crop');     %圖像進行位置矯正
%-----------------------------------------------------取值爲負值向右旋轉 並選區雙線性插值 並輸出同樣尺寸的圖像
subplot(122), imshow(rgb2gray(bw1));                            % 顯示修正後的圖像
title('傾斜校正');
take1=rgb2gray(bw1);

%%
function qingxiejiao=rando_get(I)
I1 = rgb2gray(I);                                     %轉換爲灰度圖像                
I2 = wiener2(I1, [5, 5]);                             %二維維納濾波函數去除離散噪聲點
I3 = edge(I2, 'canny');                               %利用邊緣檢測，減少干擾
%figure,imshow(I3);%可用來顯示圖像邊界
theta = 1:180;                                        %就是要投影方向的角度
[R,xp] = radon(I3,theta);                             %沿某個方向theta做radon變換，結果是向量
%所得R(p,alph)矩陣的每一個點爲對I3基於（p,alph）的線積分,其每一個投影的方向對應一個列向量
[r,c] = find(R>=max(max(R)));  %檢索矩陣R中最大值所在位置，提取行列標 
% max(R)找出每個角度對應的最大投影角度 然在對其取最大值，即爲最大的傾斜角即90度
J=c;  %由於R的列標就是對應的投影角度
qingxiejiao=90-c; %計算傾斜角
end