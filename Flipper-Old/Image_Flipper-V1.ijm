macro "Image_Flipper" {
	im_dir = getDir("Choose Processed Image Directory");
	print(im_dir);
	im_list = getFileList(im_dir);
	num_ims = lengthOf(im_list);
	binary_flip = newArray(num_ims);
	
	for (i=0; i<num_ims; i++) {
		open(im_dir + im_list[i]);
		binary_flip[i] = getBoolean("Flip Image?");
		close("*");
	}
	
	for (i=0; i<(num_ims); i++) {
		if (binary_flip[i]) {
			open(im_dir + im_list[i]);
			run("Flip Vertically");
			save(im_dir + im_list[i]);
			close("*");
		}
	}
}
