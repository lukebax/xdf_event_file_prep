% Purpose:
%   - Load one or more .xdf files and extract event information
%   - Create two output files for each .xdf:
%       1. *_events.csv — editable by the user (contains annotations)
%       2. *_urevents.csv — clean backup version (read-only)
%   - Skips files if both CSVs already exist
%
% Usage:
%   - Edit the list below to include the .xdf filenames you want to process
%   - Filenames must include the '.xdf' extension

clear; clc;
eeglab;  % Start EEGLAB (required for pop_loadxdf)

%% USER INPUT
xdfFiles = {
    'example_run1.xdf',
    'example_run2.xdf'
};

%% PROCESS EACH FILE
for i = 1:length(xdfFiles)
    xdfFile = xdfFiles{i};
    
    % Ensure the file exists
    if ~isfile(xdfFile)
        warning('File not found: %s. Skipping.', xdfFile);
        continue;
    end

    % Get base name without .xdf extension
    [~, baseName, ~] = fileparts(xdfFile);

    % Define expected output CSV filenames
    eventsFile   = baseName + "_events.csv";
    ureventsFile = baseName + "_urevents.csv";

    % Check if both CSVs already exist
    if isfile(eventsFile) && isfile(ureventsFile)
        fprintf('Files already exist for %s. Skipping.\n', xdfFile);
        continue;
    end

    % Try to load the .xdf file
    try
        EEG = pop_loadxdf(xdfFile);
        EEG = eeg_checkset(EEG);
    catch
        warning('Failed to load %s. Skipping.', xdfFile);
        continue;
    end

    % Check if EEG.event is valid
    if ~isstruct(EEG.event) || isempty(EEG.event)
        warning('No valid events found in %s. Skipping.', xdfFile);
        continue;
    end

    % Sort events by latency
    [~, sortIdx] = sort([EEG.event.latency]);
    EEG.event = EEG.event(sortIdx);
    EEG = eeg_checkset(EEG, 'eventconsistency');

    % Add derived timing fields
    for j = 1:length(EEG.event)
        EEG.event(j).time_sec = EEG.event(j).latency / EEG.srate;
        if j == 1
            EEG.event(j).time_diff_sec = NaN;
        else
            EEG.event(j).time_diff_sec = EEG.event(j).time_sec - EEG.event(j-1).time_sec;
        end
    end

    % Add datetime if available
    if isfield(EEG.etc, 'desc') && isfield(EEG.etc.desc, 'timecreated')
        try
            startTime = datetime(EEG.etc.desc.timecreated, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');
            for j = 1:length(EEG.event)
                EEG.event(j).datetime = startTime + seconds(EEG.event(j).time_sec);
            end
        catch
            for j = 1:length(EEG.event)
                EEG.event(j).datetime = NaT;
            end
        end
    else
        for j = 1:length(EEG.event)
            EEG.event(j).datetime = NaT;
        end
    end

    % Add empty annotation field
    for j = 1:length(EEG.event)
        EEG.event(j).annotation = "";
    end

    % Convert to table and add 'urevent' column
    eventTable = struct2table(EEG.event);
    eventTable.urevent = (1:height(eventTable)).';

    % Reorder columns to match standard order
    desiredOrder = {'urevent', 'latency', 'duration', 'datetime', ...
                    'time_sec', 'time_diff_sec', 'type', 'annotation'};

    % Check that all required columns are present
    if all(ismember(desiredOrder, eventTable.Properties.VariableNames))
        eventTable = eventTable(:, desiredOrder);

        % Round timing fields
        eventTable.time_sec = round(eventTable.time_sec, 3);
        eventTable.time_diff_sec = round(eventTable.time_diff_sec, 3);

        % Save editable events CSV
        writetable(eventTable, eventsFile, 'Delimiter', ',');

        % Create and save urevents CSV (read-only, no annotations)
        ureventTable = removevars(eventTable, {'urevent', 'annotation'});
        writetable(ureventTable, ureventsFile, 'Delimiter', ',');
        fileattrib(ureventsFile, '-w', 'a');  % Set to read-only

        fprintf('Created: %s and %s\n', eventsFile, ureventsFile);
    else
        warning('Missing expected fields in event table from %s. Skipping.', xdfFile);
    end
end

disp('Finished creating event tables.');