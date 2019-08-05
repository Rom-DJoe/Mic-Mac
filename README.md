# Mic-Mac
Automatic Detection of Nuclei in Paramecium

This macro works on a folder containing multiple channels acquisitions (see datatset folder).
The macro will allow the detection of nuclei (automatically, semi-automatically of fully manually) and quantifies the fluorescence in both the red and green channels.

-First you have to specify how many channels you have in your acquisition (from 1 to 4).

-Each channel has to be an independent .tif file (it cannot be a stacked file).

-Then you have to specify in which order the channels are sorted in the folder.

-For each acquisition an automatic detection is first performed (using a combination of the red and green channels).

-If multiple nuclei are detected as one, you can try to use a watershed algorithm to separate them.

-If the automatic detection failed you can help the macro by drawing region of interest around the nuclei. The channel that is active when you press OK will be the one on which the detection will be performed.

-If everything failed at this point you still can draw manually the regions around the nuclei.

-If the acquisition is not compatible with this detection, you can skip this acquisition at any time.

-As a result: a "*_Map.tif" image is saved where you can check your regions drawn around the nuclei and also the regions used to measure the background.

-A .csv file is created with the file name and the mean fluorescence intensity of each region.
