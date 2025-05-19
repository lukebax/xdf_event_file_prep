% Purpose:
%   - Clean up the 'annotation' column in one or more *_events.csv files
%   - Removes all whitespaces: leading, trailing, and internal
%   - Overwrites each *_events.csv file in-place
%
% Usage:
%   - Edit the list below to include the .xdf filenames you want to process
%   - Filenames must include the '.xdf' extension
%   - Corresponding *_events.csv files must already exist in the same folder

clear; clc;

%% USER INPUT
xdfFiles = {
    'example_run1.xdf',
    'example_run2.xdf'
};

%% PROCESS EACH FILE
for i = 1:length(xdfFiles)
    xdfFile = xdfFiles{i};

    % Get base name without .xdf extension
    [~, baseName, ~] = fileparts(xdfFile);

    % Define expected _events.csv file
    eventsFile = baseName + "_events.csv";

    % Check file exists
    if ~isfile(eventsFile)
        warning('Events file not found: %s. Skipping.', eventsFile);
        continue;
    end

    % Read table and treat all columns as strings
    opts = detectImportOptions(eventsFile, 'TextType', 'string', 'VariableNamingRule', 'preserve');
    opts = setvartype(opts, 'string');
    T = readtable(eventsFile, opts);

    % Check if 'annotation' column exists
    if ~ismember('annotation', T.Properties.VariableNames)
        warning('No annotation column in %s. Skipping.', eventsFile);
        continue;
    end

    % Clean each annotation entry
    for iAnnot = 1:height(T)
        val = T.annotation(iAnnot);
        if strlength(val) > 0
            % Remove leading/trailing whitespace
            cleaned = strtrim(val);
            % Remove all internal spaces
            cleaned = strrep(cleaned, " ", "");
            % Save cleaned value
            T.annotation(iAnnot) = cleaned;
        end
    end

    % Overwrite original file
    writetable(T, eventsFile, 'Delimiter', ',');

    fprintf('Cleaned annotations in: %s\n', eventsFile);
end

disp('Finished removing whitespaces from annotations.');