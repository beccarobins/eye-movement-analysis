clr
display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name)
name = [folder_name '\*.txt'];

textDirectory = dir('*.txt');
for k = 1:length(textDirectory);
    FileNames(k,:) = {textDirectory(k,:).name}; %#ok<*SAGROW>
end

environment = input('Physical environment or virtual reality?\n (1) PE \n (2) VR\n');

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

caltype = input('Which calibration was used?\n(1) point calibration\n(2) VOR calibration\n');

if caltype==1
    load('pointCalibration.mat');
    calChannel1 = rawChannel1/abs(fitVariableRight);
    calChannel2 = rawChannel2/abs(fitVariableLeft);
else
    load('vorCalibration.mat');
    calChannel1 = rawChannel1*(fitVariableRight(1,1))+fitVariableRight(1,2);
    calChannel2 = rawChannel2*(fitVariableLeft(1,1))+fitVariableLeft(1,2);
end

for i = 1:9;
    calChannel1(:,i) = calChannel1(:,i)-calChannel1(1,i);
    calChannel2(:,i) = calChannel2(:,i)-calChannel2(1,i);
end

subChannel1 = calChannel1(1:13.35:end,:);
subChannel2 = calChannel2(1:13.35:end,:);

[b,a] = butter(2,10/500,'low');
[d,c] = butter(2,30/500,'low');
[f,e] = butter(2,20/500,'low');
[h,g] = butter(2,25/500,'low');

for j = 1:9;
    filtChannel110(:,j) = filtfilt(b,a,subChannel1(:,j));
    filtChannel120(:,j) = filtfilt(f,e,subChannel1(:,j));
    filtChannel125(:,j) = filtfilt(h,g,subChannel1(:,j));
    filtChannel130(:,j) = filtfilt(d,c,subChannel1(:,j));
    filtChannel210(:,j) = filtfilt(b,a,subChannel2(:,j));
    filtChannel220(:,j) = filtfilt(f,e,subChannel2(:,j));
    filtChannel225(:,j) = filtfilt(h,g,subChannel2(:,j));
    filtChannel230(:,j) = filtfilt(d,c,subChannel2(:,j));
end

%Check Eye and Head data together for calibration accuracy

clc
Xaxes = (((1:675)*13.3333)/1000)';

titles(:,1) = {'PE: 10cm(1)';'PE: 10cm(2)';'PE: 10cm(3)';'PE: 150cm(1)';'PE: 150cm(2)';'PE: 150cm(3)';'PE: 300cm(1)';'PE: 300cm(2)';'PE: 300cm(3)';};
titles(:,2) = {'VR: 10cm(1)';'VR: 10cm(2)';'VR: 10cm(3)';'VR: 300cm(1)';'VR: 300cm(2)';'VR: 300cm(3)';'VR: 150cm(1)';'VR: 150cm(2)';'VR: 150cm(3)';};

for i = 1:9
    
    scrsz = get(0,'ScreenSize');
    figure('Position',scrsz);
    plot(headDataPool(:,i),'k','LineWidth',1.5)
    hold on
    plot(filtChannel130(:,i),'r','LineWidth',1.5)
    plot(filtChannel230(:,i),'b','LineWidth',1.5)
    
    set(gca,'fontsize',20);
    xlabel ('Time(s)','FontSize',30);
    ylabel ('Displacement(°)','FontSize',30);
    for j  = 1:6 %#ok<*FXSET>
        [times(j,1),position(j,1)] = ginput(1);
    end
    
    for k  = 1:6
        picktime(k,1) = round(times(k,1));
    end
    
    for l  = 1:5
        eyepeakright(l,1) = max(filtChannel130(picktime(l,1):picktime(l+1,1)));
        eyetroughright(l,1) = min(filtChannel130(picktime(l,1):picktime(l+1,1)));
        eyepeakleft(l,1) = max(filtChannel230(picktime(l,1):picktime(l+1,1)));
        eyetroughleft(l,1) = min(filtChannel230(picktime(l,1):picktime(l+1,1)));
        headpeak(l,1) = max(headDataPool(picktime(l,1):picktime(l+1,1)));
        headtrough(l,1) = min(headDataPool(picktime(l,1):picktime(l+1,1)));
    end
    
    eyeDiffLeft = eyepeakleft-eyetroughleft;
    headDiff = headpeak-headtrough;
    GainLeft = eyeDiffLeft./headDiff;%Gain=output/input
    
    meanGainLeft = mean(GainLeft);
    
    eyeDiffRight = eyepeakright-eyetroughright;
    headDiff = headpeak-headtrough;
    GainRight = eyeDiffRight./headDiff;%Gain=output/input
    
    meanGainRight = mean(GainRight);
    
    close all
    
    scrsz = get(0,'ScreenSize');
    figure('Position',scrsz);
    plot(Xaxes,headDataPool(:,i),'k','LineWidth',1.5)
    hold on
    plot(Xaxes,filtChannel130(:,i),'r','LineWidth',1.5)
    plot(Xaxes,filtChannel230(:,i),'b','LineWidth',1.5)
    axis([0 9 -50 50])
    set(gca,'fontsize',20);
    xlabel ('Time(s)','FontSize',30);
    ylabel ('Displacement(°)','FontSize',30);
    if environment==1
        Title = titles(i,1);
    else
        Title = titles(i,2);
    end
    title(Title,'FontSize',40);
    text(7,-35,strcat('Gain_{meanRight}',{' '},'=',{' '},num2str(meanGainRight)),'FontSize',20);
    text(7,-45,strcat('Gain_{meanLeft}',{' '},'=',{' '},num2str(meanGainLeft)),'FontSize',20);
    pause
    
    rez=1200; %resolution (dpi) of final graphic
    f=gcf; %f is the handle of the figure you want to export
    figpos=getpixelposition(f); %dont need to change anything here
    resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
    set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
    path= pwd; %the folder where you want to put the file
    
    imagename = char(titles(i,environment));
    imagename = strsplit(imagename,':');
    imagename = char(strcat(imagename(1,1),imagename(1,2)));
    imagename = strsplit(imagename,'(');
    imagename = char(strcat(imagename(1,1),imagename(1,2)));
    imagename = strsplit(imagename,')');
    imagename = char(strcat(imagename(1,1),imagename(1,2)));
    
    name = (strcat(imagename,'.eps'));
    print(f,fullfile(path,name),'-depsc','-r0','-opengl'); %save file
    close 1
    
end

clr