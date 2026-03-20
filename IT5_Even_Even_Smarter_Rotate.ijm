macro "Even Even Smarter Rotate Hist" {
	orig_dir = File.getDefaultDir;
	im_dir = getDir("Choose a Directory");
	File.setDefaultDir(im_dir);
	im_list = getFileList(im_dir);
	print(im_list[0]);
	num_ims = lengthOf(im_list);
	
	for (im=0; im<num_ims; im++) {
		open(im_list[im]);
		orig = getTitle();
		run("Duplicate...", "title=edges");
		run("Find Edges");
		run("Make Binary");
		run("Fill Holes");
		run("Find Edges");
		run("Make Binary");
		run("Fill Holes");
		run("Threshold", "apply");
		run("Set Measurements...", "fit redirect=None decimal=3");
		run("Analyze Particles...", "size=1000-Infinity display clear");
		el_major = 0;
		final_i = 0;
		i = 0;
		while (i < nResults()) {
			if (getResult("Major", i) > el_major) {
				el_major = getResult("Major", i);
				final_i = i;
			}
			i += 1;
		}
		angle = getResult("Angle", final_i);
		print(angle);
		angle_fixed = (-1)*(180 - angle);
		print(angle_fixed);
		run("Rotate...", "angle="+(angle_fixed)+" grid=1 interpolation=Bilinear");
		run("Threshold", "apply");
		run("Set Measurements...", "bounding redirect=None decimal=3");
		run("Analyze Particles...", "size=5000-Infinity display clear");
		j = 0;
		final_j = 0;
		area_sum = 0;
		height = 0;
		width = 0;
		while (j < nResults()) {
			if ((getResult("Width", j))+(getResult("Height", j)) > area_sum) {
				area_sum = (getResult("Width", j))+(getResult("Height", j));
				width = getResult("Width", j);
				height = getResult("Height", j);
				final_j = j;
			}
			j += 1;
		}
		BX = getResult("BX", final_j);
		BY = getResult("BY", final_j);
		
		selectWindow(orig);
		im_height = Image.height - 4;
		im_width = Image.width - 4;
	
		pix = getPixel(5, 5);
		red = (pix>>16)&0xff;  // extract red byte (bits 23-17)
	    green = (pix>>8)&0xff; // extract green byte (bits 15-8)
	    blue = pix&0xff;       // extract blue byte (bits 7-0)
		print(red, green, blue);
		if ((red<30)&&(green<30)&&(blue<30)) {
			top_left_black = true;
			x = im_width - 1005;
			y = 5;
			w = 1000;
			h = 1000;
		} else {
			top_left_black = false;
			x = 5;
			y = 5;
			w = 1000;
			h = 1000;
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
		if (top_left_black == true) {
			floodFill(5, 5, "8-connected");
			floodFill((im_width), (im_height), "8-connected");
		} else {
			floodFill((im_width), 5, "8-connected");
			floodFill(5, (im_height), "8-connected");
		}
		run("Select None");
		print(angle_fixed);
		run("Rotate...", "angle="+(angle_fixed)+" grid=1 interpolation=Bilinear");
		makeRectangle(BX, BY, width, height);
		run("Crop");
	
		file_name_split = split(orig, ".");
		file_name_noex = file_name_split[0];
		file_ex_dot = replace(orig, file_name_noex, "");
		new_file_name = file_name_noex+"_rotated"+file_ex_dot;
		save(im_dir+new_file_name);
		close("*");
	}
	File.setDefaultDir(orig_dir);
	exit("Saved new images");
}