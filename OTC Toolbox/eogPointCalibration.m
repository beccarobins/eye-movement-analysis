clr
display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name)
name = [folder_name '\*.txt'];

textDirectory = dir('*.txt');
for k = 1:length(textDirectory);
    FileNames(k,:) = {textDirectory(k,:).name}; %#ok<*SAGROW>
end

filename = char(FileNames(1,1));
eyeData = importdata(filename);
eyeMark = eyeData(:,2);
start = find(eyeMark>65000);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);

for j = 1:length(start);
    rawChannel1(:,j) = channel1(start(j,1):(start(j,1)+24000));
    rawChannel2(:,j) = channel2(start(j,1):(start(j,1)+24000)) ;
end
%%
[~,c] = size(rawChannel1);

scrsz = get(0,'ScreenSize');
figure('Position',scrsz);
for i = 1:c
    plotnumber = str2double(strcat(num2str(c),'1',num2str(i)));
    subplot(plotnumber);
    plot(rawChannel1(:,i));
    hold('on')
    plot(rawChannel2(:,i));
end

pause
close all

scrsz = get(0,'ScreenSize');
figure('Position',scrsz);
display('pick sections of data to calculate the mean mV for a given position.\n0-10 and 0-20\n8 points in total');

zeroRaw = rawChannel1(:,decision)-rawChannel1(1,decision);
plot(zeroRaw);

for i  = 1:16
    [times(i,1),position(i,1)] = ginput(1);
    times(i,1) = round(times(i,1));
end
close all

mean1 = mean(rawChannel1(times(1:2,:)));
mean2 = mean(rawChannel1(times(3:4,:)));
mean3 = mean(rawChannel1(times(5:6,:)));
mean4 = mean(rawChannel1(times(7:8,:)));

mean5 = mean(rawChannel1(times(9:10,:)));
mean6 = mean(rawChannel1(times(11:12,:)));
mean7 = mean(rawChannel1(times(13:14,:)));
mean8 = mean(rawChannel1(times(15:16,:)));

mV1 = abs(mean2)-abs(mean1);
mV2 = abs(mean4)-abs(mean3);
mV3 = abs(mean6)-abs(mean5);
mV4 = abs(mean8)-abs(mean7);

A = input('What is the distance from the chin rest to the screen (cm)?\n');
B = input('What is the distance from the fixation point to the first calibration point?\n');
C = input('What is the distance from the fixation point to the second calibration point?\n');

D1 = hypot(A,B); %#ok<*NASGU>
D2 = hypot(A,C);
angle1 = atand(B/A);
angle2 = atand(C/A);

%use info to convert mV to deg

fit1 = mV1/angle1;
fit2 = mV2/angle1;
fit3 = mV3/angle2;
fit4 = mV4/angle2;

scrsz = get(0,'ScreenSize');
figure('Position',scrsz);

subplot(411);
testdata = zeroRaw/fit1;
plot(testdata);
hold('on')

subplot(412);
testdata = zeroRaw/fit2;
plot(testdata);

subplot(413);
testdata = zeroRaw/fit3;
plot(testdata);
hold('on')

subplot(414);
testdata = zeroRaw/fit4;
plot(testdata);

fit = input('Which fit variable is correct?\n');

fit = strcat('fit',num2str(fit));
fitVariableRight = eval(fit);
close all

% scrsz = get(0,'ScreenSize');
% figure('Position',scrsz);
% display('pick sections of data to calculate the mean mV for a given position.\n0-10 and 0-20\n8 points in total');
% zeroRaw = rawChannel2(:,decision)-rawChannel2(1,decision);
% plot(zeroRaw);
% 
% for i  = 1:16
%     [times(i,1),position(i,1)] = ginput(1);
%     times(i,1) = round(times(i,1));
% end
% close all

mean1 = mean(rawChannel2(times(1:2,:)));
mean2 = mean(rawChannel2(times(3:4,:)));
mean3 = mean(rawChannel2(times(5:6,:)));
mean4 = mean(rawChannel2(times(7:8,:)));

mean5 = mean(rawChannel2(times(9:10,:)));
mean6 = mean(rawChannel2(times(11:12,:)));
mean7 = mean(rawChannel2(times(13:14,:)));
mean8 = mean(rawChannel2(times(15:16,:)));

mV1 = abs(mean2)-abs(mean1);
mV2 = abs(mean4)-abs(mean3);
mV3 = abs(mean6)-abs(mean5);
mV4 = abs(mean8)-abs(mean7);

%use info to convert mV to deg

fit1 = mV1/angle1;
fit2 = mV2/angle2;
fit3 = mV3/angle1;
fit4 = mV4/angle2;

scrsz = get(0,'ScreenSize');
figure('Position',scrsz);

subplot(411);
testdata = zeroRaw/fit1;
plot(testdata);
hold('on')

subplot(412);
testdata = zeroRaw/fit2;
plot(testdata);

subplot(413);
testdata = zeroRaw/fit3;
plot(testdata);
hold('on')

subplot(414);
testdata = zeroRaw/fit4;
plot(testdata);

fit = input('Which fit variable is correct?\n');

fit = strcat('fit',num2str(fit));
fitVariableLeft = eval(fit);
close all

clearvars -except fitVariableLeft fitVariableRight

save('pointCalibration.mat');

clr