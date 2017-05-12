clc;clear;close all;
%------------ load ------------%
load('rawdata_accl.mat');
load('rawdata_attitude.mat');
gravity_geo = cell(size(rawdata_accl));
%----------- figure -----------%
x = 1:length(rawdata_accl);
yx = cell2mat(cellfun(@(x) x(1), rawdata_accl, 'UniformOutput', false));
yy = cell2mat(cellfun(@(x) x(2), rawdata_accl, 'UniformOutput', false));
yz = cell2mat(cellfun(@(x) x(3), rawdata_accl, 'UniformOutput', false));
figure(1);plot(x, yx, x, yy, '-r', x, yz, '-g');title('���������¼��ٶ�');
xlabel('samples');
ylabel('accelerate(g)');
%- coordinate transformation -%
C_b_2 = cellfun(@(x) [cos(x(1)) 0 -sin(x(1)); 0 1 0; sin(x(1)) 0 cos(x(1))], rawdata_attitude, 'UniformOutput', false);
C_1_t = cellfun(@(x) [cos(x(2)) -sin(x(2)) 0; sin(x(2)) cos(x(2)) 0; 0 0 1], rawdata_attitude, 'UniformOutput', false);
C_2_1 = cellfun(@(x) [1 0 0; 0 cos(x(3)) sin(x(3)); 0 -sin(x(3)) cos(x(3))], rawdata_attitude, 'UniformOutput', false); 
C = cellfun(@(x,y,z) x * y * z, C_b_2, C_2_1, C_1_t, 'UniformOutput', false); 
gravity_geo(:) = {[0 0 1]};
gravity_carry = cellfun(@(x,y) x * y', C, gravity_geo, 'UniformOutput', false); 
accl_transpose = cellfun(@(x) x', rawdata_accl, 'UniformOutput', false);
accl_removegravity = cellfun(@(x,y) x + y, accl_transpose, gravity_carry, 'UniformOutput', false);
accl_geo = cellfun(@(x,y) x' * y, C, accl_removegravity, 'UniformOutput', false);
accl_geo = cellfun(@(x) x' * 9.80665, accl_geo, 'UniformOutput', false);
%----------- figure -----------%
x_geo = 1:length(accl_geo);
yx_geo = cell2mat(cellfun(@(x) x(1), accl_geo, 'UniformOutput', false));
yy_geo = cell2mat(cellfun(@(x) x(2), accl_geo, 'UniformOutput', false));
yz_geo = cell2mat(cellfun(@(x) x(3), accl_geo, 'UniformOutput', false));
figure(2);plot(x_geo, yx_geo, x_geo, yy_geo, '-r', x_geo, yz_geo, '-g');title('���������¼��ٶ�');
xlabel('samples');
ylabel('accelerate(m^2\cdot s^{-1})');

accl_amp = cell2mat(cellfun(@norm, accl_geo, 'UniformOutput', false));
figure(3);plot(x_geo, accl_amp);title('���������¼��ٶȷ�ֵ');
xlabel('samples');
ylabel('accelerate(m^2\cdot s^{-1})');

%------- peak detection -------%
[pks, locs] = findpeaks(accl_amp, 'minpeakdistance', 3, 'minpeakheight', 1.5);
stepnum = length(pks)
hold on; plot(x_geo(locs), pks + 0.05, 'k^');