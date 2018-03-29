display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name)
folder_name = pwd;
name = [folder_name '\*.txt'];
TextDirectory = dir(name);

warning('off');

subject = strsplit(folder_name,'\');%subject name generated from folder
subject = char(subject(:,end));
subject = char(strsplit(subject,'_'));

preFilename = strcat(subject,'BESS-PRE.txt');
postFilename = strcat(subject,'BESS-POST.txt');
headCalFilename = strcat(subject,'HeadCal.txt');
eyeCalFilename = strcat(subject,'EyeCal.txt');

eyeData = importdata(eyeCalFilename);
eyeMark = eyeData(:,2);
start = find(eyeMark>1000);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);
rawEOG1 = channel1(start:end,:);
rawEOG2 = channel2(start:end,:);%perform horizontal calibration followed by vertical calibration on same file
%subEOG1 = rawEOG1(1:13.5:end,:);%DK2 samples at ~75Hz
subEOG1 = rawEOG1(1:11.11:end,:);%DK3 samples at ~90Hz
%subEOG2 = rawEOG2(1:13.5:end,:);%DK2 samples at ~75Hz
subEOG2 = rawEOG2(1:11.11:end,:);%DK3 samples at ~90Hz

headData = importdata(headCalFilename);
headYaw = headData.data(:,2);
headMark = headData.data(:,4);

horzFit = vorCalibration(subEOG1,headYaw);
%vertFit = vorCalibration(subEOG2,headYaw);

eyeData = importdata(preFilename);
eyeMark = eyeData(:,2);
start = find(eyeMark>1000);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);

[b,a] = butter(2,30/500,'low');
horzEOGDeg = channel1*(horzFit(1,1))+horzFit(1,2);
horzEOGDeg = filtfilt(b,a,horzEOGDeg);
horzEOGDeg = horzEOGDeg-horzEOGDeg(1,1);
%vertEOGDeg = channel2*(vertFit(1,1))+vertFit(1,2);
%vertEOGDeg = filtfilt(b,a,vertEOGDeg);
%vertEOGDeg = vertEOGDeg-vertEOGDeg(1,1);

eyePre.X = horzEOGDeg;
%eyePre.Y = vertEOGDeg;

trialNames = {'Firm-Double';'Firm-Single';'Firm-Tandem';'Foam-Double';'Foam-Single';'Foam-Tandem'};

for i = 1:6
    trialX(:,i) = channel1(start(i,:):start(i,:)+20000);
    trialX(:,i) = trialX(:,i)-trialX(1,i);
    trialY(:,i) = channel2(start(i,:):start(i,:)+20000);
    trialY(:,i) = trialY(:,i)-trialY(1,i);
end

%%

%add eyedata to eyePRE and Post struct using trial name

for i = 1:1
    scrsz = get(0,'ScreenSize');
    figure('Position',scrsz);
    plot(eyePre.FirmDoubleX,eyePre.FirmDoubleY,'-k','LineWidth',2);%THIS NEEDS TO BE UPDATED
    hold
    plot(eyePost.FirmDoubleX,eyePost.FirmDoubleY,'color',[.5 .5 .5],'LineStyle','-','LineWidth',2);%THIS NEEDS TO BE UPDATED
    Title = char(strcat(subject,{' - '},trialNames(i,1)));
    title(Title,'fontsize',30,'fontweight','bold');
    yLabel = strcat('Vertical component (', sprintf('%c', char(176)),')');
    xLabel = strcat('Horizonital component (', sprintf('%c', char(176)),')');
    ylabel(yLabel,'fontsize',22,'fontweight','bold');
    xlabel(xLabel,'fontsize',22,'fontweight','bold');
    set(gca,'fontsize',22)
    Legend = {'PRE','POST'};
    legend(Legend,'Location','NorthEast','fontsize',22);
    legend('boxoff');
    box('off')
    %axis([0 15 -20 80]); %%NEED TO FIGURE OUT APPROPRIATE AXIS LIMITS
    axis square
    pause
    
    %rez=1200; %resolution (dpi) of final graphic
    fighand=gcf; %f is the handle of the figure you want to export
    figpos=getpixelposition(fighand); %dont need to change anything here
    resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
    set(fighand,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
    path= pwd; %the folder where you want to put the file
    name = char(strcat(subject,{' - '},trialNames(i,1),'.tiff'));
    print(fighand,fullfile(path,name),'-dtiff','-r300','-opengl'); %save file
    clearvars fighand figpos resolution path name
    close all
end