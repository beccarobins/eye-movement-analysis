function saccadeData = saccades(displacement,velocity,acceleration)
%%
% scrsz = get(0,'ScreenSize');
% figure('Position',scrsz);
% plot(displacement);
% [X1,Y1] = ginput(1);
% [X2,Y2] = ginput(1);
% title(strcat('Trial: ',num2str(trial)));
% onset = round(X1);
% endTime = round(X2);
% close all
onset = 2;
endTime = 1000;

positiveZeroCrossing = 0;

for N = onset:endTime;
    if velocity(N-1)<0 && velocity(N)>=0
        positiveZeroCrossing = positiveZeroCrossing+1;
        positiveZeroCrossingTimes(positiveZeroCrossing) = N; %#ok<*SAGROW>
    end
    
end

%finds all troughs for nystagmus portion of movement

negativeZeroCrossing = 0;

for N = onset:endTime;
    if velocity(N-1)>=0 && velocity(N)<0
        negativeZeroCrossing = negativeZeroCrossing+1;
        negativeZeroCrossingTimes(negativeZeroCrossing) = N;
    end
    
end

positiveZeroCrossingTimes = positiveZeroCrossingTimes';
negativeZeroCrossingTimes = negativeZeroCrossingTimes';

%Determines the order of the peaks and troughs
%Puts peak times and trough times together for comparison
%Troughs are in column 1 and peaks in column 2

start = 1;

if length(positiveZeroCrossingTimes)==length(negativeZeroCrossingTimes);
    if positiveZeroCrossingTimes(1,1)<negativeZeroCrossingTimes; %#ok<*BDSCI>
        times(:,1) = positiveZeroCrossingTimes;
        times(:,2) = negativeZeroCrossingTimes;
    else
        times(:,1) = negativeZeroCrossingTimes;
        times(:,2) = positiveZeroCrossingTimes;
    end
else
    if positiveZeroCrossingTimes(1,1)>negativeZeroCrossingTimes(1,1)
        positiveZeroCrossingTimes = vertcat(start,positiveZeroCrossingTimes); %#ok<*AGROW>
    else
        negativeZeroCrossingTimes = vertcat(start,negativeZeroCrossingTimes);
    end
    if positiveZeroCrossingTimes(1,1)==1;
        times(:,1) = positiveZeroCrossingTimes;
        times(:,2) = negativeZeroCrossingTimes;
    else
        times(:,1) = negativeZeroCrossingTimes;
        times(:,2) = positiveZeroCrossingTimes;
    end
end

%finds the time between a peak and the following trough

betweenTimes = times((2:end),1);
betweenTimes = vertcat(betweenTimes,endTime);
times(:,3) = betweenTimes;
clearvars betweenTimes
betweenTimes = times((2:end),2);betweenTimes = vertcat(betweenTimes,endTime+100);
times(:,4) = betweenTimes;

[r,c] = size(times); %#ok<*ASGLU,*NASGU>

for j = 1:r;
    negativetopositive(j,1) = displacement(times(j,2))-displacement(times(j,1));
    negativetopositive(j,2) = displacement(times(j,3))-displacement(times(j,2));
end

%determines which set of times represents fast movements and which represents slow
%movement
%determines beginning and end times for fast and slow movements

if sum(negativetopositive(:,1))>0;
    fastComponent = negativetopositive(:,1);
    slowComponent = negativetopositive(:,2);
    fastTimes(:,1) = times(:,1);
    fastTimes(:,2) = times(:,2);
    slowTimes(:,1) = times(:,2);
    slowTimes(:,2) = times(:,3);
else
    fastComponent = negativetopositive(:,2);
    slowComponent = negativetopositive(:,1);
    fastTimes(:,1) = times(:,2);
    fastTimes(:,2) = times(:,3);
    slowTimes(:,1) = times(:,3);
    slowTimes(:,2) = times(:,4);
end

%determines the maximum velocity reached during each fast and slow
%movement

[r,c] = size(fastTimes);

for j = 1:r;
    fastComponentVel(j,1) = max(velocity(fastTimes(j,1):fastTimes(j,2)));
    %slowComponentVel(j,1) = min(velocity(slowTimes(j,1):slowTimes(j,2)));
