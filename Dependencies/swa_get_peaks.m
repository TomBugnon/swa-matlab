function [MNP, MPP] = swa_get_peaks(slope_data, Info, flag_notch)
% find the positive and negative peaks within a channel

if nargin < 3
    flag_notch = false;
end

% find all the negative peaks
% when slope goes from negative to a positive
MNP  = find(diff(sign(slope_data)) == 2);
% Find all the positive peaks
MPP  = find(diff(sign(slope_data)) == -2);

% If there is too many MNP vs MPP, it might be because of the slope staying
% null in multiple consecutive time step. We resolve by perturbing
% infinitesimally.
acc = 0 % Avoid infinite loop
while length(find(abs(diff(sign(slope_data)) == 1))) > 1 % not 2 because slope_data(0) == 0
    
    abs(length(MNP) - length(MPP) > 1);
    slope_data(2:end) = slope_data(2:end) + 0.00001;
    MNP  = find(diff(sign(slope_data)) == 2);
    MPP  = find(diff(sign(slope_data)) == -2);
    acc = acc + 1
    if acc == 1000
        error('Can not find the proper number of local min compared to local max')
    end
end

% Check for earlier MPP than MNP
if MNP(1) < MPP(1)
    MNP(1) = [];
end
% Check that last MNP has a later MPP
if MNP(end) > MPP(end)
    MNP(end)=[];
end

% iteratively erase small notches
if flag_notch
    nb = 1;
    while nb > 0;
        posBumps = MPP(2 : end) - MNP < ...
            Info.Parameters.Ref_WaveLength(1) * Info.Recording.sRate / 10;
        MPP([false, posBumps]) = [];
        MNP(posBumps) = [];
        
        negBumps = MNP - MPP(1 : end - 1) < ...
            Info.Parameters.Ref_WaveLength(1) * Info.Recording.sRate / 10;
        MPP(negBumps) = [];
        MNP(negBumps) = [];
        
        nb = max(sum(posBumps), sum(negBumps));
    end
end
           