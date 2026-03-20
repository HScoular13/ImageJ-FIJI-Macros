macro "Super_Image_Stacker-V4" {
	orig_dir = File.getDefaultDir;
	im_dir = getDir("Choose a Directory");
	File.setDefaultDir(im_dir);
	im_list = getFileList(im_dir);
	print(im_list[0]);
	num_ims = lengthOf(im_list);
	
	im_tags = newArray(
			"2h Post-Burn", "1d Post-Burn", "4d Post-Burn",
			"8d Post-Burn", "15d Post-Burn", "22d Post-Burn"
		);
		
	add_labels = getBoolean("Add Labels to Images?");
	labels_correct = false;
	if (add_labels) {
		labels_correct = getBoolean("Are these labels correct: 2h Post-Burn, "+
		"1d Post-Burn, 4d Post-Burn, 8d Post-Burn, 15d Post-Burn, 22d Post-Burn");
	}
		
	if (!labels_correct) {
		for (i=0; i<lengthOf(im_tags); i++) {
			Dialog.create("Correct the Label");
			Dialog.addString("Label "+(i+1), im_tags[i]);
			Dialog.show();
			im_tags[i] = Dialog.getString();
		}
	Array.print(im_tags);
	}
	
	image_heights = newArray(num_ims);
	image_widths = newArray(num_ims);
//	burn_center_x = newArray(num_ims);
	burn_center_x = newArray(10528, 7664, 9104, 7968, 9360, 10064);
//	burn_center_y = newArray(num_ims);
	
	for (im=0; im<num_ims; im++) {
		open(im_dir+im_list[im]);
		orig = getTitle();
		
		im_height = Image.height;
		image_heights[im] = im_height;
		im_width = Image.width;
		image_widths[im] = im_width;
//		
//		waitForUser("Click the center of the burn, then click OK");
//		getCursorLoc(point_x, point_y, z, modifiers);
//		burn_center_x[im] = point_x;
//		burn_center_y[im] = point_y;
//		Array.print(burn_center_x);
		close("*");
	}
	
	right_diffs = newArray(num_ims);
	
	for (i=0; i<lengthOf(image_widths); i++) {
		right_diffs[i] = image_widths[i] - burn_center_x[i];
	}
	
	Array.print(right_diffs);
	
	Array.getStatistics(right_diffs, min, max, mean, stdDev);
	min_right_diff = min;
	print("Min. right diff: "+min_right_diff);
	Array.getStatistics(burn_center_x, min, max, mean, stdDev);
	min_left_diff = min;
	print("Min. left diff: "+min_left_diff);
	
	if (min_left_diff < min_right_diff) {
		min_width = 2 * min_left_diff;
	}
	else {
		min_width = 2 * min_right_diff;
	}
	
//	min_width = min_left_diff + min_right_diff;
	print("Min width: "+min_width);
	
	
	height_sum = 0;
	for (h=0; h<num_ims; h++) {
		height_sum += image_heights[h];
	}

	Array.getStatistics(image_widths, min, max, mean, stdDev);
	max_width = max;
//	min_width = min;
	print(max_width);
	
	height_sums = 0;
	y_positions = newArray(num_ims);
	y_positions[0] = 0;
	for (y=1; y<num_ims; y++) {
		height_sums += image_heights[y-1];
		y_positions[y] = height_sums;
	}
	
	run("Image...", "name="+im_dir+"_stack RGB white width=min_width height=height_sum");
	stack = getTitle();
	
	crop_x_pos = newArray(num_ims);
	for (im=0; im<num_ims; im++) {
		crop_x_pos[im] = burn_center_x[im] - min_left_diff;
	}
	
	for (im=0; im<num_ims; im++) {
		open(im_dir+im_list[im]);
		current_im = getTitle();
		x_rect = crop_x_pos[im];
		y_pos = y_positions[im];
		makeRectangle(x_rect, 0, min_width, Image.height);
		run("Crop");
		
		if (add_labels) {
			setColor("white");
			setJustification("left");
			setFont("Monospaced", 250, "non-antialiased bold");
			stringW = getStringWidth(im_tags[im]);
			print(stringW);
//			text_x = (Image.width / 2) - (stringW / 2);
//			print(text_x);
			stringH = getValue("font.height");
			text_y = stringH;
			drawString(im_tags[im], 0, text_y, "black");
//			save(label_dir+File.separator+orig);
		}
		
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
	stringH = getValue("font.height");
	
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
	
	save(im_dir+File.separator+"stacked.jpg");
	File.setDefaultDir(orig_dir);
	close("*");
	exit("Saved new image");
}
