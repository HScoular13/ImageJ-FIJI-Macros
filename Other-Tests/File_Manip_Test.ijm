macro "Test" {
	orig_dir = File.getDefaultDir;
	print(orig_dir);
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
	print(main_dir);
	im_dir = getDir("Choose Folder Containing Images to be Processed");
	File.setDefaultDir(im_dir);
	print(im_dir);
	test_main_dir = File.getParent(im_dir) + File.separator;
	print(test_main_dir);
	file_list = getFileList(im_dir);
	Array.print(file_list);
	temp_dir = im_dir + "temp_ims" + File.separator;
	
	run("Image...", "name="+im_dir+"_stack RGB white width=1000 height=500");
	test_im = getTitle();
	print(test_im);
	
	if (!File.exists(temp_dir)) {
	    File.makeDirectory(temp_dir);
	}
	print(temp_dir);
	
	test_dir = temp_dir;
	function deleteDirectory(dir) {
		del_list = getFileList(dir);
		for (i=0; i<del_list.length; i++) {
			File.delete(dir + del_list[i]);
		}
		File.delete(dir);
	}
	deleteDirectory(test_dir);
}
