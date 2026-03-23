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
	min_width = min;
	print(max_width);
	
	height_sums = 0;
	y_positions = newArray(num_ims);
	y_positions[0] = 0;
	for (y=1; y<num_ims; y++) {
		height_sums += image_heights[y-1];
		y_positions[y] = height_sums;
	}
	
	run("Image...", "name="+im_dir+"_stack RGB white width=min_width height=height_sum");
	stack = getTitle()
	for (im=0; im<num_ims; im++) {
		open(im_list[im]);
		current_im = getTitle();
		x_rect = (Image.width - min_width) / 2;
		y_pos = y_positions[im];
		makeRectangle(x_rect, 0, min_width, Image.height);
		run("Crop");
		Image.copy;
		close(current_im);
		selectWindow(stack);
		Image.paste(0, y_pos);
	}
	
	setColor("white");
	setJustification("left");
	setFont("Monospaced", 250, "non-antialiased bold");
	stringW = getStringWidth("2.5 mm");
	print(stringW);
	text_x = (min_width / 2) - (stringW / 2);
//	print(text_x);
	stringH = getValue("font.height");
//	text_y = stringH + 10;
//	drawString(im_tags[im], text_x, text_y, "black");
	
	padding = 100;
	bar_height = 150;
	bar_width = 5750;
	half_bar = bar_width / 2;
	half_width = min_width / 2;
	bar_x = half_width - half_bar;
	
	extra_height = height_sum + stringH + bar_height + (3 * padding);
	run("Canvas Size...", "width=min_width height=extra_height position=Top-Center zero");
	
	bar_y = Image.height - (padding + bar_height);
	setColor(255, 255, 255);
	fillRect(bar_x, bar_y, bar_width, bar_height);
	
	text_y = Image.height - (bar_height + (2 * padding));
	drawString("2.5 mm", text_x, text_y, "black");
	
	save(im_dir);
	File.setDefaultDir(orig_dir);
	close("*");
	exit("Saved new image");
}