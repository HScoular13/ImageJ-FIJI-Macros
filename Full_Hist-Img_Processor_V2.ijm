macro "Full_Histology_Image_Processor" {
	run("Collect Garbage");
	run("Collect Garbage");
	
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
	
//	temp_dir = im_dir + "temp_ims" + File.separator;
//	if (!File.exists(temp_dir)) {
//	    File.makeDirectory(temp_dir);
//	}
	
	rot_dir = im_dir + "processed_imgs" + File.separator;
	if (!File.exists(rot_dir)) {
	    File.makeDirectory(rot_dir);
	}

	crop_xs = newArray(num_ims);
	crop_ys = newArray(num_ims);
	crop_Hs = newArray(num_ims);
	crop_Ws = newArray(num_ims);
	angles = newArray(num_ims);
	orig_names = newArray(num_ims);
	Array.print(im_list);
	
	for (im=0; im<num_ims; im++) {
		open(im_dir + im_list[im]);
		orig = getTitle();
		print(im);
		print(orig);
		orig_names[im] = orig;
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		
		cbarHeight = 0.15 * Image.height;
		cbarWidth = 150;
		setColor(0, 0, 0);
		fillRect(0, 0, cbarWidth, cbarHeight);
		
		im_height = Image.height - 4;
		im_width = Image.width - 4;
	
		pix_tl = getPixel(5, 5);
		red_tl = (pix_tl>>16)&0xff;  // extract red byte (bits 23-17)
	    green_tl = (pix_tl>>8)&0xff; // extract green byte (bits 15-8)
	    blue_tl = pix_tl&0xff;       // extract blue byte (bits 7-0)
		print(red_tl, green_tl, blue_tl);
		pix_tr = getPixel(im_width, 5);
		red_tr = (pix_tr>>16)&0xff;  // extract red byte (bits 23-17)
	    green_tr = (pix_tr>>8)&0xff; // extract green byte (bits 15-8)
	    blue_tr = pix_tr&0xff;       // extract blue byte (bits 7-0)
		print(red_tr, green_tr, blue_tr);
		
		if (((red_tl<30)&&(green_tl<30)&&(blue_tl<30))&&((red_tr<30)&&(green_tr<30)&&(blue_tr<30))) {
			both_black = true;
			top_left_black = false;
			for (i=5; i<im_height; i++) {
				pix = getPixel(im_width, i);
				red = (pix>>16)&0xff;
				blue = (pix>>8)&0xff;
				green = pix&0xff;
				if ((red<30)&&(blue<30)&&(green<30)) {
					i += 1;
				}
				else {
					y = i;
					break;
				}
			}
			x = im_width - 500;
			w = 500;
			h = 500;
		}
		else if ((red_tl<30)&&(green_tl<30)&&(blue_tl<30)) {
			top_left_black = true;
			both_black = false;
			x = im_width - 505;
			y = 5;
			w = 500;
			h = 500;
		}
		else {
			top_left_black = false;
			both_black = false;
			x = 5;
			y = 5;
			w = 500;
			h = 500;
		}
		makeRectangle(x, y, w, h);
		getSelectionBounds(x, y, w, h);
		sumR = 0;
		sumG = 0;
		sumB = 0;
		count = 0;
		
		for (i = x; i < x + w; i++) {
		    for (j = y; j < y + h; j++) {
		        pix = getPixel(i, j);
		        r = (pix>>16)&0xff;  // extract red byte (bits 23-17)
			    g = (pix>>8)&0xff; // extract green byte (bits 15-8)
			    b = pix&0xff;
		        sumR += r;
		        sumG += g;
		        sumB += b;
		        count++;
		   	}
		}
		avgR = sumR / count;
		avgG = sumG / count;
		avgB = sumB / count;
		setForegroundColor(avgR, avgG, avgB);
		
		if (both_black == true) {
			floodFill(5, 5, "8-connected");
			floodFill((im_width), 5, "8-connected");
			floodFill(5, (im_height), "8-connected");
			floodFill((im_width), (im_height), "8-connected");
		}
		else if (top_left_black == true) {
			floodFill(5, 5, "8-connected");
			floodFill((im_width), (im_height), "8-connected");
		}
		else {
			floodFill((im_width), 5, "8-connected");
			floodFill(5, (im_height), "8-connected");
		}
		
		run("Select None");
		
		origW = getWidth();
		origH = getHeight();
		origDiag = Math.sqrt(pow(origW, 2) + pow(origH, 2));
		origDiag = round(origDiag);
		run("Canvas Size...", "width=origDiag height=origDiag");
		floodFill(5, 5, "8-connected");
//		floodFill((Image.width-5), 5, "8-connected");
		diagW = getWidth();
		diagH = getHeight();
		
		run("Duplicate...", "title=thresh");
		
//		selectWindow(orig);
//		file_name_split = split(orig, ".");
//		file_name_noex = file_name_split[0];
//		file_ex_dot = replace(orig, file_name_noex, "");
//		new_file_name = file_name_noex+"_temp"+file_ex_dot;
//		save(temp_dir + File.separator + new_file_name);
//		close(orig);
		
		newW = diagW*0.25;
		newH = diagH*0.25;
		run("Select None");
		run("Size...", "width=newW height=newH average=true interpolation=Bilinear");
		
		run("8-bit");
		run("Auto Threshold", "method=Otsu ignore_black black");
		setThreshold(128, 255);
		run("Convert to Mask");
		run("Fill Holes");
		
		run("Set Measurements...", "fit redirect=None decimal=3");
		run("Analyze Particles...", "size=1000-Infinity pixel display clear");
		print(nResults());
		el_major1 = 0;
		el_major2 = 0;
		final_i1 = 0;
		final_i2 = 0;
		i = 0;
		while (i < nResults()) {
			if ((88 < getResult("Angle", i))&&(getResult("Angle", i) < 92)) {
				i += 1;
			}
//			if (getResult("Minor", i) > (Image.height/3))
//				i += 1
			else if (getResult("Major", i) > el_major1) {
				el_major2 = el_major1;
				el_major1 = getResult("Major", i);
				final_i1 = i;
				i += 1;
			}
			else if (getResult("Major", i) > el_major2) {
				el_major2 = getResult("Major", i);
				final_i2 = i;
				i += 1;
			}
			else {
				i += 1;
			}
		}
		
		if ((el_major2 / el_major1) > 0.3) {
			angle = (getResult("Angle", final_i1) + getResult("Angle", final_i2)) / 2;
		}
		else {
			angle = getResult("Angle", final_i1);
		}
		
		print(angle);
		angle_fixed = (-1)*(180 - angle);
		angles[im] = angle_fixed;
		print(angle_fixed);
		run("Rotate...", "angle="+(angle_fixed)+" grid=1 interpolation=Bilinear");
		
		run("Convert to Mask");
		run("Set Measurements...", "bounding redirect=None decimal=3");
		run("Analyze Particles...", "size=5000-Infinity pixel display clear");
		
		two_pieces = false;
		if (nResults() == 2) {
			if ((maxOf(getResult("Width", 0),getResult("Width", 1))/minOf(getResult("Width", 0),getResult("Width", 1)))<8) {
				two_pieces = true;
			}
			else {
				j = 0;
				final_j = 0;
				area_sum = 0;
				height = 0;
				width = 0;
				while (j < nResults()) {
					if ((getResult("BX", j)==0)|((getResult("BY", j)+getResult("Height", j))==Image.height)) {
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
		}
		
		else {
			j = 0;
			final_j = 0;
			area_sum = 0;
			height = 0;
			width = 0;
			while (j < nResults()) {
				if ((getResult("BX", j)==0)|((getResult("BY", j)+getResult("Height", j))==Image.height)) {
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
		
		if (two_pieces) {
			BX1 = getResult("BX", 0);
			BX2 = getResult("BX", 1);
			BY1 = getResult("BY", 0);
			BY2 = getResult("BY", 1);
			width1 = getResult("Width", 0);
			width2 = getResult("Width", 1);
			height1 = getResult("Height", 0);
			height2 = getResult("Height", 1);
			
			if (BX1 < BX2) {
				BX = BX1;
				width = (BX2 + width2) - BX1;
			}
			else {
				BX = BX2;
				width = (BX1 + width1) - BX2;
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
		
		cropBX = (BX*4) - 50;
		crop_xs[im] = cropBX;
		cropBY = (BY*4) - 50;
		crop_ys[im] = cropBY;
		cropW = (width*4) + 100;
		crop_Ws[im] = cropW;
		cropH = (height*4) + 100;
		crop_Hs[im] = cropH;
		
		close();
		run("Collect Garbage");
		run("Collect Garbage");
	}
	
	Array.getStatistics(crop_Hs, min, max, mean, stdDev);
	max_H = max;
	print(max_H);
	
//	temp_ims_in_dir = 0;
//	temp_file_list = getFileList(temp_dir);
//	for (i=0; i<temp_file_list.length; i++) {
//		if (endsWith(temp_file_list[i], ".jpg")) {
//			temp_ims_in_dir += 1;
//		}
//	}
//	
//	temp_im_list = newArray(temp_ims_in_dir);
//	temp_im_index = 0;
//	for (i=0; i<temp_file_list.length; i++) {
//		if (endsWith(temp_file_list[i], ".jpg")) {
//			temp_im_list[temp_im_index] = temp_file_list[i];
//			temp_im_index += 1;
//		}
//		else {
//			continue;
//		}
//	}
	
//	print(temp_im_list[0]);
//	num_ims = lengthOf(temp_im_list);
	
	for (im=0; im<num_ims; im++) {
		for (H=0; H<num_ims; H++) {
			if (crop_Hs[H] < max_H) {
				H_diff = max_H - crop_Hs[H];
				half_diff = H_diff / 2;
				old_y = crop_ys[H];
				new_y = old_y - half_diff;
				crop_ys[H] = new_y;
				old_H = crop_Hs[H];
				new_H = old_H + H_diff;
				crop_Hs[H] = new_H;
			}
			else {
				continue;
			}
		}
		
//		open(temp_dir + File.separator + temp_im_list[im]);
//		temp = getTitle();
//		jdjidwnoinwionvion
		selectWindow(im_list[im]);
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		
		run("Rotate...", "angle="+(angles[im])+" grid=1 interpolation=Bilinear");
		makeRectangle(crop_xs[im], crop_ys[im], crop_Ws[im], crop_Hs[im]);
		run("Crop");
		
//		newIM = getTitle();
//		origH = Image.height;
//		origW = Image.width;
//		
//		run("Duplicate...", "title=flipper");
//		newW = origW*0.05;
//		newH = origH*0.05;
//		run("Select None");
//		run("Size...", "width=newW height=newH average=true interpolation=Bilinear");
//		
//		halfH = newH / 2;
//		
//		sumR1 = 0;
//		sumG1 = 0;
//		sumB1 = 0;
//		count = 0;
//		for (i = 5; i < newW; i++) {
//			    for (j = 5; j < halfH; j++) {
//			        pix = getPixel(i, j);
//			        r = (pix>>16)&0xff;  // extract red byte (bits 23-17)
//				    g = (pix>>8)&0xff; // extract green byte (bits 15-8)
//				    b = pix&0xff;
//			        sumR1 += r;
//			        sumG1 += g;
//			        sumB1 += b;
//			        count++;
//			   	}
//			}
//		avgR1 = sumR1 / count;
//		avgG1 = sumG1 / count;
//		avgB1 = sumB1 / count;
//		
//		sumR2 = 0;
//		sumG2 = 0;
//		sumB2 = 0;
//		count = 0;
//		for (i = 5; i < newW; i++) {
//			    for (j = halfH; j < newH; j++) {
//			        pix = getPixel(i, j);
//			        r = (pix>>16)&0xff;  // extract red byte (bits 23-17)
//				    g = (pix>>8)&0xff; // extract green byte (bits 15-8)
//				    b = pix&0xff;
//			        sumR2 += r;
//			        sumG2 += g;
//			        sumB2 += b;
//			        count++;
//			   	}
//			}
//		avgR2 = sumR2 / count;
//		avgG2 = sumG2 / count;
//		avgB2 = sumB2 / count;
//			
//		color1 = Math.sqrt(pow(avgR1, 2) + pow(avgG1, 2) + pow(avgB1, 2));
//		color2 = Math.sqrt(pow(avgR2, 2) + pow(avgG2, 2) + pow(avgB2, 2));
//		
//		selectWindow(newIM);
//		
//		if (color2 > color1) {
//			run("Flip Vertically");
//		}
		
//		if (add_labels) {
//			setColor("white");
//			setJustification("left");
//			setFont("Monospaced", 250, "non-antialiased bold");
//			stringW = getStringWidth(im_tags[im]);
//			print(stringW);
//			text_x = (Image.width / 2) - (stringW / 2);
//			print(text_x);
//			stringH = getValue("font.height");
//			text_y = stringH + 10;
//			drawString(im_tags[im], text_x, text_y, "black");
//		}
		
		orig = orig_names[im];
		file_name_split = split(orig, ".");
		file_name_noex = file_name_split[0];
		file_ex_dot = replace(orig, file_name_noex, "");
		new_file_name = file_name_noex+"_rotated"+file_ex_dot;
		save(rot_dir + File.separator + new_file_name);
		close();
		run("Collect Garbage");
		run("Collect Garbage");
	}
	
//	deleteDirectory(temp_dir);
	run("Collect Garbage");
	run("Collect Garbage");
	part1_done = getBoolean("Saved processed images. Run image flipper macro?");
	
	
	if (part1_done) {
		im_dir_orig = im_dir;
		im_dir = rot_dir;
		print(im_dir);
		im_list = getFileList(im_dir);
		num_ims = lengthOf(im_list);
		binary_flip = newArray(num_ims);
		
		for (i=0; i<num_ims; i++) {
			open(im_dir + im_list[i]);
			binary_flip[i] = getBoolean("Flip Image?");
		}
		
		for (i=0; i<num_ims; i++) {
			if (binary_flip[i]) {
				selectWindow(im_list[i]);
				run("Flip Vertically");
				save(im_dir + im_list[i]);
			}
		}
		close("*");
		run("Collect Garbage");
		run("Collect Garbage");
	}
	else {
		exit("Saved Processed Images");
		run("Collect Garbage");
		run("Collect Garbage");
	}
	
	part2_done = getBoolean("Saved flipped images. Run image stacker macro?");
	
	if (part2_done) {
//		main_dir = getDir("test");
//		im_dir =  getDir("test");
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
		burn_center_y = newArray(num_ims);
		control_ims = false;
		control_ims = getBoolean("Are these Control Tissues?");
		
		if (!control_ims) {
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
		//		burn_center_y[im] = point_y;
				Array.print(burn_center_x);
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
		
		run("Image...", "name="+im_dir+"_stack RGB white width=min_width height=height_sum");
		stack = getTitle();
		
	//	if (add_labels) {
	//		im_list = getFileList(label_dir+File.separator);
	//		Array.print(im_list);
	//		File.setDefaultDir(label_dir+File.separator);
	//	}
		
		for (im=0; im<num_ims; im++) {
			open(im_dir + im_list[im]);
			current_im = getTitle();
			
			if (control_ims) {
				x_rect = (image_widths[im] / 2) - (min_width / 2);
			}
			else {
				x_rect = burn_center_x[im] - (min_width / 2);
			}

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
			run("Collect Garbage");
			run("Collect Garbage");
		}
		
		setColor("white");
		setJustification("left");
		setFont("Monospaced", 250, "non-antialiased bold");
		stringW = getStringWidth("1 mm");
		print(stringW);
		text_x = (min_width / 2) - (stringW / 2);
		stringH = getValue("font.height");
		
		padding = 100;
		bar_height = 150;
		bar_width = 2300;
		half_bar = bar_width / 2;
		half_width = min_width / 2;
		bar_x = half_width - half_bar;
		
		extra_height = height_sum + stringH + bar_height + (3 * padding);
		run("Canvas Size...", "width=min_width height=extra_height position=Top-Center zero");
		
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
	else {
		exit("Something happened");
		run("Collect Garbage");
		run("Collect Garbage");
	}
	
	run("Collect Garbage");
	run("Collect Garbage");
}