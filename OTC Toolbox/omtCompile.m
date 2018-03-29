%Compile OMT Data
clr
folder_name = uigetdir;
cd(folder_name)

namePre = [folder_name '\*\**' 'Pre.mat'];
filesPre = rdir(namePre);
nFilesPre = length(filesPre);

nameMid = [folder_name '\*\**' 'Mid.mat'];
filesMid = rdir(nameMid);
nFilesMid = length(filesMid);

namePost = [folder_name '\*\**' 'Post.mat'];
filesPost = rdir(namePost);
nFilesPost = length(filesPost);

warning('off','all');
MainFilename = sprintf('OMT-Data.xlsx');
Sheet1 = 'Saccades-Raw Data (Pre)';
Sheet2 = 'Saccades-Raw Data (Mid)';
Sheet3 = 'Saccades-Raw Data (Post)';
Sheet4 = 'Saccades-ANOVA (Pre)';
Sheet5 = 'Saccades-ANOVA (Mid)';
Sheet6 = 'Saccades-ANOVA (Post)';
Sheet7 = 'Main Sequence (Pre)';
Sheet8 = 'Main Sequence (Mid)';
Sheet9 = 'Main Sequence (Post)';
saccadeHeading = {'Subject','Trial #','Group','Angle','Total Amplitude','Saccade N','Mean Abs Pos Error','Latency (sec) - 1','Latency (sec) - 2','Latency (sec) - 3','Duration (sec) - 1','Duration (sec) - 2','Duration (sec) - 3','Amplitude (°) - 1','Amplitude (°) - 2','Amplitude (°) - 3','Velocity (°s-1) - 1','Velocity (°s-1) - 2','Velocity (°s-1) - 3','Peak Velocity (°s-1)','Acceleration (°s-2) - 1','Acceleration (°s-2) - 2','Acceleration (°s-2) - 3'};
xlswrite(MainFilename,saccadeHeading,Sheet1,'A1');
xlswrite(MainFilename,saccadeHeading,Sheet2,'A1');
xlswrite(MainFilename,saccadeHeading,Sheet3,'A1');

meanSaccadeHeading = {'Group','Subject','Angle (+1)','Total Amplitude (+1)','Saccade N (+1)','Mean Abs Pos Error (+1)','Latency (sec) - 1 (+1)','Latency (sec) - 2 (+1)',...
    'Latency (sec) - 3 (+1)','Duration (sec) - 1 (+1)','Duration (sec) - 2 (+1)','Duration (sec) - 3 (+1)','Amplitude (°) - 1 (+1)','Amplitude (°) - 2 (+1)'...
    ,'Amplitude (°) - 3 (+1)','Velocity (°s-1) - 1 (+1)','Velocity (°s-1) - 2 (+1)','Velocity (°s-1) - 3 (+1)','Peak Velocity (°s-1) (+1)'...
    'Acceleration (°s-2) - 1 (+1)','Acceleration (°s-2) - 2 (+1)','Acceleration (°s-2) - 3 (+1)','Angle (+2)','Total Amplitude (+2)','Saccade N (+2)','Mean Abs Pos Error (+2)','Latency (sec) - 1 (+2)','Latency (sec) - 2 (+2)',...
    'Latency (sec) - 3 (+2)','Duration (sec) - 1 (+2)','Duration (sec) - 2 (+2)','Duration (sec) - 3 (+2)','Amplitude (°) - 1 (+2)','Amplitude (°) - 2 (+2)'...
    ,'Amplitude (°) - 3 (+2)','Velocity (°s-1) - 1 (+2)','Velocity (°s-1) - 2 (+2)','Velocity (°s-1) - 3 (+2)','Peak Velocity (°s-1) (+2)'...
    'Acceleration (°s-2) - 1 (+2)','Acceleration (°s-2) - 2 (+2)','Acceleration (°s-2) - 3 (+2)','Angle (+3)','Total Amplitude (+3)','Saccade N (+3)','Mean Abs Pos Error (+3)','Latency (sec) - 1 (+3)','Latency (sec) - 2 (+3)',...
    'Latency (sec) - 3 (+3)','Duration (sec) - 1 (+3)','Duration (sec) - 2 (+3)','Duration (sec) - 3 (+3)','Amplitude (°) - 1 (+3)','Amplitude (°) - 2 (+3)'...
    ,'Amplitude (°) - 3 (+3)','Velocity (°s-1) - 1 (+3)','Velocity (°s-1) - 2 (+3)','Velocity (°s-1) - 3 (+3)','Peak Velocity (°s-1) (+3)'...
    'Acceleration (°s-2) - 1 (+3)','Acceleration (°s-2) - 2 (+3)','Acceleration (°s-2) - 3 (+3)','Angle (+4)','Total Amplitude (+4)','Saccade N (+4)','Mean Abs Pos Error (+4)','Latency (sec) - 1 (+4)','Latency (sec) - 2 (+4)',...
    'Latency (sec) - 3 (+4)','Duration (sec) - 1 (+4)','Duration (sec) - 2 (+4)','Duration (sec) - 3 (+4)','Amplitude (°) - 1 (+4)','Amplitude (°) - 2 (+4)'...
    ,'Amplitude (°) - 3 (+4)','Velocity (°s-1) - 1 (+4)','Velocity (°s-1) - 2 (+4)','Velocity (°s-1) - 3 (+4)','Peak Velocity (°s-1) (+4)'...
    'Acceleration (°s-2) - 1 (+4)','Acceleration (°s-2) - 2 (+4)','Acceleration (°s-2) - 3 (+4)'};
