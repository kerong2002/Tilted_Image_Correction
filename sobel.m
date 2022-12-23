clear all; 

srcImage=imread('C:\Users\User\Documents\MATLAB\0928\car1.jpg');
srcImageInfo=imfinfo('C:\Users\User\Documents\MATLAB\0928\car1.jpg');
 
%轉灰階
grayImage=rgb2gray(srcImage);
 

imageRoberts=edge(grayImage,'roberts');
imageSobel=edge(grayImage,'sobel');	%sobel邊緣檢測
imagePrewitt=edge(grayImage,'prewitt');
imageCanny=edge(grayImage,'canny');
 
%顯示檢測圖像
subplot(2,3,1);
imshow(grayImage);
title('原圖像');
 

subplot(2,3,3);
imshow(imageSobel);
title('sobel');
