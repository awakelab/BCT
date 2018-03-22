function [output trials] = BCT_analysis_raw(data,cycle1threshold)

% if cycle1threshold does not exist, defaults to all single trials selected
% to be removed

indx_terminate2 = find(data(:,2) == 2);
indx_terminate3 = find(data(:,2) ==  3);
indx_terminate2(:,2) = 2;
indx_terminate3(:,2) = 3;
indx_endtrial = sortrows([indx_terminate2; indx_terminate3]);

for i_find = 1:size(indx_endtrial,1)
    % cycle number
    trials(i_find,1) = i_find;
    % cycle Start keypress #
    if i_find == 1
        trials(i_find,2) = 1;
    else
        trials(i_find,2) = indx_endtrial(i_find-1,1)+1;
    end
    % cycle end keypress #
    trials(i_find,3) = indx_endtrial(i_find,1);
    % number presses in cycle
    trials(i_find,4) = (trials(i_find,3) - trials(i_find,2))+1;
    % Termination Key (2 = count 9) (3 = forget reset);
    trials(i_find,5) = indx_endtrial(i_find,2);
    % Time Terminate
    trials(i_find,6) = data(trials(i_find,3),1);
    % Average keypress length in cycle
    if i_find == 1
        trials(i_find,7) = (data(trials(i_find,3),1) - 0)/ trials(i_find,4);
    else
        trials(i_find,7) = (data(trials(i_find,3),1) - data(trials(i_find,2)-1,1))/ trials(i_find,4);
    end
end
% Examine single resp trials
% if single trial time < 1 second, Remove it.
%cycle1threshold = 10;
if ~exist('cycle1threshold','var')
    cycle1threshold = max(data(:,1));
end
output.singlesremoved = sum(trials(:,4)==1 & trials(:,7) < cycle1threshold);
output.singlesremoved_detailed = trials(trials(:,4)==1 & trials(:,7) < cycle1threshold,:);
trials(trials(:,4)==1 & trials(:,7) < cycle1threshold,:) = [];

if output.singlesremoved
    trials(:,1) = 1:size(trials,1);
end

output.totaltrials = size(trials,1);
%indx_endtrial(i_find-1,1)+1
% 1 = acc
trials((trials(:,4) == 9 & trials(:,5) == 2),8) = 1;
output.number_acc = sum(trials(:,8) == 1);
% 2 = Miscount
trials((trials(:,4) ~= 9 & trials(:,5) == 2),8) = 2;
output.number_mis = sum(trials(:,8) == 2);
% 3 = Reset
trials((trials(:,5) == 3),8) = 3;
output.number_res = sum(trials(:,8) == 3);

if (output.number_acc+output.number_mis+output.number_res)~= output.totaltrials
    %fprintf('cycle numbers don''t tally\n');    
    output.manualcheck_required = 1;
else
    output.manualcheck_required = 0;
end