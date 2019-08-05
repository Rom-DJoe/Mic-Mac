// Done by RLB @ Imagerie-Gif 2016
// romain.lebars@i2bc.paris-saclay.fr
// Optimized for ImageJ v 1.51i

// This macro works on multiple channels acquisitions, detects the nuclei (automatically, semi-automatically of fully manually) and quantifies the fluorescence in both the red and green channels.

// First you have to specify how many channels you have (from 1 to 4).
// Each channel has to be an independent .tif file (it cannot be a stacked file)
// Then you have to specify in which order they are sorted in the folder.
// For each acquisition an automatic detection is first performed (using a combination of the red and green channels).
// If multiple nuclei are detected as one, you can try to use a watershed algorithm to separate them.
// If the automatic detection failed you can help the macro by drawing region of interest around the nuclei. The channel that is active when you press OK will be the one on which the detection will be performed.
// If everything failed at this point you still can draw manually the regions around the nuclei.
// If the acquisition is not compatible with this detection, you can skip this acquisition at any time.
// As a result: an image (*_Map.TIF) of the map is saved were you can check your regions around the nuclei and also the regions used to measure the background.
// A .csv file is created with the file name and the mean fluorescence intensity of each region.

run("ROI Manager...");

setBatchMode(true);
ClearTotal();

Ratio = newArray(1);
first = 1;
manualseg = "Nope";
ndfile = 0;

var Ignore=0;
var seg =0;

//Get screen info 
scrW = screenWidth;
scrH = screenHeight;

posW = scrW/30;
posH = scrH/10;
//setLocation(posW,posH);

// Create arrays for results
Resultats = newArray(1);
Resultats [0] = "Name;Channel;Region;Size_(micron_square);Mean_Fluorescence;Raw_Integrated_Density";

roiManager("UseNames","true"); 
run("Set Measurements...", "area mean standard modal integrated limit display redirect=None decimal=3");

//How many channels for each image

Channels= newArray("1", "2", "3", "4");
Dialog.create("Folder Structure");
Dialog.addChoice("How many channels ?", Channels, "4");
//Dialog.setLocation(x+width,y); 
Dialog.show(); 
NbChannels=Dialog.getChoice();

//Channels correspondence

Colors = newArray("Transmission","Blue","Green","Red");
Dialog.create("Channels order");
Dialog.addChoice("Channel 1 : ", Colors , "Transmission" );
if (NbChannels>1) { Dialog.addChoice("Channel 2 : ", Colors , "Red"); }
if (NbChannels>2) { Dialog.addChoice("Channel 3 : ", Colors , "Green"); }
if (NbChannels>3) { Dialog.addChoice("Channel 4 : ", Colors , "Blue" ); }

Dialog.show(); 

Ch1=Dialog.getChoice();
if (NbChannels>1) {Ch2=Dialog.getChoice();}
if (NbChannels>2) {Ch3=Dialog.getChoice();}
if (NbChannels>3) {Ch4=Dialog.getChoice();}

//Import images as Image sequences

dir = getDirectory("Select the source directory ");
Filelist = getFileList(dir);
ListLength = Filelist.length;

