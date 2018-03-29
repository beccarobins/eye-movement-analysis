%%Saccades

% clr;
% display('Open participant folder');
% folder_name = uigetdir; %select participant folder
% cd(folder_name)
% name = [folder_name '\*.txt'];
% name = [pwd '\*.txt'];

% textDirectory = dir('*.txt');
% for k = 1:length(textDirectory);
%     FileNames(k,:) = {textDirectory(k,:).name}; %#ok<*SAGROW>
% end

subject = '00';
%subject = input('What is participant ID\n','s');
MainFilename = sprintf(strcat(subject,'-OTC.xlsx'));
%%
%horizontal reflexive saccades
filename = strcat(subject,'HRS.txt');
eyeData = importdata(filename);
eyeMark = eyeData(:,2);
start = find(eyeMark>65000);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);
%%
load(strcat(subject,'-EOGCalibration.mat'));

rawChannel1 = channel1(start:end,:);
rawChannel2 = channel2(start:end,:);

fitChannel1 = rawChannel1/fitVariable;
fitChannel2 = rawChannel2/fitVariable;

[b,a] = butter(2,10/500,'low');
filtChannel1 = filtfilt(b,a,fitChannel1);
filtChannel2 = filtfilt(b,a,fitChannel2);

saccadeBlock = filtChannel2;
for i = 1:40
    saccadeTrials(:,i) = saccadeBlock(1:2000);
    saccadeBlock(1:2000) = [];
    
    saccadeTrials(:,i) = saccadeTrials(:,i)-saccadeTrials(1,i);
    
    Max = max(saccadeTrials(:,i));
    Min = abs(min(saccadeTrials(:,i)));
    
    if Min>Max
        saccadeTrials(:,i) = -saccadeTrials(:,i);
        saccadeDirection(:,i) = {'Left'};
    else
        saccadeTrials(:,i) = saccadeTrials(:,i);
        saccadeDirection(:,i) = {'Right'};
    end
    
    saccadesVel(:,i) = diff(saccadeTrials(:,i))*1000;
    saccadesAcc(:,i) = diff(saccadesVel(:,i))*1000;
    
end
%%
for i = 1:40
    
    displacement = saccadeTrials(:,i);
    velocity = saccadesVel(:,i);
    acceleration = saccadesAcc(:,i);
    
    onset = saccadeonsetlatency(displacement,velocity,i);
    testTrial = isnan(onset);
    
    if testTrial==1
        saccadeEnd(1,i) = nan;
        saccadeDur(1,i) = nan;
        saccadeMaxAmp(1,i) = nan;
        saccadeMaxVel(1,i) = nan;
        saccadeMaxAcc(1,i) = nan;
    else
        saccadeLat(1,i) = onset;
        endTime = saccadeendtime(displacement,velocity,i);
        saccadeEnd(1,i) = endTime;
        saccadeDur(1,i) = endTime-onset;
        saccadeMaxAmp(1,i) = displacement(endTime);
        saccadeMaxVel(1,i) = max(velocity(saccadeLat(1,i):saccadeEnd(1,i)));
        saccadeMaxAcc(1,i) = max(acceleration(saccadeLat(1,i):saccadeEnd(1,i)));
    end
    clearvars displacement velocity acceleration endTime onset
end
%%
%NOT FINISHED YET
saccadeValHeading = {'Trials','Angle','Direction','Latency (ms)','Duration (ms)','Amplitude (°)','Velocity (°s-1)','Acceleration (°s-2)'};
saccadeValues = [stimulusAngles saccadeDirection' saccadeLat' saccadeDur' saccadeMaxAmp' saccadeMaxVel' saccadeMaxAcc'];

xlswrite(MainFilename,saccadeValHeading,'Horz Reflex Saccades','A1');
xlswrite(MainFilename,saccadeValues,'Saccades','B2');
%%
clearvars -except MainFilename subject

%%
filename = strcat(subject,'OKN.txt');
eyeData = importdata(filename);
eyeMark = eyeData(:,2);
start = find(eyeMark>65000);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);
%%
load(strcat(subject,'-EOGCalibration.mat'));

rawChannel1 = channel1(start:end,:);
rawChannel2 = channel2(start:end,:);

fitChannel1 = rawChannel1/fitVariable;
fitChannel2 = rawChannel2/fitVariable;

[b,a] = butter(2,10/500,'low');
filtChannel1 = filtfilt(b,a,fitChannel1);
filtChannel2 = filtfilt(b,a,fitChannel2);

oknBlock = filtChannel2;
%set time for okn 10S, 15s, or 20s

%%ADD ANALYSIS FROM TURNING STUDY

%%