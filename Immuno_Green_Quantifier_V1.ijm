macro "Immuno Color Quantifier V2" {
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

	print(im_list[0]);
	num_ims = lengthOf(im_list);
	
	for (im=0; im<num_ims; im++) {
		run("Collect Garbage");
		run("Collect Garbage");
		open(im_dir+im_list[im]);
//		run("Set Scale...", "distance=1760 known=1 pixel=1 unit=mm");
		orig_im_name = getTitle();
		
		file_name_split = split(orig_im_name, ".");
		file_name_noex = file_name_split[0];
		im_output = File.open(im_dir+file_name_noex+".csv");
		
		im_width = Image.width;
		im_height = Image.height;
		half_width = im_width / 2;
		
		Dialog.create("Tissue Type");
		Dialog.addCheckbox("Is this a burn tissue?", false);
		Dialog.show();
		burn_tissue = Dialog.getCheckbox();
		
		if (burn_tissue) {
			setTool("rectangle");
			waitForUser("Define the burned area of the tissue,/nthen click OK to continue./nThe rectangle tool has been selected for you.");
			getSelectionBounds(burn_x, burn_y, burn_w, burn_h);
		}
		
		run("Split Channels");
		
		close(orig_im_name+" (red)");
		close(orig_im_name+" (blue)");
		
		colors = newArray(" (green)");
		for (channel=0; channel<1; channel++) {
			selectWindow(orig_im_name+colors[channel]);
			color_im_name = getTitle();
			
//			run("16-bit");
			run("Duplicate...", "title=thresh");
			im_copy = getTitle();
			run("Auto Threshold", "method=MinError(I) ignore_black white");
			run("Fill Holes");
			run("Set Measurements...", "area mean integrated limit redirect=["+color_im_name+"] decimal=3");
			std_lowbound_size = 1000000;
			run("Analyze Particles...", "size="+std_lowbound_size+"-Infinity display clear add");
			
			while (nResults() < 1) {
				std_lowbound_size -= 10000;
				print("Reducing Size to "+std_lowbound_size);
				run("Analyze Particles...", "size="+std_lowbound_size+"-Infinity display clear add");
			}
			
			if (burn_tissue) {
				Dialog.create("Sections");
				Dialog.addMessage("The image will be divided into 3 main sections:/nleft, burn, and right");
				Dialog.addSlider("If more than 3 sections desired, how many total sections do you want?", 3, 1000, 3);
				Dialog.show();
				sections = Dialog.getNumber();
			}
			else {
				Dialog.create("Sections");
				Dialog.addMessage("The image will be divided into 3 sections:/nleft, center, and right");
				Dialog.addSlider("If more than 3 sections desired, how many total sections do you want?", 3, 1000, 3);
				Dialog.show();
				sections = Dialog.getNumber();
			}
			
			if (burn_tissue) {
				outside_w = (Image.width - burn_w) / 2;
			}
			else {
				outside_w = Image.width / 3;
			}
			
			
			
			roiManager("Select", newArray(0, 1));
			roiManager("Select", 1);
			roiManager("Select", 0);
//			run("Clear Outside");
//			run("Select None");
//			roiManager("delete");
			
//			imageCalculator("Multiply create", color_im_name, im_copy);
//			selectWindow("Result of "+color_im_name);

			result_w = Image.width;
			result_h = Image.height;
			
			selectWindow("Results");
			IJ.deleteRows(0, nResults());
			
			selectWindow(im_copy);
//			run("Set Scale...", "distance=1760 known=1 pixel=1 unit=mm");
			mm_w = Image.width / 1760;
			extra_mms = mm_w%1;
			num_mms = (mm_w - extra_mms)*2;
			print(num_mms);
			run("Set Measurements...", "area area_fraction mean integrated limit redirect=["+color_im_name+"] decimal=3");
			
			out_width = extra_mms / 2;
			x_mes = newArray(num_mms);
			x_mes[0] = out_width;
			for (i=1; i<num_mms; i++) {
				x_mes[i] = x_mes[i-1] + 880;
			}
			
			for (i=0; i<num_mms; i++) {
				makeRectangle(x_mes[i], 0, 880, result_h);
				run("Measure");
			}

			result_names = newArray("Green");
			print(im_output, result_names[channel]);
			print(im_output, "Position (mm), Measurement Area (mm^2), Area Fraction (%), Adjusted Area (mm^2), Mean Gray Value, RawIntDen, IntDen");
			for (i=0; i<num_mms; i++) {
				print("Area "+getResult("Area", i));
				print("%Area"+(getResult("%Area", i) / 100));
				adjusted_area = (getResult("%Area", i) / 100) * getResult("Area", i);
				print(adjusted_area);
				print(im_output, d2s(i+1, 0)+", "+getResult("Area", i)+", "+getResult("%Area", i)+", "+adjusted_area+", "+(getResult("IntDen", i) / adjusted_area)+", "+getResult("RawIntDen", i)+", "+getResult("IntDen", i));
			}
			
		}
		
		close("*");
		File.close(im_output);
		run("Collect Garbage");
		run("Collect Garbage");
	}
}