for(m=0;m<Filelist.length;m++)
		{
		showProgress(m, ListLength);
		name = Filelist[m];
		path = 	dir+name;
	
		if (endsWith(name, "tif") || endsWith(name, "TIF"))
			{
			// This code find the common part of each channel name
			NameA = Filelist[m];
			NameB = Filelist[m+1];
			NameL = lengthOf(NameA);
			equal = 1;
			
			z = 0;
			while (equal == 1) 
				{
				Chara = substring(NameA, z, z+1);
				Charb = substring(NameB, z, z+1);
				if (Chara!=Charb) {equal = 0;}
				z=z+1;
				}
			// You can choose where the commun part stops here (e.g: z-3)	
			Name = substring(NameA,0,z-1);

			Dialog.create("File Name");
			Dialog.addMessage("Type the name of this acquisition !");
			Dialog.addString("Acquisition Name :", Name, 50);
			Dialog.show();
			nameW= Dialog.getString();
			
			
			open(path);
			rename(nameW+";"+Ch1);
			Ignore=0;

			if (NbChannels>1) 
				{
				n=m+1;
				name = Filelist[n];
				path = 	dir+name;
				open(path);
				rename(nameW+";"+Ch2);
				}
			if (NbChannels>2) 
				{
				n=n+1;
				name = Filelist[n];
				path = 	dir+name;
				open(path);
				rename(nameW+";"+Ch3);
				}
			if (NbChannels>3) 
				{
				n=n+1;
				name = Filelist[n];
				path = 	dir+name;
				open(path);
				rename(nameW+";"+Ch4);
				}

			ProcessImages();
		
//Record to the Result Array
			
			if (Ignore == 0)
				{
				nResult = nResults;
				
				for (r=0; r<nResults; r++)
					{	
					Lab=getResultString("Label", r);
					Area = getResultString("Area", r);
					Mean = getResultString("Mean", r);
					RawIntDen = getResultString("RawIntDen", r);
	
					Line=Lab+Area+";"+Mean+";"+RawIntDen;
	
					Resultats = Array.concat(Resultats,Line);
					}
//Line 167-213 = Create the Green/Red ratio calculation (Optional)
			
//				if (first == 1)
//					{
//					Ratio = Array.slice(Ratio,1);
//					first = 0;
//					}			
//				else
//					{
//					e = Ratio.length;
//					Ratio = Array.slice(Ratio, e);
//					}			

//
//				nbroi = (nResults - 2) / 2 ;
//				GBG = nResults - 2;
//				GreenBG = getResultString("Mean", GBG);
//				GreenBG  = parseFloat(GreenBG);

//
//				RBG = nResults - 1;
//				RedBG = getResultString("Mean", RBG);	
//				RedBG  = parseFloat(RedBG);
//	
//				for (c=1; c<=nbroi; c++) 
//					{ 
//					d = c-1;
//					nucG = GBG - (GBG/2) - nbroi + d ;
//					NucG = getResultString("Mean", nucG);
//					NucG = parseFloat(NucG );
//
//					nucR = GBG - (GBG/2) + d ;
//					NucR = getResultString("Mean", nucR);
//					NucR = parseFloat(NucR );
//	
//					ratioGR = (NucG - GreenBG ) / ( NucR - RedBG ) ;	
//					RatioGR = nameW+";Ratio_Green/Red;"+"Nucleus_"+c+";;;;"+ratioGR;
//
//					Ratio = Array.concat(Ratio,RatioGR);
//					}
				}
			else
				{
				Ignored = nameW+";Ignored";
				Resultats = Array.concat(Resultats,Ignored);
				}

//			if (Ignore == 0)
//				{
//				Resultats = Array.concat(Resultats,Ratio);
//				}

			run("Clear Results");
			run("Close All");	
			roiManager("reset");

			m = m + NbChannels - 1;

			Array.show(Resultats);
			selectWindow("Resultats");
			saveAs("Results", dir+"Results.csv");
			}
		}
while (isOpen("Results"))
	{
	selectWindow("Results");
	run("Close");
	}

while (isOpen("Log"))
	{
	selectWindow("Log");
	run("Close");
	}

while (isOpen("Results.csv"))
	{
	selectWindow("Results.csv");
	run("Close");
	}

run("Line Width...", "line=1");
setForegroundColor(255, 255, 255);

P = m / NbChannels; 

