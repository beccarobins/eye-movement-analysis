function saccadeLatency = saccadeonsetlatency(DisplacementInput,VelocityInput,TrialNum)

StartCriteria = 0;
Threshold = 30;
A = 1;

for N = A:1998;
    if DisplacementInput(N+1)>DisplacementInput(N) && VelocityInput(N+1)>VelocityInput(N)&& VelocityInput(N)>Threshold;
        StartCriteria = StartCriteria+1;
        StartTimes(StartCriteria)= N; %#ok<*AGROW,*SAGROW>
    end
end

exist StartTimes

if ans==1
    
    StartTimes = StartTimes';
    StartTimes2 = diff(StartTimes);
    StartTimes3 = diff(StartTimes2);
    
    t = diff([false;StartTimes3==0;false]);
    p = find(t==1);
    OnsetTimes = StartTimes(p); %#ok<*FNDSB>
    
    Question = 4;
    
    for j = 1:length(OnsetTimes);
        if Question==4||Question==2
            Onset_sec = (OnsetTimes(j,1))/1000;
            MaxY = 10*ceil(max(DisplacementInput)/10.);
            MinY = 10*floor(min(DisplacementInput)/10.);
            MaxX = length(DisplacementInput);
            axis([min(0) max(MaxX) min(MinY) max(MaxY)]);
            Xaxes = (1:MaxX)/1000;
            y1 = [MinY,MaxY];
            subplot(211)
            for x = 1:length(OnsetTimes);
                AllOnsets = (OnsetTimes(x,1))/1000;
                x2 = [AllOnsets,AllOnsets];
                plot(x2,y1,'k');
                hold on
            end
            x1 = [Onset_sec,Onset_sec];
            plot(x1,y1,'r');
            hold on
            plot(Xaxes',DisplacementInput,'k');
            TrialNumber = num2str(TrialNum);
            Title = strcat('Trial Number',{' '},TrialNumber);
            title(strcat('Determine the saccadic onset latency -',{' '},Title));
            xlabel ('Time(s)');
            ylabel ('Displacement(°)');
            MaxX = length(VelocityInput);
            MaxY = 100*ceil(max(VelocityInput)/100.);
            MinY = 100*floor(min(VelocityInput)/100.);
            Xaxes = (1:MaxX)/1000;
            y1 = [MinY,MaxY];
            subplot(212)
            for x = 1:length(OnsetTimes);
                AllOnsets = (OnsetTimes(x,1))/1000;
                x2 = [AllOnsets,AllOnsets];
                plot(x2,y1,'k');
                hold on
            end
            x1 = [Onset_sec,Onset_sec];
            plot(x1,y1,'r');
            hold on
            plot(Xaxes,VelocityInput,'b');
            ylabel ('Velocity(°s^-1)');
            
            Question = input('Is this the correct onset?\n(1)Yes\n(2)No\n(3)Previous time is correct\n(0)Exclude this trial\n');
            if Question==2;
                close all
            elseif Question==1
                saccadeLatency = OnsetTimes(j,1);
                close all
            elseif Question==3
                saccadeLatency = OnsetTimes(j-1,1);
                close all
            elseif Question==0
                saccadeLatency = nan;
                close all
            else
                Question=4;
                clc
                close all
                fprintf('Uh oh, something went wrong...\n\n');
                Statement = strcat('You will need to start Trial',{' '},num2str(TrialNum));
                disp(char(Statement));
                pause
            end
        end
    end
else
    saccadeLatency = nan;
end
clc
end
