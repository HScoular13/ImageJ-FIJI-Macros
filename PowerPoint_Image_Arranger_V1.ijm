macro "PowerPoint Image Maker" {
	run("Collect Garbage");
	run("Collect Garbage");
	Dialog.create("Message");
	Dialog.addMessage("This macro will only work for 8 or fewer images");
	Dialog.show();
	
	function deleteDirectory(dir) {
		del_list = getFileList(dir);
		for (i=0; i<del_list.length; i++) {
			File.delete(dir + del_list[i]);
		}
		File.delete(dir);
	}
	
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
		print(def_dir);
	}
	
	main_dir = getDir("Choose Main Directory Containing the Image Folder");
	im_dir = getDir("Choose Folder Containing Images to be Processed");
	file_list = getFileList(im_dir);
	ims_in_dir = 0;
	
	for (i=0; i<file_list.length; i++) {
		if (endsWith(file_list[i], ".jpg")) {
			ims_in_dir += 1;
		}
	}
	
	im_list = newArray(ims_in_dir);
	im_index = 0;
	for (i=0; i<file_list.length; i++) {
		if (endsWith(file_list[i], ".jpg")) {
			im_list[im_index] = file_list[i];
			im_index += 1;
		}
		else {
			continue;
		}
	}

	print(im_list[0]);
	num_ims = lengthOf(im_list);
	
	function arrange_grid(im_count) {
		Dialog.create("Image Layout")
		Dialog.addMessage("Number of Images in Folder: "+im_count);
		Dialog.addMessage("How many rows?");
		Dialog.addSlider("Rows", 1, 2, 1);
		Dialog.addMessage("How many images in each row?");
		Dialog.addMessage("(If only using 1 row, leave [Images in Row 2] set to 0.)");
		Dialog.addSlider("Images in Row 1", 1, im_count, 1);
		Dialog.addSlider("Images in Row 2", 0, im_count, 0);
		Dialog.show();
		
		g_rows = Dialog.getNumber();
		r1_ims = Dialog.getNumber();
		r2_ims = Dialog.getNumber();
		
		return newArray(g_rows, r1_ims, r2_ims);
	}
	
	if (num_ims > 3) {
		grid = arrange_grid(num_ims);
		grid_rows = grid[0];
		row1_ims = grid[1];
		row2_ims = grid[2];
	
		if ((row1_ims+row2_ims) != num_ims) {
			Dialog.create("Warning");
			Dialog.addMessage(
				"Inputted number of images does not match number of images in folder."
				)
			Dialog.addMessage(
				"Try again?"
				)
			Dialog.show();
			
			grid = arrange_grid(num_ims);
			grid_rows = grid[0];
			row1_ims = grid[1];
			row2_ims = grid[2];
			
			if ((row1_ims+row2_ims) != num_ims) {
				Dialog.create("Warning");
				Dialog.addMessage(
					"Inputted number of images still does not match number of images in folder."
					)
				Dialog.addMessage("The macro will now exit. Feel free to try again.")
				Dialog.show();
				exit();
			}
		}
	}
	else {
		grid_rows = 1;
		row1_ims = num_ims;
		row2_ims = 0;
	}
	print(grid_rows, row1_ims, row2_ims);
	
//	pp_width_in = 13.333; // Inches
//	pp_height_in = 7.5; // Inches
//	pp_scale = 129.1532; // Pixels per Inch
//	pp_width = pp_width_in * pp_scale;
//	pp_height = pp_height_in * pp_scale;
//	pp_width = 1722; // Pixels
//	pp_width = 1920; // Also Pixels
//	pp_height = 970; // Pixels
//	pp_height = 1080 // Also Pixels

	pp_width = 1280; // Pixels
	pp_height = 720; // Pixels


	print(pp_width, pp_height);
	newImage("pp_test", "RGB black", pp_width, pp_height, 1);
	test_dir = getDir("Desktop");
	save(test_dir+"pp_test2");
	
	run("Set Scale...", "distance=1722 known=13.333 unit=inch");
}