showMessage("Yippee Kayay!","Job Done!  "+P+" Files Processed!");
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function ProcessImages()
{
// Generate the merge image to do the map
	RedCh = nameW+";"+"Red";
	GreenCh = nameW+";"+"Green";
	BlueCh = nameW+";"+"Blue";

	if (NbChannels == 1) 
		{
		selectWindow(nameW+";"+Ch1);
		run("Duplicate...", " ");
		}
	else if (NbChannels == 2) 
		{
		if (Ch1 == "Red" || Ch2 == "Red")
			{
			if (Ch1 == "Green" || Ch2 == "Green")
				{
				run("Merge Channels...", "c1=["+RedCh+"] c2=["+GreenCh+"] keep ignore");
				}
			else if (Ch1 == "Blue" || Ch2 == "Blue")
				{
				run("Merge Channels...", "c1=["+RedCh+"] c5=["+BlueCh+"] keep ignore");
				}
			else 
				{
				selectWindow(RedCh);
				run("Duplicate...", " ");
				}
			}
		else if (Ch1 == "Green" || Ch2 == "Green")
			{
			if (Ch1 == "Blue" || Ch2 == "Blue")
				{
				run("Merge Channels...", "c2=["+GreenCh+"] c5=["+BlueCh+"] keep ignore");
				}
			else 
				{
				selectWindow(GreenCh);
				run("Duplicate...", " ");
				}
			}
		}
	else if (NbChannels == 3) 
		{
		if (Ch1 == "Red" || Ch2 == "Red" || Ch3 == "Red")
			{
			if (Ch1 == "Green" || Ch2 == "Green" || Ch3 == "Green")
				{
				if (Ch1 == "Blue" || Ch2 == "Blue" || Ch3 == "Blue")
					{
					run("Merge Channels...", "c1=["+RedCh+"] c2=["+GreenCh+"] c5=["+BlueCh+"] keep ignore");
					}
				else
					{
					run("Merge Channels...", "c1=["+RedCh+"] c2=["+GreenCh+"] keep ignore");
					}
				}
			else
				{
				run("Merge Channels...", "c1=["+RedCh+"] c5=["+BlueCh+"] keep ignore");
				}
			}
		else 
			{
			run("Merge Channels...", "c2=["+GreenCh+"] c5=["+BlueCh+"] keep ignore");
			}
		}
	else if (NbChannels == 4) 
		{
		run("Merge Channels...", "c1=["+RedCh+"] c2=["+GreenCh+"] c5=["+BlueCh+"] keep ignore");
		}
	rename("merge");

//Generate a stack of the fluorescent channels

		if (NbChannels == 1) 
			{
			selectWindow(nameW+";"+Ch1);
			run("Duplicate...", " ");
			}
		else if (NbChannels == 2) 
			{
			N1 = nameW+";"+Ch1;
			N2 = nameW+";"+Ch2;
			run("Concatenate...", "  title=[Stack] keep image1=[N1] image2=[N2] image3=[-- None --]");
			}
		else if (NbChannels == 3) 
			{
			N1 = nameW+";"+Ch1;
			N2 = nameW+";"+Ch2;
			N3 = nameW+";"+Ch3;
			run("Concatenate...", "  title=[Stack] keep image1=[N1] image2=[N2] image3=[N3] image4=[-- None --]");
			}
		else if (NbChannels == 4) 
			{
			N1 = nameW+";"+Ch1;
			N2 = nameW+";"+Ch2;
			N3 = nameW+";"+Ch3;
			N4 = nameW+";"+Ch4;
			run("Concatenate...", "  title=[Stack] keep image1=[N1] image2=[N2] image3=[N3] image4=[N4] image5=[-- None --]");
			}
		rename("stack");
		run("RGB Color");

// Generate a "Full_Stack" containing the merge+stack

	if (NbChannels > 1)
		{ 
		run("Concatenate...", "  title=Full_Stack keep image1=merge image2=stack image3=[-- None --]");
		}
	else
		{
		selectWindow("merge");
		run("Duplicate...", "title=Full_Stack");
		}
	
// Beginning of the segmentation process
			
	RedChOpen = isOpen(nameW+";"+"Red");
	GreenChOpen = isOpen(nameW+";"+"Green");

	if ( RedChOpen == true)
		{
		if ( GreenChOpen == true)
			{
				
// Generate a mask of the nuclei: both red and green signals are merged for this step
	
			selectWindow(nameW+";"+"Red");
			run("Duplicate...", "title=redMask");
			setAutoThreshold("Otsu dark");
			run("Convert to Mask");
			run("Grays");
					
			selectWindow(nameW+";"+"Green");
			run("Duplicate...", "title=greenMask");
			setAutoThreshold("Otsu dark");
			run("Convert to Mask");
			run("Grays");			
	
			imageCalculator("AND create", "redMask","greenMask");
			rename("mask");
			close("redMask");
			close("greenMask");
			seg = 1;
			}
		else 
			{
// Generate a mask of the nuclei : red channel only
			selectWindow(nameW+";"+"Red");
			run("Duplicate...", "title=redMask");
			setAutoThreshold("Otsu dark");
			run("Convert to Mask");
			run("Grays");
			rename("mask");
			seg = 1;
			}
		}
	else if ( GreenChOpen == true)
		{
// Generate a mask of the nuclei : green channel only
		selectWindow(nameW+";"+"Green");
		run("Duplicate...", "title=greenMask");
		setAutoThreshold("Otsu dark");
		run("Convert to Mask");
		run("Grays");
		rename("mask");
		seg = 1;
		}
		
	if (seg == 1)
		{
		run("Analyze Particles...", "size=2000-Infinity pixel add");
		}


	selectWindow("Full_Stack");
	setBatchMode("show");
	roiManager("Show All without labels");

	selectWindow("Full_Stack");
	setLocation(posW,posH);
	getLocationAndSize(x, y, width, height); 

	waitForUser("Check up !", "Please check if the segmentation is OK ?");
	
// First: ask if the auto segmentation is OK ?

	segmentation= newArray("Yes", "No, let's try some watershed", "No, let's help it manually", "No let's do it fully manually", "Ignore this one");
	Dialog.create("Segmentation OK ?");
	Dialog.addRadioButtonGroup("Is the segmentation OK ?", segmentation, 5, 1, "Yes");
	Dialog.setLocation(x+width,y); 
	Dialog.show(); 
	Next=Dialog.getRadioButton;

	setBatchMode("hide");

// If not, try to apply a watershed to the mask

	if (Next=="No, let's try some watershed")
		{
// Ask if now the auto segmentation is OK ?
		selectWindow("mask");
		roiManager("reset");
		run("Select None");
		run("Watershed");
		run("Analyze Particles...", "size=2000-Infinity pixel add");

		selectWindow("Full_Stack");

		setBatchMode("show");
		setLocation(posW,posH);

		getLocationAndSize(x, y, width, height); 
		roiManager("Show All without labels");

		waitForUser("Check up !", "Please check if the segmentation is OK ?");

		segmentation= newArray("Yes", "No, let's help it manually", "No let's do it fully manually", "Ignore this one");
		Dialog.create("Segmentation OK ?");
		Dialog.addRadioButtonGroup("Is the segmentation OK now ?", segmentation, 4, 1, "Yes");
		Dialog.setLocation(x+width,y); 
		Dialog.show(); 
		Next=Dialog.getRadioButton;

		setBatchMode("hide");
		}
	
// If not, try to help by drawing ROI to do the mask to limit the detection area
		
	if (Next=="No, let's help it manually")
		{
		manualseg = "No, let's do it again";
		while (manualseg=="No, let's do it again")
			{
			maskIsOpen = isOpen("mask");
			if (maskIsOpen  == true)
				{
				close("mask");
				}
			

			selectWindow("stack");

			setBatchMode("show");

			getLocationAndSize(x, y, width, height); 

			roiManager("reset");
			setTool("oval");

// Ask to draw ROIs

			waitTitle = "Draw your regions of interest !";
			waitMessage = " Draw a region around your object \n Press ' t ' to save it \n Press OK when you finish";
			waitForUser(waitTitle, waitMessage);
	
			setBatchMode("hide");

// Generate the masks based on the manual roi

			selectWindow("stack");
			run("Select None");
			run("Duplicate...", "title=mask");
			run("Select All");
			run("Clear", "slice");
			run("8-bit");
			setForegroundColor(255, 255, 255);

			nbroi=roiManager("count");
			for (b=0; b<nbroi; b++)
				{
				roiManager("select", b);
				run("Fill", "slice");
				}

// Apply the mask and refine it with the signal of the slice selected

			selectWindow("stack");

			imageCalculator("AND create", "mask","stack");
			rename("onlynuc");
			roiManager("Show None");

			run("Threshold...");
			setAutoThreshold("Minimum dark");

			setBatchMode("show");
			setLocation(posW,posH);

			waitForUser("Set threshold","Set the threshold, then press 'OK' ! ");

			setBatchMode("hide");

			run("Convert to Mask");
			run("Watershed");
			run("Grays");
	
			roiManager("reset");

			run("Analyze Particles...", "size=2000-Infinity pixel add");

			close("onlynuc");

			selectWindow("Full_Stack");

			setBatchMode("show");
			setLocation(posW,posH);

			getLocationAndSize(x, y, width, height); 
			roiManager("Show All without labels");

			waitForUser("Check up !", "Please check if the segmentation is OK ?");

// Ask if the semi manual segmentation is OK ?

			manulaseg= newArray("Yes", "No, let's do it again", "No let's do it fully manually", "Ignore this one");
			Dialog.create("Manual Segmentation OK ?");
			Dialog.addRadioButtonGroup("Is the manual segmentation OK ?", manulaseg, 4, 1, "Yes");
			Dialog.setLocation(x+width,y); 
			Dialog.show(); 
			manualseg =Dialog.getRadioButton;

			setBatchMode("hide");
			}
		}
		
// If not, draw the ROI !
		
		if (Next=="No let's do it fully manually" || manualseg=="No let's do it fully manually")
			{
			manualseg="No let's do it fully manually";
			while (manualseg=="No let's do it fully manually")
				{

				selectWindow("stack");

				setBatchMode("show");

				getLocationAndSize(x, y, width, height); 

				roiManager("reset");
				setTool("freehand");
				
				waitTitle = "Draw your regions of interest !";
				waitMessage = " Draw a region around your object \n Press ' t ' to save it \n Press OK when you finish";
				waitForUser(waitTitle, waitMessage);

// Get the new roi

				nbroi=roiManager("count");

				selectWindow("Full_Stack");

				setBatchMode("show");

				getLocationAndSize(x, y, width, height); 
				roiManager("show all");

				waitForUser("Check up !", "Please check if the segmentation is OK ?");

// Ask if the manual segmentation is OK ?

				manulaseg= newArray("Yes", "No let's do it fully manually", "Ignore this one");
				Dialog.create("Manual Segmentation OK ?");
				Dialog.addRadioButtonGroup("Is the manual segmentation OK ?", manulaseg, 3, 1, "Yes");
				Dialog.setLocation(x+width,y); 
				Dialog.show(); 
				manualseg =Dialog.getRadioButton;

				setBatchMode("hide");
				}
			}
			
	if (Next == "Ignore this one" || manualseg == "Ignore this one")
		{
		Ignore=1;
		}


// Detect the nuclei , name the ROIs , and measure!
	if (Ignore == 0)
		{
		setBatchMode("hide");
		close("mask");

		if (isOpen(nameW+";"+"Green") == true)
			{
			selectWindow(nameW+";"+"Green");
			nbroi=roiManager("count");
			for (b=0; b<nbroi; b++)
				{
				c = b+1;
				roiManager("select", b);
				roiManager("rename", ";Nucleus_"+c+";");
				run("Measure");
				}
			}
		if (isOpen(nameW+";"+"Red") == true)
			{
			selectWindow(nameW+";"+"Red");
			nbroi=roiManager("count");
			for (b=0; b<nbroi; b++)
				{
				c = b+1;
				roiManager("select", b);
				run("Measure");
				}
			}
			
// Line 665-676 : Measure the Blue Channel (Optionnal)

//		if (isOpen(nameW+";"+"Blue") == true)
//			{
//			selectWindow(nameW+";"+"Blue");
//			nbroi=roiManager("count");
//			for (b=0; b<nbroi; b++)
//				{
//				c = b+1;
//				roiManager("select", b);
//				run("Measure");
//				}
//			}
	
// Draw the Nuclei detected on the merge window
	
		selectWindow("merge");
	
		run("Line Width...", "line=3");
		setForegroundColor(255, 255, 0);

		roiManager("deselect");
		roiManager("Show All with labels");
		run("From ROI Manager");
	
			for (b=0; b<nbroi; b++)
			{
			c = b+1;
			roiManager("select", b);
			run("Draw", "slice");
			}
	
		roiManager("deselect");
		roiManager("delete");
		
		if (isOpen(RedCh) == true)
			{
			if (isOpen(GreenCh) == true)
				{
				if (isOpen(BlueCh) == true)
					{
					run("Concatenate...", "  title=[Stack2Proj] keep image1=["+RedCh+"] image2=["+GreenCh+"] image3=["+BlueCh+"] image4=[-- None --]");
					}
				else 
					{
					run("Concatenate...", "  title=[Stack2Proj] keep image1=["+RedCh+"] image2=["+GreenCh+"] image3=[-- None --]");
					}
				}
			else if (isOpen(BlueCh) == true)
				{
				run("Concatenate...", "  title=[Stack2Proj] keep image1=["+RedCh+"] image2=["+BlueCh+"] image3=[-- None --]");
				}
			}
		else if (isOpen(GreenCh) == true)
			{
			if (isOpen(BlueCh) == true)
				{
				run("Concatenate...", "  title=[Stack2Proj] keep image1=["+GreenCh+"] image2=["+BlueCh+"] image3=[-- None --]");
				}
			}
		else if (isOpen(BlueCh) == true)
			{
			selectWindow(BlueCh);
			rename("Stack2Proj");
			}	

// Generate a background region

		selectWindow("Stack2Proj");
		run("Select None");

		if (nSlices>1)
			{
			run("Z Project...", "projection=[Sum Slices]");
			}
		else
			{
			
			run("Duplicate...", "title=Dup");
			}

		rename("Back");
		run("Gaussian Blur...", "sigma=10");
	
		setForegroundColor(255, 255, 255);
		getDimensions(width, height, channels, slices, frames); 
		drawLine(0, 0, width, height);
	
		setAutoThreshold("MinError");
	
		run("Options...", "iterations=50 count=1 black do=Erode");
	
		run("Analyze Particles...", "size=10000-Infinity add");

// Do it manually if automatic detection fails

		if (roiManager("count") == 0)
			{
			selectWindow("Stack2Proj");

			setBatchMode("show");


			getLocationAndSize(x, y, width, height); 

			roiManager("reset");
			setTool("Rectangular");

// Ask to draw ROIs

			waitTitle = "Select the BG !";
			waitMessage = " The background could not be automatically detected \n Select a representative BG square \n Press ' t ' to save it \n Press OK when you finish";
			waitForUser(waitTitle, waitMessage);
	
			setBatchMode("hide");

			}

		
		close("Stack2Proj");

		
		if (roiManager("count") > 1)
			{
			roiManager("deselect");
			roiManager("combine");
			roiManager("add");
	
			BGroi=roiManager("count");
	
			while (BGroi > 1)
				{
				roiManager("select", 0);
				roiManager("delete");
				BGroi=roiManager("count");
				}
			}
	
		roiManager("select", 0);
		roiManager("rename", ";BG;");
	
		selectWindow("merge");
		roiManager("select", 0);
		run("Line Width...", "line=3");
		setForegroundColor(255, 0, 0);
		run("Draw", "slice");
		run("Labels...", "color=white font=18 show use draw");
		run("Flatten");
	
		map =  nameW+"_Map";	
		mappath = dir+map;
		saveAs("tiff", mappath);
		
		roiManager("deselect");
		
		if (isOpen(nameW+";"+"Green") == true)
			{
			selectWindow(nameW+";"+"Green");
			roiManager("select", 0 );
			run("Measure");
			}
	
		if (isOpen(nameW+";"+"Red") == true)
			{
			selectWindow(nameW+";"+"Red");
			roiManager("select", 0 );
			run("Measure");
			}
		roiManager("deselect");
		roiManager("delete");
	}
}	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function ClearTotal()
{
	run("Close All");
	run("Clear Results");
	roiManager("reset");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
