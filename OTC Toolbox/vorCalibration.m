function fitVariable = vorCalibration(subEOG,headYaw)

step1 = 0;
while step1~=1;
    scrsz = get(0,'ScreenSize');
    figure('Position',scrsz);
    plot(subEOG);
    [X1,~] = ginput(1);
    [X2,~] = ginput(1);
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
        fitVariable = polyfit(x,y,1);
        close all
        headYaw = headYaw-headYaw(1,1);
        EOGDeg = subEOG*(fitVariable(1,1))+fitVariable(1,2);
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