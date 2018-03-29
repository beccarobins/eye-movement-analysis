clr
display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name) %moves directory to chosen folder
warning('off'); %#ok<*WNOFF>

textDirectory = dir('*.txt');
for k = 1:length(textDirectory);
    FileNames(k,:) = {textDirectory(k,:).name}; %#ok<*SAGROW>
end

environment = input('Physical environment or virtual reality?\n (1) PE \n (2) VR\n'); %determine the environment the data collection was performed in

number = 1:length(FileNames);
number = number';
Files = horzcat(num2cell(number),FileNames);

display(Files)

file = input('Which eye file to use?\n'); %select the file for analysis

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

calChannel1 = calChannel1-calChannel1(1,1);%zeros out the dataset
calChannel2 = calChannel2-calChannel2(1,1);

%choose the time frames in which the convergence occurs
%used to create graphs of each individual convergence event
scrsz = get(0,'ScreenSize');
figure('Position',scrsz);
plot(calChannel1,'r','LineWidth',1.5)
hold on
plot(calChannel2,'b','LineWidth',1.5)
for i  = 1:3
    [times(i,1),position(i,1)] = ginput(1);
end
close all
for j = 1:3;
    channel1(:,j) = calChannel1(times(j,1):(times(j,1)+9999));
    channel2(:,j) = calChannel2(times(j,1):(times(j,1)+9999)) ;
end

for j = 1:3;
    channel1(:,j) = (channel1(:,j))-channel1(1,j);
    channel2(:,j) = (channel2(:,j))-channel2(1,j);
end

%filter data
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

%plots figures for quantifying convergence

for i = 1:3
    scrsz = get(0,'ScreenSize');
    figure('Position',scrsz);
    plot(filtChannel110(:,i)-filtChannel110(1,i),'r','LineWidth',1.5)
    hold on
    plot(filtChannel210(:,i)-filtChannel210(1,i),'b','LineWidth',1.5)
    hold on
    %set(gca,'fontsize',20);
    xlabel ('Time(s)','FontSize',30);
    
    display('pick begining of trial and time frame surrounding convergence event for each trial (3 points total)');
    
    for j  = 1:3 %#ok<*FXSET>
        [times(j,:),position(j,:)] = ginput(1);
    end
    for k  = 1:3
        picktime(k,1) = round(times(k,1));
    end
    
    fixationRight = filtChannel110(picktime(1,1):picktime(2,1));
    fixationLeft = filtChannel210(picktime(1,1):picktime(2,1));
    convergenceRight = filtChannel110(picktime(2,1):picktime(3,1));
    convergenceLeft = filtChannel110(picktime(2,1):picktime(3,1));
    meanFixRight = mean(fixationRight);
    meanFixLeft=  mean(fixationLeft);
    maxConvergenceRight = abs(max(convergenceRight));
    maxConvergenceLeft=  abs(max(convergenceLeft));
    minConvergenceRight = abs(min(convergenceRight));
    minConvergenceLeft=  abs(min(convergenceLeft));
    
    if minConvergenceRight>maxConvergenceRight
        maxConvergenceRight = minConvergenceRight;
    end
    
    if minConvergenceLeft>maxConvergenceLeft
        maxConvergenceLeft = minConvergenceLeft;
    end
    
    totalConvergence(i,2) = maxConvergenceRight-meanFixRight;
    totalConvergence(i,1) = maxConvergenceLeft-meanFixLeft;
    close
end

%plots final figure
titles = {'PE: convergence','VR: convergence'};
scrsz = get(0,'ScreenSize');
figure('Position',scrsz);
Xaxes = ((1:10000)/1000)';
ylabel ('Displacement(°)','FontSize',30);

for i = 1:3
    plotnumber = str2double(strcat('31',num2str(i)));
    subplot(plotnumber);
    plot(Xaxes,filtChannel110(:,i)-filtChannel110(1,i),'r','LineWidth',1.5)
    hold on
    plot(Xaxes,filtChannel210(:,i)-filtChannel210(1,i),'b','LineWidth',1.5)
    hold on
    gainPhrase = 'test';
    text(7,30,strcat('Convergence_{LeftEye}',{' '},'=',{' '},num2str(totalConvergence(i,1))),'FontSize',20);
    text(7,-30,strcat('Convergence_{RightEye}',{' '},'=',{' '},num2str(totalConvergence(i,2))),'FontSize',20);
    set(gca,'fontsize',20);
    axis([0 10 -50 50])
end

xlabel ('Time(s)','FontSize',30);
pause
%saves final figure
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