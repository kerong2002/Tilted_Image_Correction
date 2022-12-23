degree = pi/30;

img = imread('car/test1.jpg');
% 獲得原圖像尺寸和灰階
[m,n,o] = size(img);         
%計算旋轉後的大小
m2 = ceil(abs(m*cos(degree))+abs(n*sin(degree)));
n2 = ceil(abs(n*cos(degree))+abs(m*sin(degree)));      

new_img = zeros(m2,n2,o);
%選轉的矩陣
mat_1 = [1 0 0;0 -1 0;-0.5*n 0.5*m 1];
mat_2 = [cos(degree) -sin(degree) 0;sin(degree) cos(degree) 0;0 0 1];
mat_3 = [1 0 0;0 -1 0;0.5*n2 0.5 *m2 1];      

for i = 1:n
    for j=1:m
        %計算新座標
        new_coordinate = [i j 1]*mat_1*mat_2*mat_3;
        col = ceil(new_coordinate(1));
        row = ceil(new_coordinate(2));                         
        %傳遞灰階值
        new_img(row,col,:) = img(j,i,:);       
    end
end

figure,imshow(uint8(img));title('原圖');
figure,imshow(uint8(new_img));title('經旋轉後的圖像');
