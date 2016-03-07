addpath('../kondo_original_codes/')
addpath('../../../Data_wheat/' ) 

Ydata_all = csvread('wheatY.txt');
Xdata = csvread('wheatX.txt');
Ydata = Ydata_all(:,1)


size(Ydata_all)
size(Ydata)
size(Xdata)

