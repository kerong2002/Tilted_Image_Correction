import math

#============<資料放入>=============
x_data = "00000101111001111111100011011100"         #x_data
y_data = "01001101100010110101011010101111"         #y_data
x_list = list(x_data)
y_list = list(y_data)
# print(x_list,y_list)
int_x = 0                                           #int(x_data)
int_y = 0                                           #int(y_data)
y_neg = 0
x_neg = 0
if(x_data[0]=='1'):
    x_neg = 1
if(y_data[0]=='1'):
    y_neg = 1
y_check = 0
x_check = 0
cnt = 0
for i in range(31,0,-1):
    if(y_neg==1):
        if(y_check==1):
            if(y_data[i]=='0'):
                int_y += (2 ** cnt)
                y_list[i] = '1'
            else:
                y_list[i] = '0'
        else:
            if(y_data[i]=='1'):
                int_y += (2 ** cnt)
                y_list[i] = '1'
            else:
                y_list[i] = '0'
        if (y_data[i] == '1'):
            y_check = 1
    else:
        if (y_data[i] == '1'):
            int_y += (2 ** cnt)
    if(x_neg==1):
        if(x_check==1):
            if(x_data[i]=='0'):
                int_x += (2 ** cnt)
        else:
            if(x_data[i]=='1'):
                int_x += (2 ** cnt)
        if (x_data[i] == '1'):
            x_check = 1
    else:
        if (x_data[i] == '1'):
            int_x += (2 ** cnt)
    # if(cnt==24):
    #     print(2**cnt)
    cnt = cnt+1
#===========<check pos/neg>========
# print(x_list,y_list)
if(y_neg==1):
    int_y = -int_y
if(x_neg==1):
    int_x = -int_x
print(int_x/16777216)                                  # get x_data,y_data




# if(int_x==0 and int_y==0):
#     print('degree = 0')
# elif(int_x==0):
#     if(int_y>0):
#         print('degree = 90')
#     else:
#         print('degree = 270')
# else:
#     print(math.atan(1))                                 # get degree