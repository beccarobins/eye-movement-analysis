clr;
display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name)
name = [folder_name '\*.txt'];
name = [pwd '\*.txt'];

textDirectory = dir('*.txt');
for k = 1:length(textDirectory);
    FileNames(k,:) = {textDirectory(k,:).name}; %#ok<*SAGROW>
end

subject = input('What is participant ID\n','s');

MainFilename = sprintf(strcat(subject,'-OTC.xlsx'));

filename = strcat(subject,'Cal.txt');

eyeData = importdata(filename);
eyeMark = eyeData(:,2);
start = find(eyeMark>65000);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);

rawChannel1 = channel1(start:start+26999);
rawChannel2 = channel2(start:start+26999) ;

zeroRaw = rawChannel2;

for i = 1:9
    calTrials(:,i) = zeroRaw(1:3000);
    zeroRaw(1:3000) = [];
end

A = 58;%the screen is 58 cm from the chinrest
B = 3.9;%the first calibration point is 3.9 cm from the middle fixation point
C = 7.8;%the second calibration pount is 7.8 cm from the middle fixation point

angle1 = atand(B/A);
angle2 = atand(C/A);

for i = 2:9
    meanZero(:,i-1) = mean(calTrials(1:200,i));
    meanAngle(:,i-1) = mean(calTrials(800:end,i));
    mvDiff(:,i-1) = abs(meanAngle(:,i-1))-abs(meanZero(:,i-1));
    fit1(:,i-1) = mvDiff(:,i-1)/angle1;
    fit2(:,i-1) = mvDiff(:,i-1)/angle2;
end

fitVars = [fit1(:,1:4) fit2(:,5:8)];
zeroRaw = rawChannel2-rawChannel2(1,1);

scrsz = get(0,'ScreenSize');
figure('Position',scrsz);
MaxX = length(zeroRaw);
Xaxes = ((1:MaxX)/1000)';

for i = 1:8
    
    plotNum = horzcat('81',num2str(i));
    plotNum = str2num(plotNum);
    
    %subplot(plotNum);
    testdata = zeroRaw/abs(fitVars(:,i));
    plot(Xaxes,testdata,'b');
    hold on
    
end
fitVariable = mean(abs(fitVars));
testdata = zeroRaw/fitVariable;
plot(Xaxes,testdata,'r');
ylabel ('Displacement (°)');
xlabel('Time (s)');
set(gca,'fontsize',30);
pause
close all

clearvars -except subject fitVariable
save(char(strcat(subject,{'-'},'EOGcalibration.mat')));

msgbox('EOG Calibration for OTC Complete');
clr