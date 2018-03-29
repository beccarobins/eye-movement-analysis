clr;
display('Open participant folder');
folder_name = uigetdir; %select participant folder
cd(folder_name)
folder_name = pwd;

warning('off','all');

%subject = input('What is participant ID\n','s');
%decision = input('Which evaluation is being analyzed?\n(1) Pre\n(2) Mid\n(3) Post\n');

subject = strsplit(folder_name,'\');
subject = char(subject(1,end));

testFile = strcat('OMT-',subject,'-Pre.mat');
testFile = exist(testFile);

if testFile>0
    filename = strcat('OMT-',subject,'-Pre.mat');
    filename1 = strcat(subject,'EOGCal-Pre.txt');
    filename2 = strcat(subject,'HeadCal-Pre.txt');
    filename3 = strcat(subject,'EOGEval-Pre.txt');
    sheet = 'Pre';
    
    eyeData = importdata(filename1);
    eyeMark = eyeData(:,2);
    start = find(eyeMark>1000);
    channel2 = eyeData(:,4);
    rawEOG = channel2(start:end,:);
    
    headData = importdata(filename2);
    headYaw = headData.data(:,2);
    headMark = headData.data(:,4);
    
    testFile = exist(filename);
    
    if testFile>0
        load(filename);
    end
    
    testFit = exist('fitVar','var');
    
    if testFit==0
        step1 = 0;
        while step1~=1;
            %subEOG = rawEOG(1:13.5:end,:);%DK2 samples at ~75Hz
            subEOG = rawEOG(1:11.11:end,:);%DK3 samples at ~90Hz
            scrsz = get(0,'ScreenSize');
            figure('Position',scrsz);
            plot(subEOG);
            [X1,Y1] = ginput(1);
            [X2,Y2] = ginput(1);
            T1 = round(X1);
            T2 = round(X2);
            cal(:,1) = subEOG(T1:T2,:);
            cal(:,2) = headYaw(T1:T2,:);
            x = cal(:,1);
            y = cal(:,2);
            
            close all
            
            scatter(x,y,'bo');
            
            step1 = input('Is Fit Line acceptable?\n(1)Yes\n(2)No\n');
            
            if step1==1
                fitVar = polyfit(x,y,1);
                close all
                headYaw = headYaw-headYaw(1,1);
                EOGDeg = subEOG*(fitVar(1,1))+fitVar(1,2);
                EOGDeg = EOGDeg-EOGDeg(1,1);
                plot(EOGDeg,'b');
                hold
                plot(headYaw,'r');
                legend('Eye Position','Head Position','Location','NorthEast');
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
            close all
        end
    end
    
    clearvars -except subject fitVar folder_name filename3 group sheet
    
    MainFilename = sprintf(strcat(subject,'-OMT.xlsx'));
    saccadeValHeading = {'Trial #','Group','Angle','Total Amplitude','Saccade N','Mean Abs Pos Error','Latency (sec) - 1','Latency (sec) - 2','Latency (sec) - 3','Duration (sec) - 1','Duration (sec) - 2','Duration (sec) - 3','Amplitude (°) - 1','Amplitude (°) - 2','Amplitude (°) - 3','Velocity (°s-1) - 1','Velocity (°s-1) - 2','Velocity (°s-1) - 3','Peak Velocity (°s-1)','Acceleration (°s-2) - 1','Acceleration (°s-2) - 2','Acceleration (°s-2) - 3'};
    xlswrite(MainFilename,saccadeValHeading,strcat('Saccades-',sheet),'A1');
    deletesheet(folder_name,MainFilename)
    
    eyeData = importdata(filename3);
    eyeMark = eyeData(:,2);
    start = find(eyeMark>50);
    trialStart = start(1,1);
    eyeData = eyeData(trialStart:end,:);
    %channel1 = eyeData(:,3);
    channel2 = eyeData(:,4);
    EOGDeg = channel2*(fitVar(1,1))+fitVar(1,2);
    [b,a] = butter(2,30/500,'low');
    EOGDeg = filtfilt(b,a,EOGDeg);
    EOGDeg = detrend(EOGDeg);
    EOGDeg = EOGDeg-EOGDeg(1,1);
    
    %Smooth Pursuit Analysis
    filepath = 'C:\Users\tug41619\Documents\MATLAB\MATLAB Codes\OMT Toolbox';%if you get an error message here, change file path
    load([filepath '\' 'stimProfile.mat']);
    stimDeg = stimProfile*1.85;%%THIS IS NOT CORRECT, FIND THE CORRECT CONVERSION somewhere bewteen 1.75 & 2.75
    unitySampRate = length(stimProfile)/285;
    conversionFactor = 1000/unitySampRate;
    
    unitySameRateStr = num2str(unitySampRate);
    %display(strcat('Unity is sampling at',{' '},unitySameRateStr, {' '}, 'Hz'));
    subOMTEval = EOGDeg(1:conversionFactor:end);%%Subsampling from 1000Hz to 60Hz should use a conversion factor of 16.667
    %
    % spSessionDuration = unitySampRate*200;%sp session duration in frames
    % smoothPursuitBlock = subOMTEval(1:spSessionDuration);
    % spTrialDuration = unitySampRate*60;%sp trial duration in frames
    % spPause = unitySampRate*5;%duration of pause in frames
    %
    % for i = 1:3
    %     smoothPursuitTrials(:,i) = smoothPursuitBlock(spPause:spPause+spTrialDuration);
    %     smoothPursuitBlock(1:unitySampRate*65) = [];
    %     smoothPursuitTrials(:,i) = smoothPursuitTrials(:,i)-smoothPursuitTrials(1,i);
    %     stimTrial = stimDeg(spPause:spPause+spTrialDuration);
    %     stimDeg(1:unitySampRate*65) = [];
    %     %stimTrial = stimTrial-stimTrial(1,1);
    %
    %     scrsz = get(0,'ScreenSize');
    %     figure('Position',scrsz);
    %     MaxX = length(smoothPursuitTrials);%duration of sp trial
    %     Xaxes = ((1:MaxX)/unitySampRate)';
    %     plot(Xaxes,smoothPursuitTrials(:,i),'b');
    %     hold on
    %     plot(Xaxes,stimTrial,'r');
    %     legend('Eye','Stimulus','location','northeast')
    %     ylabel ('Displacement (°)');
    %     xlabel('Time (s)');
    %     set(gca,'fontsize',25);
    %     decision = input('Does the data need to be flipped?\n(1) Yes\n(0) No\n');
    %
    %     if decision==1
    %         smoothPursuitTrials(:,i) = -smoothPursuitTrials(:,i);
    %         smoothPursuitTrials(:,i) = smoothPursuitTrials(:,i)-smoothPursuitTrials(1,i);
    %         figure('Position',scrsz);
    %         plot(Xaxes,smoothPursuitTrials(:,i),'b');
    %         hold on
    %         plot(Xaxes,stimTrial,'r');
    %         legend('Eye','Stimulus','location','northeast')
    %         ylabel ('Displacement (°)');
    %         xlabel('Time (s)');
    %         set(gca,'fontsize',25);
    %         pause
    %     else
    %     end
    %
    %     close all
    %     smoothPursuitVelocity(:,i) = diff(smoothPursuitTrials(:,i))*unitySampRate;
    %
    %     %SPGain = eye velocity/target velocity
    %     %calculate peaks in SP and vel
    %     %calculate mean gain and mean lag
    % end
    
    smoothPursuitValHeading = {'Trials','Stimulus Velocity','Eye Velocity','Gain','Lag'};
    % smoothPursuitValues = {stimVel' eyeVel' Gain' Lag'};
    xlswrite(MainFilename,smoothPursuitValHeading,strcat('Smooth Pursuit-',sheet),'A1');
    % xlswrite(MainFilename,smoothPursuitValues,'Smooth Pursuit','B2');
    %
    %Saccade Analysis
    saccadeBlock = EOGDeg(200001:end,:);
    stimulusAngles = [-2;+2;+1;-1;+2;-3;+1;-2;+4;-1;-2;+3;-4;+2;+2;-4;+1;+2;-3;+4;-3;-1;+4;-4;+3;-3;+3;+1;-4;+3;-2;+1;-2;+4;-4;+4;-1;-3;+3;-1];%this IS the correct order, but the previous angles are correct
    
    for i = 1:40
        saccadeTrials(:,i) = saccadeBlock(1:2000); %#ok<*SAGROW>
        saccadeBlock(1:2000) = [];
        
        saccadeTrials(:,i) = saccadeTrials(:,i)-saccadeTrials(1,i);
        
        if stimulusAngles(i,:)<0
            saccadeTrials(:,i) = saccadeTrials(:,i);
        else
            saccadeTrials(:,i) = -saccadeTrials(:,i);
        end
        
        saccadesVel(:,i) = diff(saccadeTrials(:,i))*1000;
        saccadesAcc(:,i) = diff(saccadesVel(:,i))*1000;
        
    end
    
    stimulusAngles = [12;12;6;6;12;20;6;12;28;6;12;20;28;12;12;28;6;12;20;28;20;6;28;28;20;20;20;6;28;20;12;6;12;28;28;28;6;20;20;6];%this IS the correct order, but the angles are not correct
    
    for i = 1:40
        
        displacement = saccadeTrials(:,i);
        velocity = saccadesVel(:,i);
        acceleration = saccadesAcc(:,i);
        
        threeSaccadeMax = nan(1,3);
        saccadeData = saccades(displacement,velocity,acceleration);
        if saccadeData.onsetSec(1,1)<.05||saccadeData.onsetSec(1,1)>.6||sum(saccadeData.amplitudes)>stimulusAngles(i,:)+5||sum(saccadeData.amplitudes)<stimulusAngles(i,:)-5||saccadeData.Total>3
            saccadeData.Total = 0;
        end
        if saccadeData.Total>0
            saccadeValues(i,:) = [sum(saccadeData.amplitudes),saccadeData.Total,abs(((sum(saccadeData.amplitudes)-stimulusAngles(i,:))/stimulusAngles(i,:)))*100,horzcat(saccadeData.onsetSec',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.durationSec',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.amplitudes',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.velocities',threeSaccadeMax(1:3-saccadeData.Total)),saccadeData.peakVel,horzcat(saccadeData.accelerations',threeSaccadeMax(1:3-saccadeData.Total))];
        else
            saccadeValues(i,:) = nan(1,19);
        end
        clear saccadeData
    end
    
    if group==1
        groupName(1:40,:) = {'Control'};
    elseif group==2
        groupName(1:40,:) = {'Clinic'};
    else
        groupName(1:40,:) = {'VR'};
    end
    
    trials = num2cell([1:40]');
    stimulusAngles = num2cell([+2;+2;+1;+1;+2;+3;+1;+2;+4;+1;+2;+3;+4;+2;+2;+4;+1;+2;+3;+4;+3;+1;+4;+4;+3;+3;+3;+1;+4;+3;+2;+1;+2;+4;+4;+4;+1;+3;+3;+1]);%this IS the correct order, but the previous angles are correct
    saccadeValues = horzcat(groupName,trials,stimulusAngles,num2cell(saccadeValues));
    
    saccadeValues = sortrows(saccadeValues,3);
    xlswrite(MainFilename,saccadeValues,strcat('Saccades-',sheet),'A2');
    meanSaccadeValues = [];

    for i = 1:4
        meanSaccadeValues = horzcat(meanSaccadeValues,(nanmean(cell2mat(saccadeValues(1:10,3:end))))); %#ok<AGROW>
        saccadeValues(1:10,:) = [];
    end
    
    clearvars -except subject group sheet MainFilename meanSaccadeValues fitVar saccadeValues saccadeTrials
    
    %[~,~,smoothPursuitValues] = xlsread(MainFilename,strcat('Smooth Pursuit-',sheet)); %#ok<*UNRCH>
    [~,~,saccadeValues] = xlsread(MainFilename,strcat('Saccades-',sheet),'A2:V41');
    
    clearvars -except subject saccadeValues smoothPursuitValues group sheet meanSaccadeValues fitVar saccadeTrials
    save(char(strcat('OMT-',subject,'-',sheet,'.mat')));
    
    display(strcat('OMT Analysis for',{' '},subject, {' '}, 'complete'));
    clear
    clc
end

folder_name = pwd;

%subject = input('What is participant ID\n','s');
%decision = input('Which evaluation is being analyzed?\n(1) Pre\n(2) Mid\n(3) Post\n');

subject = strsplit(folder_name,'\');
subject = char(subject(1,end));

testFile = strcat('OMT-',subject,'-Mid.mat');
testFile = exist(testFile);

if testFile>0
    filename = strcat('OMT-',subject,'-Mid.mat');
    filename1 = strcat(subject,'EOGCal-Mid.txt');
    filename2 = strcat(subject,'HeadCal-Mid.txt');
    filename3 = strcat(subject,'EOGEval-Mid.txt');
    sheet = 'Pre';
    
    eyeData = importdata(filename1);
    eyeMark = eyeData(:,2);
    start = find(eyeMark>1000);
    channel2 = eyeData(:,4);
    rawEOG = channel2(start:end,:);
    
    headData = importdata(filename2);
    headYaw = headData.data(:,2);
    headMark = headData.data(:,4);
    
    testFile = exist(filename);
    
    if testFile>0
        load(filename);
    end
    
    testFit = exist('fitVar','var');
    
    if testFit==0
        step1 = 0;
        while step1~=1;
            %subEOG = rawEOG(1:13.5:end,:);%DK2 samples at ~75Hz
            subEOG = rawEOG(1:11.11:end,:);%DK3 samples at ~90Hz
            scrsz = get(0,'ScreenSize');
            figure('Position',scrsz);
            plot(subEOG);
            [X1,Y1] = ginput(1);
            [X2,Y2] = ginput(1);
            T1 = round(X1);
            T2 = round(X2);
            cal(:,1) = subEOG(T1:T2,:);
            cal(:,2) = headYaw(T1:T2,:);
            x = cal(:,1);
            y = cal(:,2);
            
            close all
            
            scatter(x,y,'bo');
            
            step1 = input('Is Fit Line acceptable?\n(1)Yes\n(2)No\n');
            
            if step1==1
                fitVar = polyfit(x,y,1);
                close all
                headYaw = headYaw-headYaw(1,1);
                EOGDeg = subEOG*(fitVar(1,1))+fitVar(1,2);
                EOGDeg = EOGDeg-EOGDeg(1,1);
                plot(EOGDeg,'b');
                hold
                plot(headYaw,'r');
                legend('Eye Position','Head Position','Location','NorthEast');
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
            close all
        end
    end
    
    clearvars -except subject fitVar folder_name filename3 group sheet
    
    MainFilename = sprintf(strcat(subject,'-OMT.xlsx'));
    saccadeValHeading = {'Trial #','Group','Angle','Total Amplitude','Saccade N','Mean Abs Pos Error','Latency (sec) - 1','Latency (sec) - 2','Latency (sec) - 3','Duration (sec) - 1','Duration (sec) - 2','Duration (sec) - 3','Amplitude (°) - 1','Amplitude (°) - 2','Amplitude (°) - 3','Velocity (°s-1) - 1','Velocity (°s-1) - 2','Velocity (°s-1) - 3','Peak Velocity (°s-1)','Acceleration (°s-2) - 1','Acceleration (°s-2) - 2','Acceleration (°s-2) - 3'};
    xlswrite(MainFilename,saccadeValHeading,strcat('Saccades-',sheet),'A1');
    deletesheet(folder_name,MainFilename)
    
    eyeData = importdata(filename3);
    eyeMark = eyeData(:,2);
    start = find(eyeMark>50);
    trialStart = start(1,1);
    eyeData = eyeData(trialStart:end,:);
    %channel1 = eyeData(:,3);
    channel2 = eyeData(:,4);
    EOGDeg = channel2*(fitVar(1,1))+fitVar(1,2);
    [b,a] = butter(2,30/500,'low');
    EOGDeg = filtfilt(b,a,EOGDeg);
    EOGDeg = detrend(EOGDeg);
    EOGDeg = EOGDeg-EOGDeg(1,1);
    
    %Smooth Pursuit Analysis
    filepath = 'C:\Users\tug41619\Documents\MATLAB\MATLAB Codes\OMT Toolbox';%if you get an error message here, change file path
    load([filepath '\' 'stimProfile.mat']);
    stimDeg = stimProfile*1.85;%%THIS IS NOT CORRECT, FIND THE CORRECT CONVERSION somewhere bewteen 1.75 & 2.75
    unitySampRate = length(stimProfile)/285;
    conversionFactor = 1000/unitySampRate;
    
    unitySameRateStr = num2str(unitySampRate);
    %display(strcat('Unity is sampling at',{' '},unitySameRateStr, {' '}, 'Hz'));
    subOMTEval = EOGDeg(1:conversionFactor:end);%%Subsampling from 1000Hz to 60Hz should use a conversion factor of 16.667
    %
    % spSessionDuration = unitySampRate*200;%sp session duration in frames
    % smoothPursuitBlock = subOMTEval(1:spSessionDuration);
    % spTrialDuration = unitySampRate*60;%sp trial duration in frames
    % spPause = unitySampRate*5;%duration of pause in frames
    %
    % for i = 1:3
    %     smoothPursuitTrials(:,i) = smoothPursuitBlock(spPause:spPause+spTrialDuration);
    %     smoothPursuitBlock(1:unitySampRate*65) = [];
    %     smoothPursuitTrials(:,i) = smoothPursuitTrials(:,i)-smoothPursuitTrials(1,i);
    %     stimTrial = stimDeg(spPause:spPause+spTrialDuration);
    %     stimDeg(1:unitySampRate*65) = [];
    %     %stimTrial = stimTrial-stimTrial(1,1);
    %
    %     scrsz = get(0,'ScreenSize');
    %     figure('Position',scrsz);
    %     MaxX = length(smoothPursuitTrials);%duration of sp trial
    %     Xaxes = ((1:MaxX)/unitySampRate)';
    %     plot(Xaxes,smoothPursuitTrials(:,i),'b');
    %     hold on
    %     plot(Xaxes,stimTrial,'r');
    %     legend('Eye','Stimulus','location','northeast')
    %     ylabel ('Displacement (°)');
    %     xlabel('Time (s)');
    %     set(gca,'fontsize',25);
    %     decision = input('Does the data need to be flipped?\n(1) Yes\n(0) No\n');
    %
    %     if decision==1
    %         smoothPursuitTrials(:,i) = -smoothPursuitTrials(:,i);
    %         smoothPursuitTrials(:,i) = smoothPursuitTrials(:,i)-smoothPursuitTrials(1,i);
    %         figure('Position',scrsz);
    %         plot(Xaxes,smoothPursuitTrials(:,i),'b');
    %         hold on
    %         plot(Xaxes,stimTrial,'r');
    %         legend('Eye','Stimulus','location','northeast')
    %         ylabel ('Displacement (°)');
    %         xlabel('Time (s)');
    %         set(gca,'fontsize',25);
    %         pause
    %     else
    %     end
    %
    %     close all
    %     smoothPursuitVelocity(:,i) = diff(smoothPursuitTrials(:,i))*unitySampRate;
    %
    %     %SPGain = eye velocity/target velocity
    %     %calculate peaks in SP and vel
    %     %calculate mean gain and mean lag
    % end
    
    smoothPursuitValHeading = {'Trials','Stimulus Velocity','Eye Velocity','Gain','Lag'};
    % smoothPursuitValues = {stimVel' eyeVel' Gain' Lag'};
    xlswrite(MainFilename,smoothPursuitValHeading,strcat('Smooth Pursuit-',sheet),'A1');
    % xlswrite(MainFilename,smoothPursuitValues,'Smooth Pursuit','B2');
    %
    %Saccade Analysis
    saccadeBlock = EOGDeg(200001:end,:);
    stimulusAngles = [-2;+2;+1;-1;+2;-3;+1;-2;+4;-1;-2;+3;-4;+2;+2;-4;+1;+2;-3;+4;-3;-1;+4;-4;+3;-3;+3;+1;-4;+3;-2;+1;-2;+4;-4;+4;-1;-3;+3;-1];%this IS the correct order, but the previous angles are correct
    
    for i = 1:40
        saccadeTrials(:,i) = saccadeBlock(1:2000); %#ok<*SAGROW>
        saccadeBlock(1:2000) = [];
        
        saccadeTrials(:,i) = saccadeTrials(:,i)-saccadeTrials(1,i);
        
        if stimulusAngles(i,:)<0
            saccadeTrials(:,i) = saccadeTrials(:,i);
        else
            saccadeTrials(:,i) = -saccadeTrials(:,i);
        end
        
        saccadesVel(:,i) = diff(saccadeTrials(:,i))*1000;
        saccadesAcc(:,i) = diff(saccadesVel(:,i))*1000;
        
    end
    
    stimulusAngles = [12;12;6;6;12;20;6;12;28;6;12;20;28;12;12;28;6;12;20;28;20;6;28;28;20;20;20;6;28;20;12;6;12;28;28;28;6;20;20;6];%this IS the correct order, but the angles are not correct
    
    for i = 1:40
        
        displacement = saccadeTrials(:,i);
        velocity = saccadesVel(:,i);
        acceleration = saccadesAcc(:,i);
        
        threeSaccadeMax = nan(1,3);
        saccadeData = saccades(displacement,velocity,acceleration);
        if saccadeData.onsetSec(1,1)<.05||saccadeData.onsetSec(1,1)>.6||sum(saccadeData.amplitudes)>stimulusAngles(i,:)+5||sum(saccadeData.amplitudes)<stimulusAngles(i,:)-5||saccadeData.Total>3
            saccadeData.Total = 0;
        end
        if saccadeData.Total>0
            saccadeValues(i,:) = [sum(saccadeData.amplitudes),saccadeData.Total,abs(((sum(saccadeData.amplitudes)-stimulusAngles(i,:))/stimulusAngles(i,:)))*100,horzcat(saccadeData.onsetSec',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.durationSec',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.amplitudes',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.velocities',threeSaccadeMax(1:3-saccadeData.Total)),saccadeData.peakVel,horzcat(saccadeData.accelerations',threeSaccadeMax(1:3-saccadeData.Total))];
        else
            saccadeValues(i,:) = nan(1,19);
        end
        clear saccadeData
    end
    
    if group==1
        groupName(1:40,:) = {'Control'};
    elseif group==2
        groupName(1:40,:) = {'Clinic'};
    else
        groupName(1:40,:) = {'VR'};
    end
    
    trials = num2cell([1:40]');
    stimulusAngles = num2cell([+2;+2;+1;+1;+2;+3;+1;+2;+4;+1;+2;+3;+4;+2;+2;+4;+1;+2;+3;+4;+3;+1;+4;+4;+3;+3;+3;+1;+4;+3;+2;+1;+2;+4;+4;+4;+1;+3;+3;+1]);%this IS the correct order, but the previous angles are correct
    saccadeValues = horzcat(groupName,trials,stimulusAngles,num2cell(saccadeValues));
    
    saccadeValues = sortrows(saccadeValues,3);
    xlswrite(MainFilename,saccadeValues,strcat('Saccades-',sheet),'A2');
    meanSaccadeValues = [];
    
    for i = 1:4
        meanSaccadeValues = horzcat(meanSaccadeValues,(nanmean(cell2mat(saccadeValues(1:10,3:end))))); %#ok<AGROW>
        saccadeValues(1:10,:) = [];
    end
    
    clearvars -except subject group sheet MainFilename meanSaccadeValues fitVar saccadeValues saccadeTrials
    
    %[~,~,smoothPursuitValues] = xlsread(MainFilename,strcat('Smooth Pursuit-',sheet)); %#ok<*UNRCH>
    [~,~,saccadeValues] = xlsread(MainFilename,strcat('Saccades-',sheet),'A2:V41');
    
    clearvars -except subject saccadeValues smoothPursuitValues group sheet meanSaccadeValues fitVar saccadeTrials
    save(char(strcat('OMT-',subject,'-',sheet,'.mat')));
    
    display(strcat('OMT Analysis for',{' '},subject, {' '}, 'complete'));
    clear
    clc
end

folder_name = pwd;

%subject = input('What is participant ID\n','s');
%decision = input('Which evaluation is being analyzed?\n(1) Pre\n(2) Mid\n(3) Post\n');

subject = strsplit(folder_name,'\');
subject = char(subject(1,end));

testFile = strcat('OMT-',subject,'-Post.mat');
testFile = exist(testFile);

if testFile>0
    filename = strcat('OMT-',subject,'-Post.mat');
    filename1 = strcat(subject,'EOGCal-Post.txt');
    filename2 = strcat(subject,'HeadCal-Post.txt');
    filename3 = strcat(subject,'EOGEval-Post.txt');
    sheet = 'Pre';
    
    eyeData = importdata(filename1);
    eyeMark = eyeData(:,2);
    start = find(eyeMark>1000);
    channel2 = eyeData(:,4);
    rawEOG = channel2(start:end,:);
    
    headData = importdata(filename2);
    headYaw = headData.data(:,2);
    headMark = headData.data(:,4);
    
    testFile = exist(filename);
    
    if testFile>0
        load(filename);
    end
    
    testFit = exist('fitVar','var');
    
    if testFit==0
        step1 = 0;
        while step1~=1;
            %subEOG = rawEOG(1:13.5:end,:);%DK2 samples at ~75Hz
            subEOG = rawEOG(1:11.11:end,:);%DK3 samples at ~90Hz
            scrsz = get(0,'ScreenSize');
            figure('Position',scrsz);
            plot(subEOG);
            [X1,Y1] = ginput(1);
            [X2,Y2] = ginput(1);
            T1 = round(X1);
            T2 = round(X2);
            cal(:,1) = subEOG(T1:T2,:);
            cal(:,2) = headYaw(T1:T2,:);
            x = cal(:,1);
            y = cal(:,2);
            
            close all
            
            scatter(x,y,'bo');
            
            step1 = input('Is Fit Line acceptable?\n(1)Yes\n(2)No\n');
            
            if step1==1
                fitVar = polyfit(x,y,1);
                close all
                headYaw = headYaw-headYaw(1,1);
                EOGDeg = subEOG*(fitVar(1,1))+fitVar(1,2);
                EOGDeg = EOGDeg-EOGDeg(1,1);
                plot(EOGDeg,'b');
                hold
                plot(headYaw,'r');
                legend('Eye Position','Head Position','Location','NorthEast');
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
            close all
        end
    end
    
    clearvars -except subject fitVar folder_name filename3 group sheet
    
    MainFilename = sprintf(strcat(subject,'-OMT.xlsx'));
    saccadeValHeading = {'Trial #','Group','Angle','Total Amplitude','Saccade N','Mean Abs Pos Error','Latency (sec) - 1','Latency (sec) - 2','Latency (sec) - 3','Duration (sec) - 1','Duration (sec) - 2','Duration (sec) - 3','Amplitude (°) - 1','Amplitude (°) - 2','Amplitude (°) - 3','Velocity (°s-1) - 1','Velocity (°s-1) - 2','Velocity (°s-1) - 3','Peak Velocity (°s-1)','Acceleration (°s-2) - 1','Acceleration (°s-2) - 2','Acceleration (°s-2) - 3'};
    xlswrite(MainFilename,saccadeValHeading,strcat('Saccades-',sheet),'A1');
    deletesheet(folder_name,MainFilename)
    
    eyeData = importdata(filename3);
    eyeMark = eyeData(:,2);
    start = find(eyeMark>50);
    trialStart = start(1,1);
    eyeData = eyeData(trialStart:end,:);
    %channel1 = eyeData(:,3);
    channel2 = eyeData(:,4);
    EOGDeg = channel2*(fitVar(1,1))+fitVar(1,2);
    [b,a] = butter(2,30/500,'low');
    EOGDeg = filtfilt(b,a,EOGDeg);
    EOGDeg = detrend(EOGDeg);
    EOGDeg = EOGDeg-EOGDeg(1,1);
    
    %Smooth Pursuit Analysis
    filepath = 'C:\Users\tug41619\Documents\MATLAB\MATLAB Codes\OMT Toolbox';%if you get an error message here, change file path
    load([filepath '\' 'stimProfile.mat']);
    stimDeg = stimProfile*1.85;%%THIS IS NOT CORRECT, FIND THE CORRECT CONVERSION somewhere bewteen 1.75 & 2.75
    unitySampRate = length(stimProfile)/285;
    conversionFactor = 1000/unitySampRate;
    
    unitySameRateStr = num2str(unitySampRate);
    %display(strcat('Unity is sampling at',{' '},unitySameRateStr, {' '}, 'Hz'));
    subOMTEval = EOGDeg(1:conversionFactor:end);%%Subsampling from 1000Hz to 60Hz should use a conversion factor of 16.667
    %
    % spSessionDuration = unitySampRate*200;%sp session duration in frames
    % smoothPursuitBlock = subOMTEval(1:spSessionDuration);
    % spTrialDuration = unitySampRate*60;%sp trial duration in frames
    % spPause = unitySampRate*5;%duration of pause in frames
    %
    % for i = 1:3
    %     smoothPursuitTrials(:,i) = smoothPursuitBlock(spPause:spPause+spTrialDuration);
    %     smoothPursuitBlock(1:unitySampRate*65) = [];
    %     smoothPursuitTrials(:,i) = smoothPursuitTrials(:,i)-smoothPursuitTrials(1,i);
    %     stimTrial = stimDeg(spPause:spPause+spTrialDuration);
    %     stimDeg(1:unitySampRate*65) = [];
    %     %stimTrial = stimTrial-stimTrial(1,1);
    %
    %     scrsz = get(0,'ScreenSize');
    %     figure('Position',scrsz);
    %     MaxX = length(smoothPursuitTrials);%duration of sp trial
    %     Xaxes = ((1:MaxX)/unitySampRate)';
    %     plot(Xaxes,smoothPursuitTrials(:,i),'b');
    %     hold on
    %     plot(Xaxes,stimTrial,'r');
    %     legend('Eye','Stimulus','location','northeast')
    %     ylabel ('Displacement (°)');
    %     xlabel('Time (s)');
    %     set(gca,'fontsize',25);
    %     decision = input('Does the data need to be flipped?\n(1) Yes\n(0) No\n');
    %
    %     if decision==1
    %         smoothPursuitTrials(:,i) = -smoothPursuitTrials(:,i);
    %         smoothPursuitTrials(:,i) = smoothPursuitTrials(:,i)-smoothPursuitTrials(1,i);
    %         figure('Position',scrsz);
    %         plot(Xaxes,smoothPursuitTrials(:,i),'b');
    %         hold on
    %         plot(Xaxes,stimTrial,'r');
    %         legend('Eye','Stimulus','location','northeast')
    %         ylabel ('Displacement (°)');
    %         xlabel('Time (s)');
    %         set(gca,'fontsize',25);
    %         pause
    %     else
    %     end
    %
    %     close all
    %     smoothPursuitVelocity(:,i) = diff(smoothPursuitTrials(:,i))*unitySampRate;
    %
    %     %SPGain = eye velocity/target velocity
    %     %calculate peaks in SP and vel
    %     %calculate mean gain and mean lag
    % end
    
    smoothPursuitValHeading = {'Trials','Stimulus Velocity','Eye Velocity','Gain','Lag'};
    % smoothPursuitValues = {stimVel' eyeVel' Gain' Lag'};
    xlswrite(MainFilename,smoothPursuitValHeading,strcat('Smooth Pursuit-',sheet),'A1');
    % xlswrite(MainFilename,smoothPursuitValues,'Smooth Pursuit','B2');
    %
    %Saccade Analysis
    saccadeBlock = EOGDeg(200001:end,:);
    stimulusAngles = [-2;+2;+1;-1;+2;-3;+1;-2;+4;-1;-2;+3;-4;+2;+2;-4;+1;+2;-3;+4;-3;-1;+4;-4;+3;-3;+3;+1;-4;+3;-2;+1;-2;+4;-4;+4;-1;-3;+3;-1];%this IS the correct order, but the previous angles are correct
    
    for i = 1:40
        saccadeTrials(:,i) = saccadeBlock(1:2000); %#ok<*SAGROW>
        saccadeBlock(1:2000) = [];
        
        saccadeTrials(:,i) = saccadeTrials(:,i)-saccadeTrials(1,i);
        
        if stimulusAngles(i,:)<0
            saccadeTrials(:,i) = saccadeTrials(:,i);
        else
            saccadeTrials(:,i) = -saccadeTrials(:,i);
        end
        
        saccadesVel(:,i) = diff(saccadeTrials(:,i))*1000;
        saccadesAcc(:,i) = diff(saccadesVel(:,i))*1000;
        
    end
    
    stimulusAngles = [12;12;6;6;12;20;6;12;28;6;12;20;28;12;12;28;6;12;20;28;20;6;28;28;20;20;20;6;28;20;12;6;12;28;28;28;6;20;20;6];%this IS the correct order, but the angles are not correct
    
    for i = 1:40
        
        displacement = saccadeTrials(:,i);
        velocity = saccadesVel(:,i);
        acceleration = saccadesAcc(:,i);
        
        threeSaccadeMax = nan(1,3);
        saccadeData = saccades(displacement,velocity,acceleration);
        if saccadeData.onsetSec(1,1)<.05||saccadeData.onsetSec(1,1)>.6||sum(saccadeData.amplitudes)>stimulusAngles(i,:)+5||sum(saccadeData.amplitudes)<stimulusAngles(i,:)-5||saccadeData.Total>3
            saccadeData.Total = 0;
        end
        if saccadeData.Total>0
            saccadeValues(i,:) = [sum(saccadeData.amplitudes),saccadeData.Total,abs(((sum(saccadeData.amplitudes)-stimulusAngles(i,:))/stimulusAngles(i,:)))*100,horzcat(saccadeData.onsetSec',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.durationSec',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.amplitudes',threeSaccadeMax(1:3-saccadeData.Total)),horzcat(saccadeData.velocities',threeSaccadeMax(1:3-saccadeData.Total)),saccadeData.peakVel,horzcat(saccadeData.accelerations',threeSaccadeMax(1:3-saccadeData.Total))];
        else
            saccadeValues(i,:) = nan(1,19);
        end
        clear saccadeData
    end

    if group==1
        groupName(1:40,:) = {'Control'};
    elseif group==2
        groupName(1:40,:) = {'Clinic'};
    else
        groupName(1:40,:) = {'VR'};
    end
    
    trials = num2cell([1:40]');
    stimulusAngles = num2cell([+2;+2;+1;+1;+2;+3;+1;+2;+4;+1;+2;+3;+4;+2;+2;+4;+1;+2;+3;+4;+3;+1;+4;+4;+3;+3;+3;+1;+4;+3;+2;+1;+2;+4;+4;+4;+1;+3;+3;+1]);%this IS the correct order, but the previous angles are correct
    saccadeValues = horzcat(groupName,trials,stimulusAngles,num2cell(saccadeValues));
    
    saccadeValues = sortrows(saccadeValues,3);
    xlswrite(MainFilename,saccadeValues,strcat('Saccades-',sheet),'A2');
    meanSaccadeValues = [];
    
    for i = 1:4
        meanSaccadeValues = horzcat(meanSaccadeValues,(nanmean(cell2mat(saccadeValues(1:10,3:end))))); %#ok<AGROW>
        saccadeValues(1:10,:) = [];
    end
    
    clearvars -except subject group sheet MainFilename meanSaccadeValues fitVar saccadeValues saccadeTrials
    
    %[~,~,smoothPursuitValues] = xlsread(MainFilename,strcat('Smooth Pursuit-',sheet)); %#ok<*UNRCH>
    [~,~,saccadeValues] = xlsread(MainFilename,strcat('Saccades-',sheet),'A2:V41');
    
    clearvars -except subject saccadeValues smoothPursuitValues group sheet meanSaccadeValues fitVar saccadeTrials
    save(char(strcat('OMT-',subject,'-',sheet,'.mat')));
    
    display(strcat('OMT Analysis for',{' '},subject, {' '}, 'complete'));
    clear
    clc
end

clear
clc