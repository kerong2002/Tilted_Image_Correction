# Tilted Image Correction

This project aims to correct tilted images using MATLAB and Verilog

## Approach

1. Use Hough Transform to detect straight lines in the image.
2. Apply Sobel operator to detect edges in the image.
3. Binarize the image.
4. Find the peak.
5. Use the Cordic algorithm to compute the arctangent.
6. Use matrix multiplication to obtain the correction image.

## Example

![image](https://github.com/kerong2002/Tilted_Image_Correction/blob/main/%E5%9C%96%E7%89%871.png)
