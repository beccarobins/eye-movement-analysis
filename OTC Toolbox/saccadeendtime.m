function saccadeEnd = saccadeendtime(DisplacementInput,VelocityInput,TrialNum)

B = length(VelocityInput)-1;

MeetEndCriteria = 0;
[MaxVel,MaxVelTime] = max(VelocityInput(1:B));
Vel_20 = 0.10*MaxVel;
Below_20 = 0;

for N = MaxVelTime:B
    if VelocityInput(N)<=Vel_20
        Below_20 = Below_20+1;
        Below_20Times(Below_20)= N; %#ok<*AGROW>
    end
end

A = Below_20Times(1,1);

for N = A:B
    if VelocityInput(N-1)>0&&VelocityInput(N)<=0;
        MeetEndCriteria = MeetEndCriteria+1;
        MeetEndCriteriaTimes(MeetEndCriteria) = N; %#ok<*SAGROW>
    end
end

MeetEndCriteriaTimes = MeetEndCriteriaTimes';

if MeetEndCriteriaTimes>1; %#ok<*BDSCI>
    Question = 4;
    for j = 1:length(MeetEndCriteriaTimes);
        if Question==4||Question==2
            
            DisplacementInputEnd_sec = (MeetEndCriteriaTimes(j,1))/1000;
            MaxY = 10*ceil(max(DisplacementInput)/10.);
            MinY = 10*floor(min(DisplacementInput)/10.);
            MaxX = length(DisplacementInput);
            axis([min(0) max(MaxX) min(MinY) max(MaxY)]);
            Xaxes = ((1:MaxX))/1000';
            y1 = [MinY,MaxY];
            subplot(211)
            for x = 1:length(MeetEndCriteriaTimes);
                AllEnds = (MeetEndCriteriaTimes(x,1))/1000;
                x2 = [AllEnds,AllEnds];
                plot(x2,y1,'k');
                hold on
            end
            x1 = [DisplacementInputEnd_sec,DisplacementInputEnd_sec];
            plot(x1,y1,'r');
            hold on
            plot(Xaxes,DisplacementInput,'k');
            TrialNumber = num2str(TrialNum);
            Title = strcat('Trial Number',{' '},TrialNumber);
            title(strcat('Determine the end time of the saccade -',{' '},Title));
            xlabel ('Time(s)');
            ylabel ('Displacement(°)');
            MaxY = 100*ceil(max(VelocityInput)/100.);
            MinY = 100*floor(min(VelocityInput)/100.);
            MaxX = length(VelocityInput);
            Xaxes = ((1:MaxX))/1000';
            y1 = [MinY,MaxY];
            subplot(212)
            for x = 1:length(MeetEndCriteriaTimes);
                AllEnds = (MeetEndCriteriaTimes(x,1))/1000;
                x2 = [AllEnds,AllEnds];
                plot(x2,y1,'k');
                hold on
            end
            x1 = [DisplacementInputEnd_sec,DisplacementInputEnd_sec];
            plot(x1,y1,'r');
            hold on
            plot(Xaxes,VelocityInput,'b');
            ylabel ('Velocity(°s^-1)');
            Question = input('Is this the correct end time?\n(1)Yes\n(2)No\n(3)Previous time is correct\n(0)Exclude this trial\n');
            if Question==2;
                close all
            elseif Question==1
                saccadeEnd = MeetEndCriteriaTimes(j,1);
                close all
                elseif Question==3
                saccadeEnd = MeetEndCriteriaTimes(j-1,1);
                close all
            elseif Question==0
                saccadeEnd = nan;
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
end