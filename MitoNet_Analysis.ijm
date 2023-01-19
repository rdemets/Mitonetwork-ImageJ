// This macro aims to 
// All function used are available from the stable version of Fiji.
// Requires installation of Labkit and IJPB plugin
// First macro aim to generate 
// Second macro performs 

// Macro author R. De Mets
// Version : 0.0.4, 07/07/2022
// change prominence 200 Find Maxima
// Save PNG of ConnComp



// Global variables to execute both macros in sequence
 
macro "Realignment Button Action Tool - C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0eD0fD10D11D12D13D14D15D16D19D1aD1fD20D21D22D23D24D25D26D2fD30D31D32D33D34D35D36D3fD40D41D42D50D51D52D60D61D62D70D71D80D90Da0Db0Db1DcfDdfDeeDefDf0Df1DfdDfeDffC005D2eC000Dc0C075Db3C000D17D2aC00fD3cD3dD4cD4dD5cD5dD6dD7dC092De1Df6Df7C09fD68DacC00cD4eC010De0C09cD56C001D0cD0dD1bD1eD4fDbfC05fD8cC0f4Dc4Dc5Dc6Dc7Dc8Dc9Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDe4De5De6De7De8De9DeaC0deDbcC008D3bC001D18C0f5DcaC01fD8dC0d3De2C0bfD67C00dDbeC041Dd0C0fdD93D94D95D96Da4Da5Da6Da7Da8Da9C06fD69D9cC0eeD98C045D44D74C001D46C0d5DddC0b3Dc2C0aeD54C00fD2cD2dD7eD8eC012D53C0fbDbaC06fD38D48D49D59D5aD6aD6bD7bC0cfD87DabC027D29C003D9fC0faDb5Db8C04fD5bD7cC0e4DebC0cfD65D66D76D77D78D88D89D9aC05eD4aC061Df4C07fD7aD8bDbdC0feD97C026D3aD47C000D43D63D72D73Da1C08bD64C0afD79D9bC00eDaeC020Df2C0bcDcdC0dfD86D99C00aD1dC002D6fC0f8DccC01fD6cC0d4Dc3C01dD4bC061Dc1DedC065D91C0caD83C0c3DecC0afD8aC013DdeC0fdD92DbbC037D37C004D2bC0fbDb9C04fDadC0f4Dd1De3C06fD39D58C082Df5C0eeDaaC025D27C010DfcC087Da2C00dD5eC010Db2C009D3eC002D5fDafC0f6DcbC051DfaC0baD82C0beD75C041Df3C0fcDa3C01aDceC003D7fD8fC072Df9C0b9D84C00eD6eD9eC031DfbC0ddD85C00bD1cC0faDb6Db7C02fD9dC05dD28C044D81C0eaDb4C0bfD55C034D45C058D57C082Df8"{

	run("Close All");
	dirS = getDirectory("Choose source Directory");
	pattern = ".*"; // for selecting all the files in the folder
	
	
	filenames = getFileList(dirS);
	count = 0;
	
	// Open each file
	for (i = 0; i < filenames.length; i++) {
	//for (i = 0; i < 1; i++) {
		currFile = dirS+filenames[i];
		if(endsWith(currFile, ".czi") && matches(filenames[i], pattern)) { // process czi files matching regex
			//open(currFile);
			run("Bio-Formats Windowless Importer", "open=[" + currFile+"]");
			getPixelSize(unit, pw, ph, pd);
			

			window_title = getTitle();
			getDimensions(width, height, channels, slices, frames);
			run("Split Channels");
			if (channels == 2) {
				selectWindow("C1-"+window_title);
				rename("DAPIStack");
				selectWindow("C2-"+window_title);
				rename("MitoStack");
				
			}
			else{
				selectWindow("C1-"+window_title);
				close();
				selectWindow("C2-"+window_title);
				rename("DAPIStack");
				selectWindow("C3-"+window_title);
				rename("MitoStack");
			}
			selectWindow("DAPIStack");
			waitForUser("Choose DAPI plane to use for alignment, then hit OK"); 
			
			sliceNuclei = getSliceNumber();
			run("Duplicate...", "use");
			rename("DAPI");
			run("Duplicate...", " ");
			run("Gaussian Blur...", "sigma=4");
			setAutoThreshold("Otsu dark");
			//run("Threshold...");
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Set Measurements...", "fit shape display redirect=None decimal=2");
			run("Analyze Particles...", "size=10-Infinity display clear");
			
			CircMin = 1;

			for (object=0; object<nResults; object++){
				
				if (getResult("Circ.", object)< CircMin) {
					angleRotation = getResult("Angle", object);
					CircMin = getResult("Circ.", object);
				}
			}
			
			
			// Work to do here
			selectWindow("MitoStack");
			waitForUser("Choose Mito plane to use for measurement, then hit OK"); 
			
			run("Duplicate...", "use");
			rename("Mito");
			run("Merge Channels...", "c1=Mito c3=DAPI create");
			run("Rotate... ", "angle="+angleRotation+" grid=1 interpolation=Bilinear enlarge");
			title = File.nameWithoutExtension;
			print("Rotating "+title+" by "+angleRotation);
			
			saveAs("Tiff", dirS+title+"_rotated.tif");
			run("Close All");
			selectWindow("Results"); 
         	run("Close" );
		}
	}
}




