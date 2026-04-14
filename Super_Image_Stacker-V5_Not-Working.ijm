macro "Image Stacker + User Input" {
	main_dir = getDir("Select Folder Containing Folder with Processed Images");
	im_dir = getDir("Select Folder with Processed Images");
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
	burn_center_x = newArray(num_ims);
	tissue_top_y = newArray(num_ims);
	control_ims = false;
	control_ims = getBoolean("Are these Control Tissues?");
	
	if (!control_ims) {
//			Dialog.create("Selection Option");
//			Dialog.add
		for (im=0; im<num_ims; im++) {
			open(im_dir + im_list[im]);
			orig = getTitle();
			
			im_height = Image.height;
			image_heights[im] = im_height;
			im_width = Image.width;
			image_widths[im] = im_width;
			
			
//				waitForUser("Click the left side of the burn, then click OK");
//				getCursorLoc(left_point_x, y, z, modifiers);
//				waitForUser("Click the right side of the burn, then click OK");
//				getCursorLoc(right_point_x, y, z, modifiers);
//				burn_center_x[im] = (left_point_x + right_point_x) / 2;
			waitForUser("Click the middle of the ROI");
			getCursorLoc(center_point, y, z, modifiers);
			burn_center_x[im] = center_point;
//				waitForUser("Click the upper-most point of the tissue");
//				getCursorLoc(x, tissue_top, z, modifiers);
//				tissue_top_y[im] = tissue_top;
	//		burn_center_y[im] = point_y;
			Array.print(burn_center_x);
//				Array.print(tissue_top_y);
	//		Array.print(burn_center_y);
			
			close("*");
			
		}
		
		right_diffs = newArray(num_ims);
		
		for (i=0; i<lengthOf(image_widths); i++) {
			right_diffs[i] = image_widths[i] - burn_center_x[i];
		}
		
		Array.getStatistics(right_diffs, min, max, mean, stdDev);
		min_right_diff = min;
		Array.getStatistics(burn_center_x, min, max, mean, stdDev);
		min_left_diff = min;
		
		if (min_left_diff < min_right_diff) {
			min_width = 2 * min_left_diff;
		}
		else {
			min_width = 2 * min_right_diff;
		}
		print(min_width);
	}
	else {
		for (im=0; im<num_ims; im++) {
			open(im_dir + im_list[im]);
			orig = getTitle();
			
			im_height = Image.height;
			image_heights[im] = im_height;
			im_width = Image.width;
			image_widths[im] = im_width;
			
			close("*");
		}
		Array.getStatistics(image_widths, min, max, mean, stdDev);
		max_width = max;
		min_width = min;
		print(max_width);
	}
	
	height_sum = 0;
	for (h=0; h<num_ims; h++) {
		height_sum += image_heights[h];
	}
	
	height_sums = 0;
	y_positions = newArray(num_ims);
	y_positions[0] = 0;
	for (y=1; y<num_ims; y++) {
		height_sums += image_heights[y-1];
		y_positions[y] = height_sums;
	}
	
	stack_width = 11000;
	if (min_width < stack_width) {
		stack_width = min_width;
	}
	else {
		stack_width = stack_width;
	}
	run("Image...", "name="+im_dir+"_stack RGB white width=stack_width height=height_sum");
	stack = getTitle();
	
	crop_xs = newArray(num_ims);
	crop_ys = newArray(num_ims);
	crop_Hs = newArray(num_ims);
	crop_Ws = newArray(num_ims);
	orig_names = newArray(num_ims);
	
	for (im=0; im<num_ims; im++) {
		open(im_dir + im_list[im]);
		current_im = getTitle();
		
		if (control_ims) {
			x_rect = (image_widths[im] / 2) - (stack_width / 2);
		}
		else {
			x_rect = burn_center_x[im] - (stack_width / 2);
		}

		y_pos = y_positions[im];
		makeRectangle(x_rect, 0, stack_width, Image.height);
		run("Crop");
		orig = getTitle();
		orig_names[im] = orig;
		origW = getWidth();
		origH = getHeight();
		
		run("Duplicate...", "title=thresh");
		
		newW = origW*0.25;
		newH = origH*0.25;
		run("Select None");
		run("Size...", "width=newW height=newH average=true interpolation=Bilinear");
		
		run("8-bit");
		run("Auto Threshold", "method=Otsu ignore_black black");
		setThreshold(128, 255);
		run("Convert to Mask");
		run("Fill Holes");
		
		run("Set Measurements...", "bounding redirect=None decimal=3");
		run("Analyze Particles...", "size=5000-Infinity pixel display clear");
		
		
		
		mult_pieces = false;
		if (nResults() > 1) {
//				if ((maxOf(getResult("Width", 0),getResult("Width", 1))/minOf(getResult("Width", 0),getResult("Width", 1)))<8) {
//					mult_pieces = true;
//				}
//				else {
			mult_pieces = true;
			j = 0;
			final_j1 = 0;
			final_j2 = 0;
			area_sum1 = 0;
			area_sum2 = 0;
			height1 = 0;
			height2 = 0;
			width1 = 0;
			width2 = 0;
			while (j < nResults()) {
				if (((getResult("BY", j)+getResult("Height", j))==Image.height)) {
					j += 1;
				}
				else if ((getResult("Width", j))+(getResult("Height", j)) > area_sum1) {
					area_sum2 = area_sum1;
					area_sum1 = (getResult("Width", j))+(getResult("Height", j));
					width2 = width1;
					width1 = getResult("Width", j);
					height2 = height1;
					height1 = getResult("Height", j);
					final_j2 = final_j1;
					final_j1 = j;
					j += 1;
				}
				else if ((getResult("Width", j))+(getResult("Height", j)) > area_sum2) {
					area_sum2 = (getResult("Width", j))+(getResult("Height", j));
					width2 = getResult("Width", j);
					height2 = getResult("Height", j);
					final_j2 = j;
					j += 1;
				}
				else {
					j += 1;
				}
			}
//			}
		}
		
		else {
			j = 0;
			final_j = 0;
			area_sum = 0;
			height = 0;
			width = 0;
			while (j < nResults()) {
				if (((getResult("BY", j)+getResult("Height", j))==Image.height)) {
					j += 1;
				}
				else if ((getResult("Width", j))+(getResult("Height", j)) > area_sum) {
					area_sum = (getResult("Width", j))+(getResult("Height", j));
					width = getResult("Width", j);
					height = getResult("Height", j);
					final_j = j;
					j += 1;
				}
				else {
					j += 1;
				}
			}
		}
		
		if (mult_pieces) {
			BX1 = getResult("BX", final_j1);
			BX2 = getResult("BX", final_j2);
			BY1 = getResult("BY", final_j1);
			BY2 = getResult("BY", final_j2);
			width1 = getResult("Width", final_j1);
			width2 = getResult("Width", final_j2);
			height1 = getResult("Height", final_j1);
			height2 = getResult("Height", final_j2);
			
			if (BX1 < BX2) {
				if ((BX2 + width2) < (BX1 + width1)) {
					BX = BX1;
					width = width1;
				}
				else {
					BX = BX1;
					width = (BX2 + width2) - BX1;
				}
			}
			else {
				if ((BX1 + width1) < (BX2 + width2)) {
					BX = BX2;
					width = width2;
				}
				else {
					BX = BX2;
					width = (BX1 + width1) - BX2;
				}
			}
			
			if (BY1 < BY2) {
				BY = BY1;
				if ((BY1 + height1) < (BY2 + height2)) {
					height = (BY2 + height2) - BY1;
				}
				else {
					height = height1;
				}
			}
			
			else {
				BY = BY2;
				if ((BY2 + height2) < (BY1 + height1)) {
					height = (BY1 + height1) - BY2;
				}
				else {
					height = height2;
				}
			}
		}
		
		else {
			BX = getResult("BX", final_j);
			BY = getResult("BY", final_j);
		}
		
		cropBX = (BX*4);
		crop_xs[im] = cropBX;
		cropBY = (BY*4) - 50;
		crop_ys[im] = cropBY;
		cropW = (width*4) + 100;
		crop_Ws[im] = cropW;
		cropH = (height*4) + 100;
		crop_Hs[im] = cropH;
		
		print(cropBX, cropBY, cropW, cropH);
		
		close();
		run("Collect Garbage");
		run("Collect Garbage");
		
		Array.getStatistics(crop_Hs, min, max, mean, stdDev);
		max_H = max;
		print(max_H);
		
		for (H=0; H<num_ims; H++) {
			if (crop_Hs[H] < max_H) {
				H_diff = max_H - crop_Hs[H];
				half_diff = H_diff / 2;
				old_y = crop_ys[H];
				if ((old_y - H_diff) > 0) {
					new_y = old_y - H_diff;
					extra_h = 0;
				}
				else {
					extra_h = H_diff - old_y;
					new_y = 0;
				}
				crop_ys[H] = new_y;
				old_H = crop_Hs[H];
				new_H = old_H + H_diff + extra_h;
				crop_Hs[H] = new_H;
			}
			else {
				continue;
			}
		}
		
		selectWindow(im_list[im]);
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		
		makeRectangle(crop_xs[im], crop_ys[im], crop_Ws[im], crop_Hs[im]);
		run("Crop");
			
//			orig = orig_names[im];
//			file_name_split = split(orig, ".");
//			file_name_noex = file_name_split[0];
//			file_ex_dot = replace(orig, file_name_noex, "");
//			new_file_name = file_name_noex+"_rotated"+file_ex_dot;
//			save(rot_dir + File.separator + new_file_name);
//			close();
//			run("Collect Garbage");
//			run("Collect Garbage");
		
		if (add_labels) {
			setColor("white");
			setJustification("left");
			setFont("Monospaced", 250, "non-antialiased bold");
			stringW = getStringWidth(im_tags[im]);
			print(stringW);
			stringH = getValue("font.height");
			text_y = stringH;
			drawString(im_tags[im], 0, text_y, "black");
		}
		
		
	}
	Array.print(crop_xs);
	Array.print(crop_ys);
	Array.print(crop_Ws);
	Array.print(crop_Hs);
	Array.print(crop_Hs);
	new_height_sum = 0;
	for (i=0; i<num_ims; i++) {
		new_height_sum += crop_Hs[i];
	}
	
	selectWindow(stack);
	run("Canvas Size...", "width=stack_width height=new_height_sum position=Bottom-Center zero");
	
	y_pos = newArray(num_ims+1);
	y_pos[0] = 0;
	
	for (im=0; im<num_ims; im++) {
		selectWindow(im_list[im]);
		y_pos[im+1] = Image.height;
		Image.copy;
		close();
		selectWindow(stack);
		Image.paste(0, y_pos[im]);
		run("Collect Garbage");
		run("Collect Garbage");
	}
	
	
	setColor("white");
	setJustification("left");
	setFont("Monospaced", 250, "non-antialiased bold");
	stringW = getStringWidth("1 mm");
	print(stringW);
	text_x = (stack_width / 2) - (stringW / 2);
	stringH = getValue("font.height");
	
	padding = 100;
	bar_height = 150;
	bar_width = 2300;
	half_bar = bar_width / 2;
	half_width = stack_width / 2;
	bar_x = half_width - half_bar;
	
	extra_height = height_sum + stringH + bar_height + (3 * padding);
	run("Canvas Size...", "width=stack_width height=extra_height position=Top-Center zero");
	
	bar_y = Image.height - (padding + bar_height);
	setColor(255, 255, 255);
	fillRect(bar_x, bar_y, bar_width, bar_height);
	
	text_y = Image.height - (bar_height + (2 * padding));
	drawString("1 mm", text_x, text_y, "black");
	
	Dialog.create("Name Stacked Image");
	Dialog.addString("Name:", "name here");
	Dialog.show();
	stack_name = Dialog.getString();
	
	save(main_dir + stack_name);
	close("*");
	run("Collect Garbage");
	run("Collect Garbage");
	exit("Saved new image");
}
