%x——wifi定位结果横坐标矩阵
%y——wifi定位结果纵坐标矩阵
%v——运动目标运动距离矩阵
%t——时间间隔矩阵
%N——粒子个数
function result = Particlefilter(x, y, d, N)
particles = zeros(3,N);
particles(1,:) = normrnd(x(1), 1, [1 N]);
particles(2,:) = normrnd(y(1), 1, [1 N]);
particles(3,:) = normrnd(d(1), 0.5, [1 N]);%距离
% particles(4,:) = normrnd(v(1), 2, [1 N]);%方向
weights = ones(1,N) / N;
result = zeros(2,length(x));
result(1,1) = x(1);
result(2,1) = y(1);

for i = 2:length(x)
    %-------- prediction --------%
    costheta = (x(i) - x(i-1)) / d(i);
    sintheta = (y(i) - y(i-1)) / d(i);
    x_pre = particles(1,:) + d(i) * costheta + normrnd(0.5, 1, [1 N]);
    y_pre = particles(2,:) + d(i) * sintheta + normrnd(0.5, 1, [1 N]);
    d = particles(3,:) + normrnd(0, 0.5, [1 N]);
    %---------- update ----------%
    distance = arrayfun(@(x,y) sqrt(x^2 + y^2), x_pre - x(i), y_pre - y(i) , 'UniformOutput', true);
    weights = normpdf(distance, 0, 1) / sum(normpdf(distance, 0, 1));
    %-------- resampling --------%
    if 1 / sum(weights.^2) < length(x) / 2
        cumulative_sum = cumsum(weights);
        indexes = searchsorted(cumulative_sum, rand([1,length(weights)]));
        particles(:) = particles(:,indexes);
        weights = ones(1,length(weights)) / length(weights);
    end        
    %--------- estimate ---------%
    result(1,i) = sum(x_pre .* weights);
    result(2,i) = sum(y_pre .* weights);
end
end

function indexes = searchsorted(array1, array2)
array1 = [0 array1];
indexes = array2;
for i = 1 : length(array1) - 1
    indexes(array2 >= array1(i) & array2 < array1(i + 1)) = i - 1;
end
end