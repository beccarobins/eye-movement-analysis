%Example calibration with VORCal

clr
display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name)
name = [folder_name '\*.txt'];

textDirectory = dir('*.txt');
for k = 1:length(textDirectory);
    FileNames(k,:) = {textDirectory(k,:).name}; %#ok<*SAGROW>
end

number = 1:length(FileNames);
number = number';
Files = horzcat(num2cell(number),FileNames);

display(Files)

file = input('Which head file to use?\n');

filename = char(FileNames(file,1));
headData = importdata(filename);
%headPitch = headData.data(:,1);
headYaw = headData.data(:,2);
%headRoll = headData.data(:,3);
headMark = headData.data(:,5);
start = find(headMark>0);
%channel1 = eyeData(:,3);
%rawEOG = channel1(start:end,:);

for j = 1:length(start);
    headDataPool(:,j) = headYaw(start(j,1):(start(j,1)+674)) ;
end

if length(start)==15
    for j = 1:15;
        headDataPool(:,j) = headDataPool(:,j)-headDataPool(1,j) ;
    end
    headDataPool(:,1:3) = headDataPool(:,1:3);
    headDataPool(:,4:9)= headDataPool(:,10:15);
else
    for j = 1:9;
        headDataPool(:,j) = headDataPool(:,j)-headDataPool(1,j) ;
    end
end
display(Files)

file = input('Which eye file to use?\n');

filename = char(FileNames(file,1));
eyeData = importdata(filename);
eyeMark = eyeData(:,2);
start = find(eyeMark>0);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);

for j = 1:length(start);
    rawChannel1(:,j) = channel1(start(j,1):(start(j,1)+8999));
    rawChannel2(:,j) = channel2(start(j,1):(start(j,1)+8999)) ;
end

% [~,c] = size(rawChannel1);
% 
% scrsz = get(0,'ScreenSize');
% figure('Position',scrsz);
% for i = 1:c
%     plotnumber = str2double(strcat(num2str(c),'1',num2str(i)));
%     subplot(plotnumber);
%     plot(rawChannel2(:,i));
%     hold('on')
% end
% 
% pause
% close all

% decision = input('Which dataset to use for calibration?\n');

headTest = headDataPool(:,9);
eyeTest = rawChannel2(:,9);

%4,9

step1 = 0;
while step1~=1;
    subEOG = eyeTest(1:13.35:end,:);
    scrsz = get(0,'ScreenSize');
    figure('Position',scrsz);
    plot(subEOG);
    [X1,Y1] = ginput(1);
    [X2,Y2] = ginput(1);
    T1 = round(X1);
    T2 = round(X2);
    cal(:,1) = subEOG(T1:T2,:);
    cal(:,2) = headTest(T1:T2,:);
    x = cal(:,1);
    y = cal(:,2);

    close all

    scatter(x,y,'bo');

    step1 = input('Is Fit Line acceptable?\n(1)Yes\n(2)No\n');

    if step1==1
        fit = polyfit(x,y,1);
        close all
        headTest = headTest-headTest(1,1);
        EOGDeg = subEOG*(fit(1,1))+fit(1,2);
        EOGDeg = EOGDeg-EOGDeg(1,1);
        plot(EOGDeg,'b');
        hold on
        plot(headTest,'r');
        step2 = input('Is Fit Variable acceptable?\n(1)Yes\n(2)No\n');
        if step2==2
            clearvars cal
            hold off
            step1=0;
        else
        end
    else
        clearvars cal
    end
end

clearvars cal

fitVariableLeft = fit;

headTest = headDataPool(:,9);
eyeTest = rawChannel1(:,9);

%4,9

step1 = 0;
while step1~=1;
    subEOG = eyeTest(1:13.35:end,:);
    scrsz = get(0,'ScreenSize');
    figure('Position',scrsz);
    plot(subEOG);
    [X1,Y1] = ginput(1);
    [X2,Y2] = ginput(1);
    T1 = round(X1);
    T2 = round(X2);
    cal(:,1) = subEOG(T1:T2,:);
    cal(:,2) = headTest(T1:T2,:);
    x = cal(:,1);
    y = cal(:,2);

    close all

    scatter(x,y,'bo');

    step1 = input('Is Fit Line acceptable?\n(1)Yes\n(2)No\n');

    if step1==1
        fit = polyfit(x,y,1);
        close all
        headTest = headTest-headTest(1,1);
        EOGDeg = subEOG*(fit(1,1))+fit(1,2);
        EOGDeg = EOGDeg-EOGDeg(1,1);
        plot(EOGDeg,'b');
        hold on
        plot(headTest,'r');
        step2 = input('Is Fit Variable acceptable?\n(1)Yes\n(2)No\n');
        if step2==2
            clearvars cal
            hold off
            step1=0;
        else
        end
    else
        clearvars cal
    end
end

fitVariableRight = fit;

clearvars -except fitVariableLeft fitVariableRight

save('vorCalibration.mat');

clr