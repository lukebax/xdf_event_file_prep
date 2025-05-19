# EEG XDF Event Files Preparation

This repository contains three MATLAB scripts designed to help create event sidecar files (`.csv` files) for EEG `.xdf` data. These scripts are intended to be used immediately after data collection, before moving the raw EEG data from your local computer to the backup server.

The process is broken down into **five steps**. Before running the first step, the user must have downloaded the three scripts from this repository and moved the scripts to the same folder in which the newly collected `.xdf` data are stored. Once the `.xdf` data and scripts are in the same location, the event preparation process can begin.

- The first step involves running the first script, which will create the event files.
- The second step is a manual step where the user must open one of the event files and edit (or “clean”) the events—for example, removing unwanted events and adding descriptive annotations.
- The third step involves running the second script, which ensures there are no whitespaces in your added annotations.
- The fourth step involves running the third script, which summarises your annotations in a separate file for you to inspect.
- If you find issues with your events, you will need to return to the second step to fix your annotations; if you find no issues, you are finished and can proceed to backing up your raw `.xdf` data and the associated event sidecar files on the backup server.

## Scripts

| Script | Purpose |
|--------|---------|
| `script_1_create_event_tables.m` | Loads `.xdf` file(s), extracts EEG event data, and generates editable `.csv` files for annotation. |
| `script_2_remove_annotation_whitespaces.m` | Cleans all whitespace from the manually edited annotation fields in the `_events.csv` file(s). |
| `script_3_check_annotations.m` | Summarizes all annotation labels across files to help the user detect typos or inconsistencies. |

## Requirements

- MATLAB R2024 or newer  
- EEGLAB v2024 or newer  
- EEGLAB plugin: `xdfimport`  
  - Required to load `.xdf` files into EEGLAB  
  - See **Installing the xdfimport EEGLAB Plugin** below

## File Structure

All scripts and `.xdf` data files should be placed in the same folder.

**Example layout:**
```
my_recording_folder/
  ├── script_1_create_event_tables.m
  ├── script_2_remove_annotation_whitespaces.m
  ├── script_3_check_annotations.m
  ├── example_run1.xdf
  ├── example_run2.xdf
```

## How to Use

Follow these five steps in sequence:

### Step 1: Create Event Tables
- Open `script_1_create_event_tables.m` in MATLAB.
- Edit the `xdfFiles` list at the top of the script to include the names of your `.xdf` file(s), including the `.xdf` extension.
- Run the script. It will generate:
  - `*_events.csv` — editable file where you'll later annotate each event
  - `*_urevents.csv` — read-only backup (do not modify)

### Step 2: Manually Edit the Event Table(s)
- Open each `*_events.csv` file in Excel or other spreadsheet editor.
- Review the events, delete unwanted rows (e.g. false triggers).
- Fill in the `Annotation` column with a brief, meaningful label for each retained event.
- See **Using Standardised Annotations** below for guidance on the standardised annotation conventions used by our group.

### Step 3: Remove Annotation Whitespaces
- Open `script_2_remove_annotation_whitespaces.m` in MATLAB.
- Use the same `xdfFiles` list as in Step 1.
- Run the script. It will remove all leading, trailing, and internal whitespace from the `annotation` entries and overwrite each `_events.csv` file in place.

### Step 4: Check Your Annotations
- Open `script_3_check_annotations.m`.
- Use the same `xdfFiles` list again.
- Run the script. It will generate a file called `events_check.csv` containing a summary of all annotations across files, including:
  - Each unique annotation
  - Total number of occurrences
  - Number of files it appears in
- Open and review `events_check.csv`. If you notice typos or unexpected entries, return to Step 2 and fix the annotation(s), then re-run Steps 3 and 4.

### Step 5: Backup Your Data
- Once all annotations are complete and consistent, move the following files to the backup server:
  - The raw `.xdf` file(s)
  - The corresponding `*_events.csv` and `*_urevents.csv` files

## Output Files

For each `.xdf` file processed, the following files will be created:

- `*_events.csv` — editable file containing structured event data and annotations
- `*_urevents.csv` — backup file without annotations (read-only)
- `events_check.csv` — summary file listing all annotation labels and their frequency

## Installing the xdfimport EEGLAB Plugin

1. Open MATLAB.  
2. Run the command `eeglab` in the MATLAB Command Window to launch the EEGLAB graphical interface.  
3. In the EEGLAB window, click on **File** in the top menu bar.  
4. Select **Manage EEGLAB extensions** from the dropdown menu. This opens the EEGLAB Plugin Manager.  
5. In the Plugin Manager, use the search bar to search for `xdf`.  
6. Locate the plugin labeled **xdfimport**.  
7. Click on **xdfimport** to highlight it, then click the **Install/Update** button.

## Using Standardised Annotations

All stimulus annotations should follow the standard system which is `stimulus_intervention`.

Stimulus should give you information about the modality, intensity (if applicable) and location of the stimulus (if applicable).

Intervention gives you information about an intervention that may alter the stimulus response, and gives the intervention modality, location relative to the stimulus (if applicable) and location of the intervention (if applicable).

e.g. pinprick032foot_brushipsicheek – this tells you that the stimulus was a 32 mN pinprick applied to the foot. Prior to the pinprick the intervention was brushing on the cheek ipsilateral to the pinprick.