end

%tallies which fast movements are considered fast phases
%uses a velocity threshold and an amplitude threshold

saccadeData = struct;

saccadeData.Total = 0;

for N = 1:length(fastComponentVel);
    if fastComponentVel(N)>=30&& fastComponent(N)>=1.5;
        saccadeData.Total = saccadeData.Total+1;
        saccadeTimes(saccadeData.Total) = N;
    end
end
%%
%determines the onset latency and end time of each fast phase
if saccadeData.Total>0
    
    saccadeTimes = saccadeTimes';
    
    for j = 1:saccadeData.Total;
        Time(j,1) = fastTimes(saccadeTimes(j,1),1);
        Time(j,2) = fastTimes(saccadeTimes(j,1),2);
    end
    
    %might be able to get rid of this
    
    E = find(Time(:,1)>onset);
    PostProcessingStartTimes = Time(E(1,1):end,:);
    saccadeData.Total = length(E);
    clearvars Time
    Time = PostProcessingStartTimes;
    
    %determines onset latencies, end time, amplitude, velocities,
    %and accelerations for each individual fast phase
    %determines mean fast phase amplitude, velocity and
    %acceleration
    %determines peak fast phase amplitude, velocity and
    %acceleration
    
    for j = 1:saccadeData.Total;
        saccadeData.onsetMS(j,1) = Time(j,1);
        saccadeData.onsetSec(j,1) = saccadeData.onsetMS(j,1)/1000;
        saccadeData.endMS(j,1) = Time(j,2);
        saccadeData.endSec(j,1) = saccadeData.endMS(j,1)/1000;
        saccadeData.durationMS(j,1) = Time(j,2)-Time(j,1);
        saccadeData.durationSec(j,1) = saccadeData.durationMS(j,1)/1000;
        saccadeData.onsetPosition(j,1) = displacement(saccadeData.onsetMS(j,1));
        saccadeData.Position(j,1) = displacement(saccadeData.endMS(j,1));
        saccadeData.amplitudes(j,1)  = displacement(Time(j,2))-displacement(Time(j,1));
        saccadeData.velocities(j,1) = max(velocity(Time(j,1):Time(j,2)));
        saccadeData.Q(j,1) = (max(velocity(Time(j,1):Time(j,2))))/(mean(velocity(Time(j,1):Time(j,2))));%from Neurology of Eye Movements page
        saccadeData.accelerations(j,1) = max(acceleration(Time(j,1):Time(j,2)));
        saccadeData.maxAmp = max(saccadeData.amplitudes);
        saccadeData.peakVel = max(saccadeData.velocities);
        saccadeData.peakAcc = max(saccadeData.accelerations);
        saccadeData.meanAmp = mean(saccadeData.amplitudes);
        saccadeData.SDAmp = std(saccadeData.amplitudes);
        saccadeData.meanVel = mean(saccadeData.velocities);
        saccadeData.SDVel = std(saccadeData.velocities);
        saccadeData.meanAcc = mean(saccadeData.accelerations);
        saccadeData.SDAcc = std(saccadeData.accelerations);
    end
else
    saccadeData.onsetMS(j,1) = nan;
    saccadeData.onsetSec(j,1) = nan;
    saccadeData.endMS(j,1) = nan;
    saccadeData.endSec(j,1) = nan;
    saccadeData.durationMS(j,1) = nan;
    saccadeData.durationSec(j,1) = nan;
    saccadeData.onsetPosition(j,1) = nan;
    saccadeData.Position(j,1) = nan;
    saccadeData.amplitudes(j,1)  = nan;
    saccadeData.velocities(j,1) = nan;
    saccadeData.accelerations(j,1) = nan;
    saccadeData.maxAmp = nan;
    saccadeData.peakVel = nan;
    saccadeData.peakAcc = nan;
    saccadeData.meanAmp = nan;
    saccadeData.SDAmp = nan;
    saccadeData.meanVel = nan;
    saccadeData.SDVel = nan;
    saccadeData.meanAcc = nan;
    saccadeData.SDAcc = nan;
end