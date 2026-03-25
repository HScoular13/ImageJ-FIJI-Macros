macro "PowerPoint Image Maker" {
	run("Collect Garbage");
	run("Collect Garbage");
	Dialog.create("Message");
	Dialog.addMessage("This macro will only work for 8 or fewer images");
	Dialog.addMessage("The current version of this macro also assumes that/nall images are the same size.");
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
	
//	main_dir = getDir("Choose Main Directory Containing the Image Folder");
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
	
	Dialog.create("Name Image");
	Dialog.addString("Input filename for new image:", "filename");
	Dialog.show();
	filename = Dialog.getString();
	
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
	
//	im_widths = newArray(num_ims);
//	im_heights = newArray(num_ims);
//	for (im=0; im<num_ims; im++) {
//		open(im_dir+im_list[im]);
//		im_widths[im] = Image.width;
//		im_heights[im] = Image.height;
//		close();
//	}

	open(im_dir+im_list[0]);
	im_width = Image.width;
	im_height = Image.height;
	close();
	
	equal_heights = true;
	equal_widths = false;
	if ((grid_rows > 1)&((num_ims%2)==1) {
		Dialog.create("Arrangement Choice");
		Dialog.addMessage("Make the height of all images the same/nor/nmake the total widths of each row the same?");
		Dialog.addChoice("Options:", newArray("Equal Heights", "Equal Widths"));
		Dialog.show();
		choice = Dialog.getChoice();
		if (choice == "Equal Widths") {
			equal_heights = false;
			equal_widths = true;
		}
	}


//	pp_width_in = 13.333; // Inches
//	pp_height_in = 7.5; // Inches
//	pp_scale = 129.1532; // Pixels per Inch
//	pp_width = pp_width_in * pp_scale;
//	pp_height = pp_height_in * pp_scale;
//	pp_width = 1722; // Pixels
//	pp_width = 1920; // Also Pixels
//	pp_height = 970; // Pixels
//	pp_height = 1080 // Also Pixels
//	run("Set Scale...", "distance=1722 known=13.333 unit=inch");

	Dialog.create("Image Title");
	Dialog.addCheckbox("Do you want the image to have a title?", false);
	Dialog.addString("If yes, input title. If no, ignore.", "Image Title");
	Dialog.show();
	add_title = Dialog.getCheckbox();
	im_title = Dialog.getString();
	
	Dialog.create("Image Color");
	Dialog.addChoice("Choose Background Color for Image:", newArray("white", "black");
	Dialog.show();
	back_color = Dialog.getChoice();
	
	if (add_title) {
		if (back_color=="white") {
			setColor("black");
		}
		else {
			setColor("white");
		}

		setJustification("center");
		setFont("Monospaced", 250, "non-antialiased bold");
		stringW = getStringWidth(im_title);
		print(stringW);
		stringH = getValue("font.height");
		title_y = stringH;
		drawString(im_title, title_x, title_y);
	}

	pp_width = 1280; // Pixels
	pp_height = 720; // Pixels

	newImage(filename, "RGB"+back_color, pp_width, pp_height, 1);
	
	save(im_dir+filename);
	
	
}