If there is no intervention please put `_na`

Important things to note: there are no spaces in the name and only one underscore. There are no capital letters.

The tables below set out the standard naming first for the stimuli (before the underscore) and then the intervention (after the underscore). To create a complete annotation please join these two bits together with the underscore.

If the stimulus or intervention you have used is not listed in the tables below please see the steps afterwards on how to create a new standard annotation.

Note that if you would like to include an annotation that is not exact, or a general comment e.g. baby restless then this can be included using a ‘comment annotation’. This uses the format `c_xxxxx` e.g. `c_babyrestless`.

#### Stimuli

| Type                   | Intensity                                  | Location           | Example (of section before underscore)  | Notes                                                                                                           |
|------------------------|--------------------------------------------|--------------------|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| heellance              | –                                          | –                  | heellance                               |                                                                                                                 |
| controlheellance       | –                                          | –                  | controlheellance                        |                                                                                                                 |
| immunisation           | –                                          | thigh              | immunisationthigh                       |                                                                                                                 |
| cannulation            | –                                          | foot, hand         | cannulationfoot                         |                                                                                                                 |
| pinprick               | 032, 064, 128, 256, 512 (always 3 digits!) | foot, thigh, hand  | pinprick032hand                         |                                                                                                                 |
| touch                  | –                                          | foot, thigh, hand  | touchthigh                              |                                                                                                                 |
| led                    | Lux, distance                              | –                  | led850lux50cm                           | This is the old visual stimulus                                                                                 |
| photic                 | Lumen, distance                            | –                  | photic514lumen30cm                      | NB 514 lumen is if used on setting 4. The photic visual stimulus has maximum output 900 lumens with 7 levels    |
| speaker                | db, tone and duration (both 5 digits!)     | –                  | speaker80db00500hz00100ms               |                                                                                                                 |
| headphone              | db, tone and duration (both 5 digits!)     | –                  | headphone70dbnhl00500hz00100ms          |                                                                                                                 |
| ropdrops               | –                                          | –                  |                                         |                                                                                                                 |
| ropspeculumleft        | –                                          | –                  |                                         |                                                                                                                 |
| ropspeculumright       | –                                          | –                  |                                         |                                                                                                                 |
| ropspeculum            | –                                          | –                  |                                         | If side unknown                                                                                                 |
| ropend                 | –                                          | –                  |                                         | Note this is when the speculum is removed from second eye                                                       |
| ropindent              | –                                          | –                  |                                         |                                                                                                                 |
| ropstart               | –                                          | –                  |                                         | Can be used instead of specific markers i.e. if you don't know which eye was first                              |
| optosstart             |                                            |                    |                                         |                                                                                                                 |
| optosend               |                                            |                    |                                         |                                                                                                                 |
| lpin                   |                                            |                    |                                         |                                                                                                                 |
| lpout                  |                                            |                    |                                         |                                                                                                                 |
| nappystart             |                                            |                    |                                         |                                                                                                                 |
| nappystop              |                                            |                    |                                         |                                                                                                                 |
| longlinecleanstart     |                                            |                    |                                         | Start of cleaning for long line insertion                                                                       |
| longlinethreadingstart |                                            |                    |                                         | Start of threading of long line                                                                                 |
| longlineussstart       |                                            |                    |                                         | Start of ultrasound for long line position                                                                      |
| longlineussstop        |                                            |                    |                                         | Stop of ultrasound for long line position                                                                       |
| syncnirs1              |                                            |                    |                                         | First marker used to sync vital signs laptop with NIRS machine                                                  |
| syncnirs2              |                                            |                    |                                         | Second marker used to sync vital signs laptop with NIRS machine                                                 |
| syncnirs3              |                                            |                    |                                         | Third marker used to sync vital signs laptop with NIRS machine                                                  |
| rbctransfusionstart    |                                            |                    |                                         | Start of red blood cell transfusion                                                                             |
| rbctransfusionstop     |                                            |                    |                                         | End of red blood cell transfusion                                                                               |

#### Interventions

| Type         | Location relative to stimulus  | Location         | ~Speed and duration  | Example (of section after underscore) | Notes                                           |
|--------------|--------------------------------|------------------|----------------------|---------------------------------------|-------------------------------------------------|
| na           | –                              | -                |                      | na                                    |                                                 |
| brush        | ipsi, contra                   | leg, arm, cheek  | 3cms (3 cm/s) and 5s | brushipsicheek3cms5s                  |                                                 |
| stroke       | ipsi, contra                   | leg, arm, cheek  | 3cms (3 cm/s) and 5s | strokecontraleg3cms5s                 |                                                 |
| kangaroocare | –                              | –                |                      | kangaroocare                          |                                                 |
| paracetamol  | –                              | –                |                      | paracetamol                           |                                                 |
| la           | –                              | –                |                      | la                                    | Local anaesthetic (e.g. ametop or emla)         |
| ga           |                                |                  |                      | ga                                    | General anaesthetic                             |
| imp          | –                              | –                |                      | imp                                   | Investigational medicinal product (for RCT use) |

#### How to Create a New Standard Annotation

1. Decide on an appropriate annotation that follows the system above.
2. Check this with some others in the group to see that the new annotation makes sense.
3. Add the new annotation to the tables above and update the document on the shared drive.
4. Print the document for use next to the analysis computer.
