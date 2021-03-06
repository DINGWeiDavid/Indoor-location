clc;clear;close all;
%-------- load & init--------%
map = openfig('testmap.fig','reuse');
load('testpoints');
load('radiomap_kalman');
k = 3;
weight = 0.54;
result = cell(1,1);
%-------improved wknn -------%
testqty = size(testpoints, 2);
tempcell = cell(size(radiomap_kalman));
for i = 1:testqty
    %----------- 计算欧式距离 -----------%
    tempcell(:,:) = {testpoints{i}(2,:)};
    EuclideanDistancecell = cellfun(@(x,y) (x - y).^2, radiomap_kalman, tempcell, 'UniformOutput', false);
    EuclideanDistance = sqrt(cellfun(@sum, EuclideanDistancecell));
    %--------- 判断高低权值区域 ---------%
    [sorted, index] = sort(EuclideanDistance(:));
    [y_index, x_index] = ind2sub(size(radiomap_kalman), index);
    y_wknn = sum(y_index(1:k).*(sorted(1:k).^(-1))) / sum(sorted(1:k).^(-1));
    x_wknn = sum(x_index(1:k).*(sorted(1:k).^(-1))) / sum(sorted(1:k).^(-1));
    if i == 1
        result{2,i} = x_wknn;
        result{3,i} = y_wknn;
        continue;
    elseif (1 <= x_wknn) && (x_wknn < 24)
        diff = testpoints{i}(2,:) - testpoints{i-1}(2,:);
        diff(1) = -diff(1);
    else
        diff = testpoints{i}(2,:) - testpoints{i-1}(2,:);
        diff(1) = -diff(1);
        diff(2) = -diff(2);
    end
    %----------- 计算定位结果 -----------%
    [sorted, index] = sort(EuclideanDistance(:));
    [y_index, x_index] = ind2sub(size(radiomap_kalman), index);
    if sum(diff(:)>0) >= 2
        x_boundary = floor(result{2, i-1});
        lowweight = sorted(x_index <= x_boundary);
        highweight = sorted(x_index > x_boundary);
        x_lw = x_index(x_index <= x_boundary);
        x_hw = x_index(x_index > x_boundary);
        y_lw = y_index(x_index <= x_boundary);
        y_hw = y_index(x_index > x_boundary);
        x_wknnpro = (1 - weight) * sum(x_lw(1:k).*(lowweight(1:k).^(-1))) / sum(lowweight(1:k).^(-1)) + weight * sum(x_hw(1:k).*(highweight(1:k).^(-1))) / sum(highweight(1:k).^(-1));
        y_wknnpro = (1 - weight) * sum(y_lw(1:k).*(lowweight(1:k).^(-1))) / sum(lowweight(1:k).^(-1)) + weight * sum(y_hw(1:k).*(highweight(1:k).^(-1))) / sum(highweight(1:k).^(-1));
    else
        x_boundary = ceil(result{2, i-1}(1));
        lowweight = sorted(x_index >= x_boundary);
        highweight = sorted(x_index < x_boundary);
        x_lw = x_index(x_index >= x_boundary);
        x_hw = x_index(x_index < x_boundary);
        y_lw = y_index(x_index >= x_boundary);
        y_hw = y_index(x_index < x_boundary);
        x_wknnpro = (1 - weight) * sum(x_lw(1:k).*(lowweight(1:k).^(-1))) / sum(lowweight(1:k).^(-1)) + weight * sum(x_hw(1:k).*(highweight(1:k).^(-1))) / sum(highweight(1:k).^(-1));
        y_wknnpro = (1 - weight) * sum(y_lw(1:k).*(lowweight(1:k).^(-1))) / sum(lowweight(1:k).^(-1)) + weight * sum(y_hw(1:k).*(highweight(1:k).^(-1))) / sum(highweight(1:k).^(-1));
    end
    result{2,i} = x_wknnpro;
    result{3,i} = y_wknnpro;
end

%----------- 定位结果图 -----------%
[xreal, yreal] = realposition(cell2mat(result(2:3,:)));   
hold on;
plot(xreal, yreal, 'k^', 'MarkerSize', 7, 'MarkerFaceColor','k');
text(xreal + 10, yreal + 10, num2cell(1:size(xreal,2)));

%---------- 计算误差分布 ----------%
xtest = 0:80:22*80;
ytest = 79*ones(1,23);
error_wknnpro = sqrt((xtest/100 - xreal/100).^2 + (ytest/100 - yreal/100).^2);
save('error_wknnpro', 'error_wknnpro');
error_avg = mean(error_wknnpro)
error_std = std(error_wknnpro)
error_min = min(error_wknnpro)
error_max = max(error_wknnpro)