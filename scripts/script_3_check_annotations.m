% Purpose:
%   - Summarize annotation labels used in one or more *_events.csv files
%   - Outputs a summary table with:
%       1. Annotation
%       2. TotalOccurrences
%       3. FilesContainingEvent
%   - Helps the user spot typos or inconsistencies before continuing
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

%% INITIALIZE STORAGE
allAnnotations = string.empty;
fileAnnotationMap = containers.Map();

%% PROCESS EACH FILE
for i = 1:length(xdfFiles)
    xdfFile = xdfFiles{i};

    % Get base name without .xdf extension
    [~, baseName, ~] = fileparts(xdfFile);

    % Define expected _events.csv file
    eventsFile = baseName + "_events.csv";

    % Check if file exists
    if ~isfile(eventsFile)
        warning('Events file not found: %s. Skipping.', eventsFile);
        continue;
    end

    % Read the file
    T = readtable(eventsFile, 'TextType', 'string');

    % Check for annotation column
    if ~ismember('annotation', T.Properties.VariableNames)
        warning('No annotation column in %s. Skipping.', eventsFile);
        continue;
    end

    % Get non-empty annotations
    annotationsInFile = T.annotation(strlength(T.annotation) > 0);
    allAnnotations = [allAnnotations; annotationsInFile];

    % Track which files each annotation appears in
    uniqueAnnotations = unique(annotationsInFile);
    for j = 1:length(uniqueAnnotations)
        annot = uniqueAnnotations(j);
        if ~isKey(fileAnnotationMap, annot)
            fileAnnotationMap(annot) = {eventsFile};
        else
            currentList = fileAnnotationMap(annot);
            fileAnnotationMap(annot) = [currentList, {eventsFile}];
        end
    end
end

%% SUMMARIZE ANNOTATIONS
uniqueAnnots = unique(allAnnotations);
n = numel(uniqueAnnots);

Annotation = strings(n,1);
TotalOccurrences = zeros(n,1);
FilesContainingEvent = zeros(n,1);

for i = 1:n
    annot = uniqueAnnots(i);
    Annotation(i) = annot;
    TotalOccurrences(i) = sum(allAnnotations == annot);
    if isKey(fileAnnotationMap, annot)
        % FilesContainingEvent(i) = numel(unique(fileAnnotationMap(annot)));
        FilesContainingEvent(i) = numel(unique(cellfun(@char, fileAnnotationMap(annot), 'UniformOutput', false)));
    else
        FilesContainingEvent(i) = 0;
    end
end

% Create and save the summary table
summaryTable = table(Annotation, TotalOccurrences, FilesContainingEvent);
writetable(summaryTable, 'events_check.csv', 'Delimiter', ',');

fprintf('Saved annotation summary to: events_check.csv\n');
disp('Please review this file to check for unexpected annotations.');