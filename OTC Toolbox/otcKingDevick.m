%King Devick script

% quantify saccades
% 
% frequency distribution
% bins of 5 degrees
% 
% measure durations using marks

% clr;
% display('Open participant folder');
% folder_name = uigetdir; %select participant folder
% cd(folder_name)
% name = [folder_name '\*.txt'];
% name = [pwd '\*.txt'];
% 
% textDirectory = dir('*.txt');
% for k = 1:length(textDirectory);
%     FileNames(k,:) = {textDirectory(k,:).name}; %#ok<*SAGROW>
% end

subject = input('What is participant ID\n','s');

filename = strcat(subject,'KD.txt');
eyeData = importdata(filename);
eyeMark = eyeData(:,2);
start = find(eyeMark>65000);
channel1 = eyeData(:,3);
channel2 = eyeData(:,4);
%%
load(strcat(subject,'-EOGCalibration.mat'));

fitChannel1 = channel1/fitVariable;
fitChannel2 = channel2/fitVariable;

[b,a] = butter(2,10/500,'low');
filtChannel1 = filtfilt(b,a,fitChannel1);
filtChannel2 = filtfilt(b,a,fitChannel2);

%%cut data into sections
%%divided into the separate KD testing cards
demo = filtChannel2(start(1,1):start(2,1));
demo = demo-demo(1,1);
KD = filtChannel2(start(2,1):start(5,1));
KD = KD-KD(1,1);
KDcard1 = filtChannel2(start(2,1):start(3,1));
KDcard1 = KDcard1-KDcard1(1,1);
KDcard2 = filtChannel2(start(3,1):start(4,1));
KDcard2 = KDcard2-KDcard2(1,1);
KDcard3 = filtChannel2(start(4,1):start(5,1));
KDcard3 = KDcard3-KDcard3(1,1);
KDduration = length(KD)/1000;

KDvel = diff(KD)*1000;
KDcard1vel = diff(KDcard1)*1000;

KDTotalSaccades = 0;

for N = 2:length(KD)-2
   
    if KDvel(N-1)<KDvel(N) && KDvel(N+1)<KDvel(N) && KDvel(N)>30
        KDTotalsaccades = KDTotalsaccades+1;
        KDpeakVelTimes(saccades,1) = N;
    end
    
end

for i = 1:KDTotalsaccades
KDpeakVel(i,:) = KDvel(KDpeakVelTimes(i,:));
end

minSaccade = min(KDpeakVel);
maxSaccade = max(KDpeakVel);
meanSaccade = mean(KDpeakVel);