xlswrite(MainFilename,meanSaccadeHeading,Sheet4,'A1');
xlswrite(MainFilename,meanSaccadeHeading,Sheet5,'A1');
xlswrite(MainFilename,meanSaccadeHeading,Sheet6,'A1');
mainSequenceHeading = {'Duration (Control)' 'Amplitude (Control)' 'Velocity (Control)' 'Duration (Clinic)' 'Amplitude (Clinic)' 'Velocity (Clinic)' 'Duration (VR)' 'Amplitude (VR)' 'Velocity (VR)'};
xlswrite(MainFilename,mainSequenceHeading,Sheet7,'A1');
xlswrite(MainFilename,mainSequenceHeading,Sheet8,'A1');
xlswrite(MainFilename,mainSequenceHeading,Sheet9,'A1');
deletesheet(folder_name,MainFilename)

controlGroupSP = {};
clinicGroupSP = {};
vrGroupSP = {};

controlGroupSaccades = {};
clinicGroupSaccades = {};
vrGroupSaccades = {};

controlGroupSaccadesMean = {};
clinicGroupSaccadesMean = {};
vrGroupSaccadesMean = {};

for i = 1:nFilesPre
    filename = char({filesPre(i,1).name});
    load(filename)
    subjectIDSaccades(1:40,:) = cellstr(subject);
    
    if group==1
        controlGroupSaccades = vertcat(controlGroupSaccades,horzcat(subjectIDSaccades,saccadeValues)); %#ok<*AGROW>
        controlGroupSaccadesMean = vertcat(controlGroupSaccadesMean,horzcat({'control'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %controlGroupSP = vertcat(controlGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    elseif group==2
        clinicGroupSaccades = vertcat(clinicGroupSaccades,horzcat(subjectIDSaccades,saccadeValues));
        clinicGroupSaccadesMean = vertcat(clinicGroupSaccadesMean,horzcat({'clinic'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %clinicGroupSP = vertcat(clinicGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    else
        vrGroupSaccades = vertcat(vrGroupSaccades,horzcat(subjectIDSaccades,saccadeValues));
        vrGroupSaccadesMean = vertcat(vrGroupSaccadesMean,horzcat({'vr'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %vrGroupSP = vertcat(vrGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    end
end
%%
mainSequenceControl = vertcat(horzcat(controlGroupSaccades(:,11),controlGroupSaccades(:,14),controlGroupSaccades(:,17)),horzcat(controlGroupSaccades(:,12),controlGroupSaccades(:,15),controlGroupSaccades(:,18)),horzcat(controlGroupSaccades(:,13),controlGroupSaccades(:,16),controlGroupSaccades(:,19)));
mainSequenceClinic = vertcat(horzcat(clinicGroupSaccades(:,11),clinicGroupSaccades(:,14),clinicGroupSaccades(:,17)),horzcat(clinicGroupSaccades(:,12),clinicGroupSaccades(:,15),clinicGroupSaccades(:,18)),horzcat(clinicGroupSaccades(:,13),clinicGroupSaccades(:,16),clinicGroupSaccades(:,19)));
mainSequenceVR = vertcat(horzcat(vrGroupSaccades(:,11),vrGroupSaccades(:,14),vrGroupSaccades(:,17)),horzcat(vrGroupSaccades(:,12),vrGroupSaccades(:,15),vrGroupSaccades(:,18)),horzcat(vrGroupSaccades(:,13),vrGroupSaccades(:,16),vrGroupSaccades(:,19)));
xlswrite(MainFilename,mainSequenceControl,Sheet7,'A2');
xlswrite(MainFilename,mainSequenceClinic,Sheet7,'D2');
xlswrite(MainFilename,mainSequenceVR,Sheet7,'G2');
groupSaccades = vertcat(controlGroupSaccades,clinicGroupSaccades,vrGroupSaccades);
xlswrite(MainFilename,groupSaccades,Sheet1,'A2');
groupSaccadesMean = vertcat(controlGroupSaccadesMean,clinicGroupSaccadesMean,vrGroupSaccadesMean);
xlswrite(MainFilename,groupSaccadesMean,Sheet4,'A2');
controlGroupSaccades = {};
clinicGroupSaccades = {};
vrGroupSaccades = {};
controlGroupSaccadesMean = {};
clinicGroupSaccadesMean = {};
vrGroupSaccadesMean = {};
for i = 1:nFilesMid
    filename = char({filesMid(i,1).name});
    load(filename)
    subjectIDSaccades(1:40,:) = cellstr(subject);
    
    if group==1
        controlGroupSaccades = vertcat(controlGroupSaccades,horzcat(subjectIDSaccades,saccadeValues)); %#ok<*AGROW>
        controlGroupSaccadesMean = vertcat(controlGroupSaccadesMean,horzcat({'control'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %controlGroupSP = vertcat(controlGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    elseif group==2
        clinicGroupSaccades = vertcat(clinicGroupSaccades,horzcat(subjectIDSaccades,saccadeValues));
        clinicGroupSaccadesMean = vertcat(clinicGroupSaccadesMean,horzcat({'clinic'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %clinicGroupSP = vertcat(clinicGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    else
        vrGroupSaccades = vertcat(vrGroupSaccades,horzcat(subjectIDSaccades,saccadeValues));
        vrGroupSaccadesMean = vertcat(vrGroupSaccadesMean,horzcat({'vr'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %vrGroupSP = vertcat(vrGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    end
end
groupSaccades = vertcat(controlGroupSaccades,clinicGroupSaccades,vrGroupSaccades);
groupSaccadesMean = vertcat(controlGroupSaccadesMean,clinicGroupSaccadesMean,vrGroupSaccadesMean);
test = isempty(groupSaccades);
if test==0
    mainSequenceControl = vertcat(horzcat(controlGroupSaccades(:,11),controlGroupSaccades(:,14),controlGroupSaccades(:,17)),horzcat(controlGroupSaccades(:,12),controlGroupSaccades(:,15),controlGroupSaccades(:,18)),horzcat(controlGroupSaccades(:,13),controlGroupSaccades(:,16),controlGroupSaccades(:,19)));
    mainSequenceClinic = vertcat(horzcat(clinicGroupSaccades(:,11),clinicGroupSaccades(:,14),clinicGroupSaccades(:,17)),horzcat(clinicGroupSaccades(:,12),clinicGroupSaccades(:,15),clinicGroupSaccades(:,18)),horzcat(clinicGroupSaccades(:,13),clinicGroupSaccades(:,16),clinicGroupSaccades(:,19)));
    mainSequenceVR = vertcat(horzcat(vrGroupSaccades(:,11),vrGroupSaccades(:,14),vrGroupSaccades(:,17)),horzcat(vrGroupSaccades(:,12),vrGroupSaccades(:,15),vrGroupSaccades(:,18)),horzcat(vrGroupSaccades(:,13),vrGroupSaccades(:,16),vrGroupSaccades(:,19)));
    xlswrite(MainFilename,mainSequenceControl,Sheet8,'A2');
    xlswrite(MainFilename,mainSequenceClinic,Sheet8,'D2');
    xlswrite(MainFilename,mainSequenceVR,Sheet8,'G2');
    xlswrite(MainFilename,groupSaccades,Sheet2,'A2');
    xlswrite(MainFilename,groupSaccadesMean,Sheet5,'A2');
end
controlGroupSaccades = {};
clinicGroupSaccades = {};
vrGroupSaccades = {};
controlGroupSaccadesMean = {};
clinicGroupSaccadesMean = {};
vrGroupSaccadesMean = {};

for i = 1:nFilesPost
    filename = char({filesPost(i,1).name});
    load(filename)
    subjectIDSaccades(1:40,:) = cellstr(subject);
    
    if group==1
        controlGroupSaccades = vertcat(controlGroupSaccades,horzcat(subjectIDSaccades,saccadeValues)); %#ok<*AGROW>
        controlGroupSaccadesMean = vertcat(controlGroupSaccadesMean,horzcat({'control'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %controlGroupSP = vertcat(controlGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    elseif group==2
        clinicGroupSaccades = vertcat(clinicGroupSaccades,horzcat(subjectIDSaccades,saccadeValues));
        clinicGroupSaccadesMean = vertcat(clinicGroupSaccadesMean,horzcat({'clinic'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %clinicGroupSP = vertcat(clinicGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    else
        vrGroupSaccades = vertcat(vrGroupSaccades,horzcat(subjectIDSaccades,saccadeValues));
        vrGroupSaccadesMean = vertcat(vrGroupSaccadesMean,horzcat({'vr'},subject,num2cell(meanSaccadeValues))); %#ok<*AGROW>
        %vrGroupSP = vertcat(vrGroupSP,horzcat(subjectIDSP,smoothPursuitValues));
    end
end
groupSaccades = vertcat(controlGroupSaccades,clinicGroupSaccades,vrGroupSaccades);
groupSaccadesMean = vertcat(controlGroupSaccadesMean,clinicGroupSaccadesMean,vrGroupSaccadesMean);
test = isempty(groupSaccades);
if test==0
    mainSequenceControl = vertcat(horzcat(controlGroupSaccades(:,11),controlGroupSaccades(:,14),controlGroupSaccades(:,17)),horzcat(controlGroupSaccades(:,12),controlGroupSaccades(:,15),controlGroupSaccades(:,18)),horzcat(controlGroupSaccades(:,13),controlGroupSaccades(:,16),controlGroupSaccades(:,19)));
    mainSequenceClinic = vertcat(horzcat(clinicGroupSaccades(:,11),clinicGroupSaccades(:,14),clinicGroupSaccades(:,17)),horzcat(clinicGroupSaccades(:,12),clinicGroupSaccades(:,15),clinicGroupSaccades(:,18)),horzcat(clinicGroupSaccades(:,13),clinicGroupSaccades(:,16),clinicGroupSaccades(:,19)));
    mainSequenceVR = vertcat(horzcat(vrGroupSaccades(:,11),vrGroupSaccades(:,14),vrGroupSaccades(:,17)),horzcat(vrGroupSaccades(:,12),vrGroupSaccades(:,15),vrGroupSaccades(:,18)),horzcat(vrGroupSaccades(:,13),vrGroupSaccades(:,16),vrGroupSaccades(:,19)));
    xlswrite(MainFilename,mainSequenceControl,Sheet9,'A2');
    xlswrite(MainFilename,mainSequenceClinic,Sheet9,'D2');
    xlswrite(MainFilename,mainSequenceVR,Sheet9,'G2');
    xlswrite(MainFilename,groupSaccades,Sheet3,'A2');
    xlswrite(MainFilename,groupSaccadesMean,Sheet6,'A2');
end

msgbox('OMT Data Compiled');
clear
clc