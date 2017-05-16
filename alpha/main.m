clc;clear;close all;
load('rawdata_wifi.mat');
load('rawdata_accl.mat');
load('rawdata_attitude.mat');
load('radiomap_kalman.mat');
map = openfig('map.fig','reuse');

[pdrtime, stepsize, stepvelocity] = PDR(rawdata_accl, rawdata_attitude);
wifiresult = Improvedwknn(rawdata_wifi, radiomap_kalman);
[a,locs] = ismember(wifiresult(1,:), pdrtime);
n = 0; 
distance = zeros(1, length(locs));
velocity = zeros(1, length(locs));
for i = 1:length(locs)
    if locs(i) ~= 0 && locs(i) ~= 1
        distance(i) = sum(stepsize((n + 1):(locs(i) - 1)));
        velocity(i) = sum(stepvelocity((n + 1):(locs(i) - 1))) / (locs(i) - (n + 1));
        n = locs(i) - 1;
    elseif locs(i) == 1
        distance(i) = stepsize(1);
        velocity(i) = stepvelocity(1);
    else
        distance(i) = 0;
        velocity(i) = 0;
    end
end
result = Particlefilter(cell2mat(wifiresult(2,:)), cell2mat(wifiresult(3,:)), distance, 1000);

%----------- ��λ���ͼ -----------%
for k = 1:size(result,2)
    x = result(1,k) - 1;
    y = result(2,k) - 1;
    xloc = 80 * x;
    if y >= 2
        yloc = 79 + 80 + (y - 2) * 83;
    elseif y >= 1
        yloc = 79 + (y - 1) * 80;
    else
        yloc = 79 * y;
    end
    hold on;
    scatter(xloc, yloc, 20, 'k');
    text(xloc, yloc, num2str(k));
end