%讀取圖像
I  = imread('car1.jpg');
% 轉變成灰階
grayI = rgb2gray(I);

% 創建二進制圖檔
BW = edge(grayI,'canny');
% 使用二值圖像創建Hough變換。
[H,T,R] = hough(BW);
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
% 在圖像霍夫變化尋找峰值
P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
% 找到線條並繪製直線
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
figure, imshow(I), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % 繪製直線的開始和結束
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % 確定最長的端點
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% 顯示最長的線段
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');