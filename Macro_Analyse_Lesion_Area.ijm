/*
 *****************************************************************************
 * The authors of the macro reserve the copyrights of the original macro.
 * However, you are welcome to distribute, modify and use the program under 
 * the terms of the GNU General Public License as stated here: 
 * (http://www.gnu.org/licenses/gpl.txt) as long as you attribute proper 
 * acknowledgement to the author as mentioned above.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * *****************************************************************************
 *
 */

// Create dialog, create save folders, and select file(s) to process
Dialog.create("Measure Lesion Area");
Dialog.addCheckbox("Analyse single image container file", true);
Dialog.addCheckbox("Save ROI Selections", true);
Dialog.addString("Name of saving folder: ", "_Results");
Dialog.show();

// Variables of Dialog and Global Variables
single_file=Dialog.getCheckbox();
SAVE_ROI=Dialog.getCheckbox();
save_folder=Dialog.getString();
sep = File.separator;

//Fetch the folders' and files' names when input is a single file or a folder
//Create a list of the files that will be quantified
if (single_file)
{
	Filelist=newArray(1);
	Filelist[0] = File.openDialog("Select a file to proccess...");
	SourceDir=File.getParent(Filelist[0]);
	Filelist[0]=File.getName(Filelist[0]);
	SAVE_DIR=SourceDir;
}else
{
	SourceDir = getDirectory("Choose source directory");
	Filelist=getFileList(SourceDir);
	SAVE_DIR=SourceDir;
	BASIC_NAME=File.getName(SourceDir);
}

// Remove Folders from Filelist array (when input is a folder with individual images)
tmp=newArray();
for(k=0;k<Filelist.length;k++)
{
	if (!File.isDirectory(SourceDir+"/"+Filelist[k]))
	{
		tmp = Array.concat(tmp,Filelist[k]); 
	}
}
Filelist=tmp;
Array.sort(Filelist);

//Add date and time in results folder's name
//Create the output folder under the same folder where the input file (or folder) is
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
month=month+1;
save_folder=save_folder+"_"+year+""+month+""+dayOfMonth+"_"+hour+""+minute;
new_folder=SAVE_DIR + sep + save_folder;
File.makeDirectory(new_folder);

// Reset the Roi Manager and Clear the results window
roiManager("reset");
run("Clear Results");

// Start opening one by one the images of the file list using Bio-Formats Importer
for (k=0;k<Filelist.length;k++)
{
	run("Bio-Formats Macro Extensions");
	Ext.setId(SourceDir+sep+Filelist[k]);
	Ext.getSeriesCount(SERIES_COUNT);
	FILE_PATH=SourceDir + sep + Filelist[k];
	
	for (i=0;i<SERIES_COUNT; i++) 
	{
		options="open=["+ FILE_PATH + "] " + "autoscale color_mode=Default view=Hyperstack stack_order=XYCZT " + "series_"+d2s(i+1,0);
		run("Bio-Formats Importer", options);
		FILE_NAME=File.getName(FILE_PATH);
		Ext.setSeries(i);
		Ext.getSeriesName(SERIES_NAMES);
		SERIES_NAMES=replace(SERIES_NAMES, " ", "_");
		SERIES_NAMES=replace(SERIES_NAMES, "/", "_");
		SERIES_NAMES=replace(SERIES_NAMES, "\\(", "");
		SERIES_NAMES=replace(SERIES_NAMES, "\\)", "_");
		SAVE_NAME=Filelist[k]+"_"+SERIES_NAMES;
		rename(SAVE_NAME);

		//Check opened image dimensions and display messages to the user
		getDimensions(width, height, channels, slices, frames);
		getPixelSize(unit, pixelWidth, pixelHeight);
		if (unit=="pixels" || unit=="" || unit==" ")
		{
			waitForUser("This image is not calibrated. The area will be calculated in squared pixels.");
		}
		if(channels<2)
		{
			print(SAVE_NAME+": Single Channel Image detected");
			//showMessageWithCancel("Single Channel Image","This image has only one channel. Do you want to proceed with the quantification?");
			run("Enhance Contrast", "saturated=0.35");

		}else {
			Stack.setDisplayMode("composite");
			run("Enhance Contrast", "saturated=0.35");
		}
		if(slices>1)
		{
			print(SAVE_NAME+": This image is a z-stack. The area quantification will proceed on a maximum intensity projection of the image");
			//showMessageWithCancel("z-stack","This image is a z-stack. If you press OK, then the area quantification \nwill proceed on a maximum intensity projection of the image");
			run("Z Project...", "projection=[Max Intensity]");
			close(SAVE_NAME);
			run("Enhance Contrast", "saturated=0.35");
		}
		if(frames>1)
		{
			print(SAVE_NAME+": This image is a time-lapse. The area quantification will proceed only for the currently selected time frame");
			//showMessageWithCancel("Time-lapse","This image is a time-lapse. If you press OK, then the area quantification \nwill proceed only at the currently selected time frame");
			run("Enhance Contrast", "saturated=0.35");
		}
		
		setTool("freehand");
		waitForUser("Please select the region of lesion and press OK");
		if(selectionType()<0)
		{
			showMessageWithCancel("No Selection","You did not select something. The whole image will be selected!");
			run("Select All");
		}
		run("Set Measurements...", "area display redirect=None decimal=3");
		run("Measure");
		roiManager("Add");
		getResultLabel(nResults-1);
		print(getResultLabel(nResults-1));
		setResult("Label", nResults-1, SAVE_NAME);
		updateResults();
		close();
		if(SAVE_ROI)
		{
			roiManager("save", new_folder+ sep + SAVE_NAME+"_Selections"+".zip");
		}
		roiManager("reset");
	}
}
saveAs("Results", new_folder+ sep +"Results"+".txt");
run("Clear Results");
run("Close All");