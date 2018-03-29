%smooth Pursuit

clr;
display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name)

subject = '00';
%subject = input('What is participant ID\n','s');

MainFilename = sprintf(strcat(subject,'-OTC.xlsx'));

filename = '00sinusoidalLR.txt';
%filename = strcat(subject,'Cal.txt');

eyeData = importdata(filename);
eyeMark = eyeData(:,2);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);
start = find(eyeMark>65000);
%rawChannel1 = channel1(start:start+19999);%change to 29999 when fixed
rawChannel2 = channel2(start:end) ;

load(strcat(subject,'-EOGCalibration.mat'));

EOGDeg = rawChannel2/fitVariable;
[b,a] = butter(2,1/500,'low');
EOGDeg = filtfilt(b,a,EOGDeg);
EOGDeg = EOGDeg-EOGDeg(1,1);

subEOG = EOGDeg(1:16.835:end);%subsample EOG to unity frequency
%subEOG = detrend(subEOG);
eogVel = diff(subEOG)*59.4;

%filename = 'OCULAR1_HorizSineSP.txt';
%stim1 = importdata(filename);
load('stimProfile.mat');
%%
stim1Deg = stimProfile*2.5973;
[b,a] = butter(2,10/59.4,'low');
stim1Filt = filtfilt(b,a,stim1Deg);
stim1Vel = diff(stim1Filt)*59.4;

scrsz = get(0,'ScreenSize');
figure('Position',scrsz);
MaxX = length(stim1Filt);
Xaxes = ((1:MaxX)/59.4)';

plot(Xaxes,stim1Filt,'r');
hold on
plot(Xaxes,subEOG(1:MaxX),'b');
legend('Stimulus','Eye','location','northeast')
ylabel ('Displacement (°)');
xlabel('Time (s)');
set(gca,'fontsize',25);
pause
close all

subTest = subEOG(1:MaxX);

for M = 1:length(subTest)
    for N = 1:length(subTest)-1
        leastSq(N,1) =  sqrt((subTest(N)-stim1Filt(N))^2)+sqrt((subTest(N+1)-stim1Filt(N+1))^2);
    end
    subTest(1,:) = [];
    leastSqSum(M,1) = sum(leastSq);
end

[~,delay] = min(leastSqSum);

stimMinima = 0;

for N = 2:length(stim1Filt)-1
    
    if stim1Filt(N-1)>stim1Filt(N) && stim1Filt(N+1)>stim1Filt(N)
        stimMinima = stimMinima+1;
        stimMinimaTimes(stimMinima,1) = N;
    end
    
end

for i = 1:stimMinima-1
   stimCycle(:,i) = stim1Filt(stimMinimaTimes(i,:):stimMinimaTimes(i+1,:));
   eyeCycle(:,i) = detrend(subEOG(stimMinimaTimes(i,:):stimMinimaTimes(i+1,:)));
end

MaxX = length(stimCycle);
CycleAxes = ((1:MaxX)/60)';

for i = 1:stimMinima-1
    figure('Position',scrsz);
    plot(CycleAxes,stimCycle(:,i),'r');
    hold on
    plot(CycleAxes,eyeCycle(:,i),'b');
    legend('Stimulus','Eye','location','northeast')
    ylabel ('Displacement (°)');
    xlabel('Time (s)');
    set(gca,'fontsize',25);
    pause
    close all
    
end
%%
clearvars leastSq leastSqSum

for i = 1:stimMinima-1
subTest = eyeCycle(:,i);
stimTest = stimCycle(:,i);

for M = 1:length(subTest)
    for N = 1:length(subTest)-1
        leastSq(N,1) =  sqrt((subTest(N)-stimTest(N))^2)+sqrt((subTest(N+1)-stimTest(N+1))^2);
    end
    subTest(1,:) = [];
    leastSqSum(M,i) = sum(leastSq);
end

end

[~,cycleDelays] = min(leastSqSum);

% stimPeaks = 0;
% 
% for N = 2:length(stim1Filt)-2
%     
%     if stim1Filt(N-1)<stim1Filt(N) && stim1Filt(N+1)<stim1Filt(N)
%         stimPeaks = stimPeaks+1;
%         stimPeakTimes(stimPeaks,1) = N;
%     end
%     
% end
% 
% eogPeaks = 0;
% 
% for N = 2:length(subEOG)-2
%     
%     if subEOG(N-1)<subEOG(N) && subEOG(N+1)<subEOG(N) && subEOG(N)>5
%         eogPeaks = eogPeaks+1;
%         eogPeakTimes(eogPeaks,1) = N;
%     end
%     
% end
% 
% Lag = eogPeakTimes-stimPeakTimes;
% meanLag = mean(Lag);
% sdLag = std(Lag);
% 
% %removeLagOutliers
% 
% for N = 2:length(Lag)
%     
%     if Lag(N)> meanLag+sdLag || Lag(N)<meanLag-sdLag
%         Lag(N) = nan;
%     end
%     
% end
% 
% meanLag = nanmean(Lag);
%%
%Gain=output/input
% 
% stimVelPeaksN = 0;
% 
% for N = 2:length(stim1Vel)-2
%     
%     if stim1Vel(N-1)<stim1Vel(N) && stim1Vel(N+1)<stim1Vel(N)&&stim1Vel(N)>0
%         stimVelPeaksN = stimVelPeaksN+1;
%         stimVelPeakTimes(stimVelPeaksN,1) = N;
%         stimVelPeaks(stimVelPeaksN,1) = stim1Vel(N);
%     end
%     
% end
% 
% eogVelPeaksN = 0;
% 
% for N = 2:length(subEOG)-2
%     
%     if eogVel(N-1)<eogVel(N) && eogVel(N+1)<eogVel(N) && eogVel(N)>5
%         eogVelPeaksN = eogVelPeaksN+1;
%         eogVelPeakTimes(eogVelPeaksN,1) = N;
%         eogVelPeaks(eogVelPeaksN,1) = eogVel(N);
%     end
%     
% end
% 
% eogPeaksOnly = eogVelPeaks;
% 
% eogVelPeaksN = 0;
% clearvars eogVelPeaks eogVelPeakTimes
% 
% for N = 2:length(eogPeaksOnly)-2
%     
%     if eogPeaksOnly(N-1)<eogPeaksOnly(N) && eogPeaksOnly(N+1)<eogPeaksOnly(N) && eogPeaksOnly(N)>5
%         eogVelPeaksN = eogVelPeaksN+1;
%         eogVelPeakTimes(eogVelPeaksN,1) = N;
%         eogVelPeaks(eogVelPeaksN,1) = eogPeaksOnly(N);
%     end
%     
% end

%Gain=output/input
%%
% Gain = eogVelPeaks./stimVelPeaks;
% meanGain = mean(Gain);

%testGain = eogVel./stim1Vel;
% shiftEOGVel = eogVel(meanLag+1:end);
% fixstim1Vel = stim1Vel(1:end-meanLag);
% 
% MaxX = length(stim1Vel);
% Xaxes = ((1:MaxX)/60)';
% 
% figure('Position',scrsz);
% plot(Xaxes,stim1Vel,'r');
% hold on
% plot(Xaxes,eogVel,'b');
% legend('Stimulus','Eye','location','northeast')
% ylabel ('Velocity (°s^-1)');
% xlabel('Time (s)');
% set(gca,'fontsize',25);
% pause
% close all
% 
% 
% plot(fixstim1Vel,'r');
% hold on
% plot(shiftEOGVel,'b');
% pause
% close all
%testGain = shiftEOGVel./fixstim1Vel;