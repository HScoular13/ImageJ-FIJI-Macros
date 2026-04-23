macro "Immuno Color Quantifier" {
	run("Collect Garbage");
	run("Collect Garbage");
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
		else {
			continue;
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
		run("Collect Garbage");
		run("Collect Garbage");
		open(im_dir+im_list[im]);
		run("Set Scale...", "distance=1760 known=1 pixel=1 unit=mm");
		orig_im_name = getTitle();
		
		file_name_split = split(orig_im_name, ".");
		file_name_noex = file_name_split[0];
		im_output = File.open(im_dir+file_name_noex+".txt");
		
		im_width = Image.width;
		im_height = Image.height;
		half_width = im_width / 2;
		
		run("16-bit");
		run("Duplicate...", "title=thresh");
		im_copy = getTitle();
		run("Auto Threshold", "method=MinError(I) ignore_black white");
		run("Fill Holes");
		run("Set Measurements...", "area mean integrated limit redirect=["+orig_im_name+"] decimal=3");
		std_lowbound_size = 0.4;
		run("Analyze Particles...", "size="+std_lowbound_size+"-Infinity display clear add");
		
		while (nResults() < 1) {
			std_lowbound_size -= 0.05;
			run("Analyze Particles...", "size="+std_lowbound_size+"-Infinity display clear add");
		}
		
		roiManager("Select", 0);
		run("Clear Outside");
		run("Select None");
		roiManager("delete");
//		
//		while (i < nResults()) {
//			if ((getResult("BX", j)==0)|((getResult("BY", j)+getResult("Height", j))==Image.height))
//				j += 1;
//			else if ((getResult("Width", j))+(getResult("Height", j)) > area_sum) {
//				area_sum = (getResult("Width", j))+(getResult("Height", j));
//				width = getResult("Width", j);
//				height = getResult("Height", j);
//				final_j = j;
//				j += 1;
//			}
//			else {
//				j += 1;
//			}
//		}
		
		roi_xs = newArray(0);
		roi_ys = newArray(0);
//		selectWindow(orig_im_name);
		
		for (x=0; x<im_width; x++) {
			if (x%500 == 0) {
				print("Checking Column "+x);
			}
			
			for (y=0; y<im_height; y++) {
				pix_val = getPixel(x, y);
				
				if (pix_val == 255) {
					roi_xs = Array.concat(roi_xs, x);
					roi_ys = Array.concat(roi_ys, y);
				}
				else {
					continue;
				}
			}
		}
		
		print("ROI Xs: "+lengthOf(roi_xs));
		print("ROI Ys: "+lengthOf(roi_ys));
		selectWindow(orig_im_name);
		col_means = newArray(0);
		col_intDens = newArray(0);
		col_counts = newArray(0);
		col_xs = newArray(0);
		
		for (pix=0; pix<lengthOf(roi_xs); pix++) {
			sum = 0;
			count = 0;
			current_col = roi_xs[pix];
			
			if (pix%500 == 0) {
				print("Quantifying Column "+pix);
			}
			
			if ((pix > 0)&(lengthOf(col_xs) > 0)&(current_col == col_xs[lengthOf(col_xs) - 1])) {
				continue;
			}
			else {
				for (pix=0; pix<lengthOf(roi_xs); pix++) {
					x = roi_xs[pix];
					y = roi_ys[pix];
					
					if (x == current_col) {
						gray_val = getPixel(x, y);
						count += 1;
						sum += gray_val;
					}
					else {
						col_intDens = Array.concat(col_intDens, sum);
						col_counts = Array.concat(col_counts, count);
						col_means = Array.concat(col_means, (sum/count));
						col_xs = Array.concat(col_xs, current_col);
						break;
					}
				}
			}
		}
		
		print(im_output, "Column Number\tCount\tMean Gray Value\tIntegrated Density")
		
		for (i=0; i<lengthOf(col_xs); i++) {
			print(im_output, col_xs[i]+"\t"+col_counts[i]+"\t"+col_means[i]+"\t"+col_intDens[i]);
		}
		close("*");
		File.close(im_output);
		run("Collect Garbage");
		run("Collect Garbage");
	}
	run("Collect Garbage");
	run("Collect Garbage");
}
