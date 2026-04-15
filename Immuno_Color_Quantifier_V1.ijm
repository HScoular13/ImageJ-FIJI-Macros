macro "Immuno Color Quantifier" {
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
		File.open(im_dir+im_list[im]);
		im_width = Image.width;
		half_width = im_width / 2;
		
	}
}
