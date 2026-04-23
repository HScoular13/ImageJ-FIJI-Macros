macro "Immuno_Color_Quantifier_V3" {
	run("Collect Garbage");
	run("Collect Garbage");
	orig_dir = File.getDefaultDir;
	
	change_default_dir = getBoolean(
		"Would you like to change the default directory for easier "+
		"access to working files? This will only persist until FIJI is closed."
		);
		
	if (change_default_dir) {
		def_dir = getDir("Choose a new default directory");
		File.setDefaultDir(def_dir);
		print(def_dir);
	}
	else {
		def_dir = orig_dir;
	}
	
	main_dir = getDir("Choose Main Directory Containing the Image Folder");
	File.setDefaultDir(main_dir);
	im_dir = getDir("Choose Folder Containing Images to be Processed");
	if (change_default_dir) {
		File.setDefaultDir(def_dir);
	}
	else {
		File.setDefaultDir(orig_dir);
	}
	
	file_list = getFileList(im_dir);
	ims_in_dir = 0;
	
	for (i=0; i<file_list.length; i++) {
		if (endsWith(file_list[i], ".jpg")|endsWith(file_list[i], ".tif")) {
			ims_in_dir += 1;
		}
		else {
			continue;
		}
	}
	
	im_list = newArray(ims_in_dir);
	im_index = 0;
	for (i=0; i<file_list.length; i++) {
		if (endsWith(file_list[i], ".jpg")|endsWith(file_list[i], ".tif")) {
			im_list[im_index] = file_list[i];
			im_index += 1;
		}
		else {
			continue;
		}
	}
	
	Dialog.create("Plan");
	Dialog.addChoice("Which staining plan is this?", newArray("Plan 1", "Plan 2", "Plan 3"));
	Dialog.show();
	stain_plan = Dialog.getChoice();

	print(im_list[0]);
	num_ims = lengthOf(im_list);
	roi_output_names = newArray(num_ims);
	data_output_names = newArray(num_ims);
	
	for (im=0; im<num_ims; im++) {
		run("Collect Garbage");
		run("Collect Garbage");
		open(im_dir+im_list[im]);
		orig_im_name = getTitle();
		
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		
		file_name_split = split(orig_im_name, ".");
		file_name_noex = file_name_split[0];
		roi_output_name = file_name_noex+"_ROI.roi";
		roi_output_names[im] = roi_output_name;
		data_output_name = im_dir+file_name_noex+".csv";
		data_output_names[im] = data_output_name;
		
		run("Duplicate...", "title=copy");
		copy_im_name = getTitle();
		
		run("8-bit");
		setThreshold(1, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask");
//		run("Auto Threshold", "method=MinError(I) ignore_black white");
		
//		run("Dilate");
		run("Fill Holes");
		run("Set Measurements...", "area decimal=3");
		
		im_area = Image.width * Image.height;
		std_lowbound_size = 0.1 * im_area;
		delta_size = 0.01 * im_area;
		
		run("Analyze Particles...", "size="+std_lowbound_size+"-Infinity display clear add");
		
		loop_stopper = 0;
		while (nResults() != 1) {
			if (nResults() < 1) {
				std_lowbound_size -= delta_size;
				print("Reducing size to "+std_lowbound_size);
			}
			else {
				std_lowbound_size += delta_size;
				print("Increasing size to "+std_lowbound_size);
			}
			run("Analyze Particles...", "size="+std_lowbound_size+"-Infinity display clear add");
			loop_stopper += 1;
			if (loop_stopper > 99) {
				break;
			}
		}
		
		selectWindow("ROI Manager");
		roiManager("Select", 0);
		roiManager("Rename", roi_output_name);
		roiManager("Select", 0);
		roiManager("Save", im_dir+roi_output_name);
		roiManager("Select", 0);
		roiManager("Delete");
		close("*");
		
		selectWindow("Results");
		IJ.deleteRows(0, nResults());
	}
	
	Dialog.create("Tissue Type");
	Dialog.addCheckbox("Check box if these are burn tissues\nThen click OK", false);
	Dialog.show();
	burn_tissue = Dialog.getCheckbox();
	
	if (burn_tissue) {
		Dialog.create("Sections");
		Dialog.addMessage("The images will be divided into 3 sections for data labeling:/nleft, burn, and right");
		Dialog.addSlider("How many data points per image do you want?", 3, 1000, 3);
		Dialog.show();
		sections = Dialog.getNumber();
	}
	else {
		Dialog.create("Sections");
		Dialog.addMessage("The images will be divided into 3 sections for data labeling:/nleft, center, and right");
		Dialog.addSlider("How many data points per image do you want?", 3, 1000, 3);
		Dialog.show();
		sections = Dialog.getNumber();
	}
	
	for (im=0; im<num_ims; im++) {
		run("Collect Garbage");
		run("Collect Garbage");
		open(im_dir+im_list[im]);
		orig_im_name = getTitle();
//		burn_tissue = true;
		if (burn_tissue) {
			setTool("rectangle");
			waitForUser("Define the burned area of the tissue, then click OK to continue.\nThe rectangle tool has been selected for you.");
			getSelectionBounds(burn_x, burn_y, burn_w, burn_h);
		}
		run("Select None");
		
		if (burn_tissue) {
			rect1 = newArray(0, 0, burn_x-1, Image.height);
			rect2 = newArray(burn_x, 0, burn_w, Image.height);
			rect3 = newArray(burn_x+burn_w+1, 0, (Image.width-(burn_x+burn_w)), Image.height);
		}
		else {
			rect1 = newArray(0, 0, Image.width/3, Image.height);
			rect2 = newArray((Image.width/3)+1, 0, Image.width/3, Image.height);
			rect3 = newArray(((2*Image.width)/3)+1, 0, Image.width/3, Image.height);
		}
		
		run("Duplicate...", "title=copy");
		
//		I will make this more robust later but gonna start with just the collagen images so green and blue
		
		copy_im_name = getTitle();
		run("Split Channels");
		
		selectWindow(copy_im_name+" (green)");
		run("ROI Manager...");
		roiManager("Open", im_dir+roi_output_names[im]);
		roiManager("Select", 0);
		
		section_width = (Image.width - (Image.width % sections)) / sections;
		extra_width = (Image.width % sections) / 2;
		section_xs = newArray(sections);
		section_xs[0] = extra_width;
		for (i=1; i<sections; i++) {
			section_xs[i] = section_xs[i-1] + section_width;
		}
		
		run("Set Measurements...", "area mean modal integrated area_fraction redirect=None decimal=3");
		
		for (i=0; i<sections; i++) {
			makeRectangle(section_xs[i], 0, section_width, Image.height);
			roiManager("Add");
			roiManager("Select", newArray(0, 1));
			roiManager("AND");
			roiManager("Add");
			roiManager("Select", 2);
			roiManager("Measure");
			roiManager("Select", newArray(1, 2));
			roiManager("Delete");
		}
		
		im_output = File.open(data_output_names[im]);
		print(im_output, "X-Position (pix), Measurement Area (pix^2), Area Percent, Mean Gray Value, IntDen");
		for (i=0; i<sections; i++) {
			print(im_output, section_xs[i]+", "+getResult("Area", i)+", "+getResult("%Area", i)+", "+getResult("Mean", i)+", "+getResult("IntDen", i));
		}
		
		File.close(im_output);
		close("*");
	
//Duplicate Image
//Split Channels or do whatever to seperate colors
//Open the saved roi file
//Use rectangles and the "AND" function in ROI manager to subdivide
//Set measurements and measure each subdivision
//Save to csv output file
	}
	
	run("Collect Garbage");
	run("Collect Garbage");
	exit("Test Finished");
}
