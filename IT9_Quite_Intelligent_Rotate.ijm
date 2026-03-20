macro "Quite Intelligent Rotate" {
	orig_dir = File.getDefaultDir;
	im_dir = getDir("Choose a Directory");
	File.setDefaultDir(im_dir);
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
	
	add_labels = getBoolean("Add Labels to Images?");
	
	temp_dir = im_dir + File.separator + "temp_ims";
	if (!File.exists(temp_dir)) {
	    File.makeDirectory(temp_dir);
	}
	
	rot_dir = im_dir + File.separator + "rot_ims";
	if (!File.exists(rot_dir)) {
	    File.makeDirectory(rot_dir);
	}

	im_tags = newArray(
		"2h Post-Burn", "1d Post-Burn", "4d Post-Burn",
		"8d Post-Burn", "15d Post-Burn", "22d Post-Burn"
		);
	crop_xs = newArray(num_ims);
	crop_ys = newArray(num_ims);
	crop_Hs = newArray(num_ims);
	crop_Ws = newArray(num_ims);
	angles = newArray(num_ims);
	orig_names = newArray(num_ims);
	
	for (im=0; im<num_ims; im++) {
		open(im_list[im]);
		orig = getTitle();
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
		run("Canvas Size...", "width=origDiag height=origDiag");
		floodFill(5, 5, "8-connected");
//		floodFill((Image.width-5), 5, "8-connected");
		diagW = getWidth();
		diagH = getHeight();
		
		run("Duplicate...", "title=thresh");
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
		el_major = 0;
		final_i = 0;
		i = 0;
		while (i < nResults()) {
			if ((88 < getResult("Angle", i))&&(getResult("Angle", i) < 92)) {
				i += 1;
			}
//			if (getResult("Minor", i) > (Image.height/3))
//				i += 1
			else if (getResult("Major", i) > el_major) {
				el_major = getResult("Major", i);
				final_i = i;
				i += 1;
			}
			else {
				i += 1;
			}
		}
		angle = getResult("Angle", final_i);
		print(angle);
		angle_fixed = (-1)*(180 - angle);
		angles[im] = angle_fixed;
		print(angle_fixed);
		run("Rotate...", "angle="+(angle_fixed)+" grid=1 interpolation=Bilinear");
		
		run("Convert to Mask");
		run("Set Measurements...", "bounding redirect=None decimal=3");
		run("Analyze Particles...", "size=5000-Infinity pixel display clear");
		
		j = 0;
		final_j = 0;
		area_sum = 0;
		height = 0;
		width = 0;
		while (j < nResults()) {
			if ((getResult("BX", j)==0)|((getResult("BY", j)+getResult("Height", j))==Image.height))
				j += 1;
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
		
		BX = getResult("BX", final_j);
		BY = getResult("BY", final_j);
		cropBX = (BX*4) - 50;
		crop_xs[im] = cropBX;
		cropBY = (BY*4) - 50;
		crop_ys[im] = cropBY;
		cropW = (width*4) + 100;
		crop_Ws[im] = cropW;
		cropH = (height*4) + 100;
		crop_Hs[im] = cropH;
		
		selectWindow(orig);
		file_name_split = split(orig, ".");
		file_name_noex = file_name_split[0];
		file_ex_dot = replace(orig, file_name_noex, "");
		new_file_name = file_name_noex+"_temp"+file_ex_dot;
		save(temp_dir + File.separator + new_file_name);
		
		close("*");
	}
	
	Array.getStatistics(crop_Hs, min, max, mean, stdDev);
	max_H = max;
	print(max_H);
	
	temp_ims_in_dir = 0;
	temp_file_list = getFileList(temp_dir);
	for (i=0; i<temp_file_list.length; i++) {
		if (endsWith(temp_file_list[i], ".jpg")) {
			temp_ims_in_dir += 1;
		}
	}
	
	temp_im_list = newArray(temp_ims_in_dir);
	temp_im_index = 0;
	for (i=0; i<temp_file_list.length; i++) {
		if (endsWith(temp_file_list[i], ".jpg")) {
			temp_im_list[temp_im_index] = temp_file_list[i];
			temp_im_index += 1;
		}
		else {
			continue;
		}
	}
	
	print(temp_im_list[0]);
	num_ims = lengthOf(temp_im_list);
	
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
		
		open(temp_dir + File.separator + temp_im_list[im]);
		temp = getTitle();
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		
		run("Rotate...", "angle="+(angles[im])+" grid=1 interpolation=Bilinear");
		makeRectangle(crop_xs[im], crop_ys[im], crop_Ws[im], crop_Hs[im]);
		run("Crop");
		
		newIM = getTitle();
		origH = Image.height;
		origW = Image.width;
		
		run("Duplicate...", "title=flipper");
		newW = origW*0.05;
		newH = origH*0.05;
		run("Select None");
		run("Size...", "width=newW height=newH average=true interpolation=Bilinear");
		
		halfH = newH / 2;
		
		sumR1 = 0;
		sumG1 = 0;
		sumB1 = 0;
		count = 0;
		for (i = 5; i < newW; i++) {
			    for (j = 5; j < halfH; j++) {
			        pix = getPixel(i, j);
			        r = (pix>>16)&0xff;  // extract red byte (bits 23-17)
				    g = (pix>>8)&0xff; // extract green byte (bits 15-8)
				    b = pix&0xff;
			        sumR1 += r;
			        sumG1 += g;
			        sumB1 += b;
			        count++;
			   	}
			}
		avgR1 = sumR1 / count;
		avgG1 = sumG1 / count;
		avgB1 = sumB1 / count;
		
		sumR2 = 0;
		sumG2 = 0;
		sumB2 = 0;
		count = 0;
		for (i = 5; i < newW; i++) {
			    for (j = halfH; j < newH; j++) {
			        pix = getPixel(i, j);
			        r = (pix>>16)&0xff;  // extract red byte (bits 23-17)
				    g = (pix>>8)&0xff; // extract green byte (bits 15-8)
				    b = pix&0xff;
			        sumR2 += r;
			        sumG2 += g;
			        sumB2 += b;
			        count++;
			   	}
			}
		avgR2 = sumR2 / count;
		avgG2 = sumG2 / count;
		avgB2 = sumB2 / count;
			
		color1 = Math.sqrt(pow(avgR1, 2) + pow(avgG1, 2) + pow(avgB1, 2));
		color2 = Math.sqrt(pow(avgR2, 2) + pow(avgG2, 2) + pow(avgB2, 2));
		
		selectWindow(newIM);
		
		if (color2 > color1) {
			run("Flip Vertically");
		}
		
		if (add_labels) {
			setColor("white");
			setJustification("left");
			setFont("Monospaced", 250, "non-antialiased bold");
			stringW = getStringWidth(im_tags[im]);
			print(stringW);
			text_x = (Image.width / 2) - (stringW / 2);
			print(text_x);
			stringH = getValue("font.height");
			text_y = stringH + 10;
			drawString(im_tags[im], text_x, text_y, "black");
		}
		
		orig = orig_names[im];
		file_name_split = split(orig, ".");
		file_name_noex = file_name_split[0];
		file_ex_dot = replace(orig, file_name_noex, "");
		new_file_name = file_name_noex+"_rotated"+file_ex_dot;
		save(rot_dir + File.separator + new_file_name);
		close("*");
	}
	File.setDefaultDir(orig_dir);
	exit("Saved new images");
}
