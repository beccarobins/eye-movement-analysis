clr
display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name)

textDirectory = dir('*.txt');
for k = 1:length(textDirectory);
    FileNames(k,:) = {textDirectory(k,:).name}; %#ok<*SAGROW>
end

environment = input('Physical environment or virtual reality?\n (1) PE \n (2) VR\n');

number = 1:length(FileNames);
number = number';
Files = horzcat(num2cell(number),FileNames);

display(Files)

file = input('Which eye file to use?\n');

filename = char(FileNames(file,1));
eyeData = importdata(filename);
eyeMark = eyeData(:,2);
start = find(eyeMark>0);
rawChannel1 = eyeData(:,3);
rawChannel2 = eyeData(:,4);

caltype = input('Which calibration was used?\n(1) point calibration\n(2) VOR calibration\n');

if caltype==1
    load('pointCalibration.mat');
    calChannel1 = rawChannel1/fitVariableRight;
    calChannel2 = rawChannel2/fitVariableLeft;
else
    load('vorCalibration.mat');
    calChannel1 = rawChannel1*(fitVariableRight(1,1))+fitVariableRight(1,2);
    calChannel2 = rawChannel2*(fitVariableLeft(1,1))+fitVariableLeft(1,2);
end

calChannel1 = calChannel1-calChannel1(1,1);
calChannel2 = calChannel2-calChannel2(1,1);

scrsz = get(0,'ScreenSize');
figure('Position',scrsz);

plot(calChannel1,'r','LineWidth',1.5)
hold on
plot(calChannel2,'b','LineWidth',1.5)
[X1,~] = ginput(1);
[X2,~] = ginput(1);
close all

channel1 = calChannel1(X1:X2,:);
channel2 = calChannel2(X1:X2,:);

[b,a] = butter(2,10/500,'low');
[d,c] = butter(2,30/500,'low');
[f,e] = butter(2,20/500,'low');
[h,g] = butter(2,25/500,'low');

filtChannel110 = filtfilt(b,a,channel1);
filtChannel120 = filtfilt(f,e,channel1);
filtChannel125 = filtfilt(h,g,channel1);
filtChannel130 = filtfilt(d,c,channel1);
filtChannel210 = filtfilt(b,a,channel2);
filtChannel220 = filtfilt(f,e,channel2);
filtChannel225 = filtfilt(h,g,channel2);
filtChannel230 = filtfilt(d,c,channel2);

titles = {'PE: expansion','VR: expansion'};

scrsz = get(0,'ScreenSize');
figure('Position',scrsz);

Xaxes = ((1:length(filtChannel110))/1000)';
plot(Xaxes,(filtChannel110),'r','LineWidth',1.5)
hold on
plot(Xaxes,(filtChannel210),'b','LineWidth',1.5)
%set(gca,'fontsize',20);
xlabel ('Time(s)','FontSize',30);

rez=1200; %resolution (dpi) of final graphic
f=gcf; %f is the handle of the figure you want to export
figpos=getpixelposition(f); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
path= pwd; %the folder where you want to put the file

imagename = char(titles(1,environment));
imagename = strsplit(imagename,':');
imagename = char(strcat(imagename(1,1),imagename(1,2)));

name = (strcat(imagename,'.eps'));
print(f,fullfile(path,name),'-depsc','-r0','-opengl'); %save file

clr