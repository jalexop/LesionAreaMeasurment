# Lesion Area Measurment

Quantify a selected image area

- Open the macro in FIJI by dragging and dropping the .ijm file on imageJ/FIJI or File-->Open… and selecting the macro file. Then click Run.
- The option "Analyse single image container file" is selected by default. This means that the macro will process only single files (images or image containers). If this option is not checked, then the macro asks for an input folder and will process all image (or image container) files located in this folder.
- The option “Save ROI Selections” is marked by default. Uncheck this if you do not wish to save the area selections.
- Then give the basic name of the output folder where the result text files and the regions of interest (ROIs) will be saved. This new folder will be located in the same folder where the input files exist. The name of the output folder will also contain the date and time the macro has run (e.g. _Results_20211020_1535).
- Press OK and then select the folder containing the image files (or the image container file) to be analysed.
- Every selected image will be opened, together with a pop-up message that states “Please select the region of lesion and press OK”. With the free-hand selection tool delineate the whished area. When done click OK.
- The step above will be repeated until all images will be processed.
- In the saving folder selected in step 22e, you will find a .txt file that contains the results of your analysis. This file is a tab-separated file with two columns (name of image and Area measurement) and as many lines as the analysed images.

Notes:
- The macro expects as input, images with a single z-level, a single time-frame and three channels. However, it can accept as an input any kind of hyper-stack, notifying the user during the process of the image, with messages at the Log Window.
- The area measurement will have the same unit as the image pixel size (i.e. if the image is not calibrated, then the area’s unit will be squared pixels).
