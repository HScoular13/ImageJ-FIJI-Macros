macro "Image_Stacker" {
	orig_dir = File.getDefaultDir;
	im_dir = getDir("Choose a Directory");
	File.setDefaultDir(im_dir);
	im_list = getFileList(im_dir);
	print(im_list[0]);
	num_ims = lengthOf(im_list);
	
	image_heights = newArray(num_ims);
	image_widths = newArray(num_ims);
	
	for (im=0; im<num_ims; im++) {
		open(im_list[im]);
		orig = getTitle();
		im_height = Image.height;
		image_heights[im] = im_height;
		im_width = Image.width;
		image_widths[im] = im_width;
		close("*");
		
	}
	
	height_sum = 0;
	for (h=0; h<num_ims; h++) {
		height_sum += image_heights[h];
	}

	Array.getStatistics(image_widths, min, max, mean, stdDev);
	max_width = max;
	print(max_width);
	
	height_sums = 0;
	y_positions = newArray(num_ims);
	y_positions[0] = 0;
	for (y=1; y<num_ims; y++) {
		height_sums += image_heights[y-1];
		y_positions[y] = height_sums;
	}
	
	run("Image...", "name="+im_dir+"_stack RGB white width=max_width height=height_sum");
	stack = getTitle()
	for (im=0; im<num_ims; im++) {
		open(im_list[im]);
		current_im = getTitle();
		x_pos = (max_width - Image.width) / 2;
		y_pos = y_positions[im];
		Image.copy;
		close(current_im);
		selectWindow(stack);
		Image.paste(x_pos, y_pos);
	}
	save(im_dir);
	File.setDefaultDir(orig_dir);
	close("*");
	exit("Saved new image");
}