macro "Segment Button Action Tool - C232Db6Cff4D89Cff7D34C567D85Da3CeebDb5C353D4aCabbD4dC235D55C9aaD81C563D45CbbcDc8C234D25D35D73D93C899D7aD8aDaaC345D4cD84Cc99DdeC900DddCabbD44D46Dc5Dc7Cab0D83CcccDc4C134Da6Dd6C778D98D99D9bC453Dc6CbbbD43D63C345D82C456D3bD5bCbccD2bC456D49CdaaDcdCa22DedC992D4bCccdD47C678D6bC785D9a"{
	run("Close All");
	roiManager("reset");
	print("\\Clear");
	run("Clear Results");
	dirS = getDirectory("Choose source Directory");
	pattern = ".*"; // for selecting all the files in the folder
	run("Set Measurements...", "area mean display redirect=None decimal=2");
	filenames = getFileList(dirS);
	count = 0;

	// Open each file
	//for (i = 0; i < 1; i++) {
	for (i = 0; i < filenames.length; i++) {
		currFile = dirS+filenames[i];
		if(endsWith(currFile, ".tif") && matches(filenames[i], pattern)) { // process czi files matching regex
			
			
			run("Bio-Formats Windowless Importer", "open=[" + currFile+"]");
			title = File.nameWithoutExtension;
			rename("Raw");
			run("Duplicate...", "duplicate channels=1");
			rename("Mito");
			run("Gaussian Blur...", "sigma=4");
			//run("Find Maxima...", "prominence=200 exclude light output=[Segmented Particles]");
			run("Find Maxima...", "prominence=200 light output=[Segmented Particles]");

			run("Create Selection");
			roiManager("Add");
			selectWindow("Raw");
			roiManager("Select", count);
			run("Measure");
			selectWindow("Mito Segmented");
			rename("Maxima");
			run("Duplicate...", " ");
			run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
			run("glasbey on dark");
			saveAs("PNG", dirS+title+"_contour_colored.png");
			run("Analyze Regions", "area oriented_box oriented_box_elong.");
			saveAs("Results", dirS+title+"_-Morphometry.csv");
			run("Close");
			selectWindow("Maxima");
			saveAs("Tiff", dirS+title+"_contour.tif");
			
			run("Close All");
			
			
			count = count+1;
		}
	}
	selectWindow("Results");
	saveAs("Results", dirS+"Overall_Intensity.csv");
}

macro "Merge CSV Button Action Tool - C073D68D77D78C042D0aC274D3aC000D13D23D3dC184D15D16D27D44D54D64D74C153D5dD6dD7dD8dD9cD9dDacDadDbcDbdDccDcdDdcDddDecDedC3b7Db1Dc1Dd1De1C000D3eD4fD5fD6fD7fD8fD9fDafDbfDcfDdfDefC174D69C153D4dD5eD6eD7eD88D8cD8eD9eDaeDbeDceDdeDeeC2a6D93C031D0bC195D42C063D4bD87C396D26D55C174D19D1aD67D75D76D84D97Da8Da9DaaDb9DbaDc9DcaDd9DdaDe9DeaC052D05Df8C2a6D52D62D72D82Db5Db6Dc5Dc6Dd5Dd6De5De6C021D90C184D28D45D65D66C3c8Db2Db3Dc2Dc3Dd2Dd3De2De3C184D17D18D95D96Db8Dc8Dd8De8C053D5bC2b7Da1Db4Dc4Dd4De4C142D4cC196D51D53D61D63D71D73D81Da5Da6Db7Dc7Dd7De7C063D85C8baD37C164Df1Df4C142D8bC285D25C011D32D40C3c7Da2Da3C2a6D92Da4C042DfbC195Da7C163D98D99D9aDf7C496D29D57C052D1bD2bD3bD6bD7bC021Da0Db0Dc0Dd0De0DfeC185D41C153D9bC142D4eD5cD6cD7cC164Df5Df6C9caD59C173D4aD6aC042D06D07D08D09Df9DfaC275Df2Df3C010D31D3cDf0C032D04DfcDfdC063D79D7aD86C496D49C152D89D8aC163DabDbbDcbDdbDebC9caD39D56C174D14D24D34C296D83D91C021D33D50D60D70D80C5a7D58C195D94CcdcD48C284D2aD5aC9caD38C396D35CadbD36C5a8D46C185D43CcedD47"{
	run("Close All");
	roiManager("reset");
	print("\\Clear");
	run("Clear Results");
	dirS = getDirectory("Choose source Directory");
	pattern = ".*"; // for selecting all the files in the folder
	run("Set Measurements...", "area mean display redirect=None decimal=2");
	filenames = getFileList(dirS);
	count = 0;
	
	// Open each file
	//for (i = 0; i < 1; i++) {
	for (i = 0; i < filenames.length; i++) {
		currFile = dirS+filenames[i];
		
		if(endsWith(currFile, ".csv") && matches(filenames[i], pattern) && endsWith(currFile, "Intensity.csv")==0) { // process czi files matching regex
			open(currFile);
			
			tableTitle = Table.title;
			Table.rename(tableTitle, "Results"); //can only get text from this table if it is a Results table
			headings = Table.headings;
			headingsArray = split(headings, "\t");
			if (isOpen("Analysis")==false) {
				Table.create("Analysis");
			}
			selectWindow("Analysis");
			size = Table.size;
			for (line = 0; line < nResults; line++) {
				for (row=0; row<headingsArray.length; row++){
					//selectWindow(""+tableTitle);
					//data = Table.get(headingsArray[i], 0);
					data = getResultString(headingsArray[row], line);
					selectWindow("Analysis");
					Table.set(headingsArray[row], size+line, data);
					//Table.update;
					print("File "+i+"Line "+line+"out of "+nResults);
				}
			}
			Table.update;
			
		}
	}
	selectWindow("Analysis");
	saveAs("Results", dirS+"Overall_Morphometry.csv");
}
			


