macro "PowerPoint Image Maker" {
	run("Collect Garbage");
	run("Collect Garbage");
	Dialog.create("Message");
	Dialog.addMessage("This macro will only work for 8 or fewer images");
	Dialog.addMessage("The current version of this macro also assumes that\nall images are the same size.");
	Dialog.show();
	
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
	else {
		def_dir = orig_dir;
		print(def_dir);
	}
	
//	main_dir = getDir("Choose Main Directory Containing the Image Folder");
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
		if (endsWith(file_list[i], ".jpg") | endsWith(file_list[i], ".tif")) {
			im_list[im_index] = file_list[i];
			im_index += 1;
		}
		else {
			continue;
		}
	}

	print(im_list[0]);
	num_ims = lengthOf(im_list);
	
	Dialog.create("Name Image");
	Dialog.addString("Input filename for new image:", "filename");
	Dialog.show();
	filename = Dialog.getString();
	
	function arrange_grid(im_count) {
		Dialog.create("Image Layout")
		Dialog.addMessage("Number of Images in Folder: "+im_count);
		Dialog.addMessage("How many rows?");
		Dialog.addSlider("Rows", 1, 2, 1);
		Dialog.addMessage("How many images in each row?");
		Dialog.addMessage("(If only using 1 row, leave [Images in Row 2] set to 0.)");
		Dialog.addSlider("Images in Row 1", 1, im_count, 1);
		Dialog.addSlider("Images in Row 2", 0, im_count, 0);
		Dialog.show();
		
		g_rows = Dialog.getNumber();
		r1_ims = Dialog.getNumber();
		r2_ims = Dialog.getNumber();
		
		return newArray(g_rows, r1_ims, r2_ims);
	}
	
	if (num_ims > 3) {
		grid = arrange_grid(num_ims);
		grid_rows = grid[0];
		r1_ims = grid[1];
		r2_ims = grid[2];
	
		if ((r1_ims+r2_ims) != num_ims) {
			Dialog.create("Warning");
			Dialog.addMessage(
				"Inputted number of images does not match number of images in folder."
				)
			Dialog.addMessage(
				"Try again?"
				)
			Dialog.show();
			
			grid = arrange_grid(num_ims);
			grid_rows = grid[0];
			r1_ims = grid[1];
			r2_ims = grid[2];
			
			if ((r1_ims+r2_ims) != num_ims) {
				Dialog.create("Warning");
				Dialog.addMessage(
					"Inputted number of images still does not match number of images in folder."
					)
				Dialog.addMessage("The macro will now exit. Feel free to try again.")
				Dialog.show();
				exit();
			}
		}
		if ((grid_rows == 2) & (r1_ims == 0)) {
			grid_rows = 1;
			r1_ims = r2_ims;
			r2_ims = 0;
		}
	}
	else {
		grid_rows = 1;
		r1_ims = num_ims;
		r2_ims = 0;
	}
	print(grid_rows, r1_ims, r2_ims);
	
//	im_widths = newArray(num_ims);
//	im_heights = newArray(num_ims);
//	for (im=0; im<num_ims; im++) {
//		open(im_dir+im_list[im]);
//		im_widths[im] = Image.width;
//		im_heights[im] = Image.height;
//		close();
//	}

	open(im_dir+im_list[0]);
	im_width = Image.width;
	im_height = Image.height;
	close();
	run("Collect Garbage");
	run("Collect Garbage");
	
	equal_heights = false;
	equal_row_widths = false;
	equal_row_ims = true;
	if ((grid_rows > 1)&((num_ims%2)==1)) {
		equal_row_ims = false;
		Dialog.create("Arrangement Choice");
		Dialog.addMessage("Make the heights of the images in row 1 the same as those in row 2\nor\nmake the total widths of each row the same?");
		Dialog.addChoice("Options:", newArray("Equal Heights", "Equal Row Widths"));
		Dialog.show();
		choice = Dialog.getChoice();
		if (choice == "Equal Widths") {
			equal_row_widths = true;
		}
		else {
			equal_heights = true;
		}
	}


//	pp_width_in = 13.333; // Inches
//	pp_height_in = 7.5; // Inches
//	pp_scale = 129.1532; // Pixels per Inch
//	pp_width = pp_width_in * pp_scale;
//	pp_height = pp_height_in * pp_scale;
//	pp_width = 1722; // Pixels
//	pp_width = 1920; // Also Pixels
//	pp_height = 970; // Pixels
//	pp_height = 1080 // Also Pixels
//	run("Set Scale...", "distance=1722 known=13.333 unit=inch");

	Dialog.create("Image Title");
	Dialog.addCheckbox("Do you want the image to have a title?", false);
	Dialog.addString("If yes, input title. If no, ignore.", "Image Title");
	Dialog.show();
	add_title = Dialog.getCheckbox();
	im_title = Dialog.getString();
	
	Dialog.create("Image Color");
	Dialog.addChoice("Choose Background Color for Image:", newArray("white", "black"));
	Dialog.show();
	back_color = Dialog.getChoice();

	pp_width = 1280; // Pixels
	pp_height = 720; // Pixels

	newImage(filename, "RGB"+back_color, pp_width, pp_height, 1);
	pp_image = getTitle();
	
	if (add_title) {
		if (back_color=="white") {
			setColor("black");
		}
		else {
			setColor("white");
		}

		setJustification("left");
		setFont("Monospaced", 30, "non-antialiased bold");
		stringW = getStringWidth(im_title);
//		print("String W: "+stringW);
		title_x = (pp_width / 2) - (stringW / 2);
		stringH = getValue("font.height");
		title_y = stringH - 6;
		
//		print("title_y: "+title_y);
//		print("title_x"+title_x);
		
		drawString(im_title, title_x, title_y);
	}
	
	if (grid_rows == 1) {
		width_div = pp_width / num_ims;
		scale_val = width_div / im_width;
		scale_h = im_height * scale_val;
		first_y = title_y;
		im_xs = newArray(num_ims);
		if ((scale_h + first_y) > pp_height) {
			scale_h = pp_height - first_y;
			new_scale_val = scale_h / im_height;
			width_div = im_width * new_scale_val;
			extra_width = pp_width - (width_div * num_ims);
			extra_width_div = extra_width / (num_ims + 1);
			im_xs[0] = extra_width_div;
			for (i=1; i<num_ims; i++) {
				im_xs[i] = im_xs[i-1] + width_div + extra_width_div;
			}
		}
		else {
			im_xs[0] = 0;
			for (i=1; i<num_ims; i++) {
				im_xs[i] = im_xs[i-1] + width_div;
			}
		}
		
		im_y = (((pp_height - first_y) / 2) + first_y) - (scale_h / 2);
		for (im=0; im<num_ims; im++) {
			open(im_dir+im_list[im]);
			run("Size...", "width=width_div height=scale_h constrain average=true interpolation=Bilinear");
			Image.copy;
			close();
			selectWindow(pp_image);
			Image.paste(im_xs[im], im_y);
			run("Collect Garbage");
			run("Collect Garbage");
		}
	}
		
	else if (grid_rows == 2) {
		if (!equal_row_ims) {
			if (equal_heights) {
				r1_width_div = pp_width / r1_ims;
				r2_width_div = pp_width / r2_ims;
				width_div = minOf(r1_width_div, r2_width_div);
				scale_val =  width_div / im_width;
				scale_h = im_height * scale_val;
				first_y = title_y;
				im_xs = newArray(num_ims);
				im_ys = newArray(num_ims);
				im_widths = newArray(num_ims);
				im_heights = newArray(num_ims);
				
				if (((scale_h * 2) + first_y) > pp_height) {
					scale_h = (pp_height - first_y) / 2;
					new_scale_val = scale_h / im_height;
					width_div = im_width * new_scale_val;
					
					extra_h = pp_height - first_y - (2 * scale_h);
					extra_h_div = extra_h / 2;
					for (i=0; i<r1_ims; i++) {
						im_ys[i] = first_y;
					}
					for (i=r1_ims; i<num_ims; i++) {
						im_ys[i] = first_y + scale_h + extra_h_div;
					}
					
					extra_width_r1 = pp_width - (width_div * r1_ims);
					extra_width_r2 = pp_width - (width_div * r2_ims);
					extra_width_div_r1 = extra_width_r1 / (r1_ims + 1);
					extra_width_div_r2 = extra_width_r2 / (r2_ims + 1);
					im_xs[0] = extra_width_div_r1;
					im_xs[r1_ims] = extra_width_div_r2;
					for (i=1; i<r1_ims; i++) {
						im_xs[i] = im_xs[i-1] + width_div + extra_width_div_r1;
					}
					for (i=r2_ims; i<num_ims; i++) {
						im_xs[i] = im_xs[i-1] + width_div + extra_width_div_r2;
					}
					for (i=0; i<num_ims; i++) {
						im_widths[i] = width_div;
						im_heights[i] = scale_h;
					}
				}
				
				else {
					extra_h = pp_height - first_y - (2 * scale_h);
					extra_h_div = extra_h / 2;
					for (i=0; i<r1_ims; i++) {
						im_ys[i] = first_y;
					}
					for (i=r1_ims; i<num_ims; i++) {
						im_ys[i] = first_y + scale_h + extra_h_div;
					}
					
					if (r1_ims > r2_ims) {
						im_xs[0] = 0;
						for (i=1; i<r1_ims; i++) {
							im_xs[i] = im_xs[i-1] + width_div;
						}
						extra_width_r2 = pp_width - (width_div * r2_ims);
						extra_width_div_r2 = extra_width_r2 / (r2_ims + 1);
						im_xs[r1_ims] = extra_width_div_r2;
						for (i=r2_ims; i<num_ims; i++) {
							im_xs[i] = im_xs[i-1] + width_div + extra_width_div_r2;
						}
					}
					else {
						im_xs[r1_ims] = 0;
						for (i=r2_ims; i<num_ims; i++) {
							im_xs[i] = im_xs[i-1] + width_div;
						}
						extra_width_r1 = pp_width - (width_div * r1_ims);
						extra_width_div_r1 = extra_width_r1 / (r1_ims + 1);
						im_xs[0] = extra_width_div_r1;
						for (i=1; i<r1_ims; i++) {
							im_xs[i] = im_xs[i-1] + width_div + extra_width_div_r1;
						}
					}
					for (i=0; i<num_ims; i++) {
						im_widths[i] = width_div;
						im_heights[i] = scale_h;
					}
				}
				for (im=0; im<num_ims; im++) {
					open(im_dir+im_list[im]);
					width = im_widths[im];
					height = im_heights[im];
					run("Size...", "width=width height=height constrain average=true interpolation=Bilinear");
					Image.copy;
					close();
					selectWindow(pp_image);
					Image.paste(im_xs[im], im_ys[im]);
					run("Collect Garbage");
					run("Collect Garbage");
				}
			}
			
			else if (equal_row_widths) {
				r1_width = r1_ims * im_width;
				r2_width = r2_ims * im_width;
				unscaled_width = maxOf(r1_width, r2_width);
				r1_scale_factor = unscaled_width / r1_width;
				r2_scale_factor = unscaled_width / r2_width;
				scale_h_r1 = im_height * r1_scale_factor;
				scale_h_r2 = im_height * r2_scale_factor;
				r1_width_eq = r1_scale_factor * r1_width;
				r2_width_eq = r2_scale_factor * r2_width;
				scale_factor = pp_width / unscaled_width;
				scale_h_r1 = scale_h_r1 * scale_factor;
				scale_h_r2 = scale_h_r2 * scale_factor;
				if ((first_y + scale_h_r1 + scale_h_r2) > pp_height) {
					im_height_combined = scale_h_r1 + scale_h_r2;
					scale_factor = (pp_height - first_y) / im_height_combined;
					scale_h_r1 = scale_h_r1 * scale_factor;
					scale_h_r2 = scale_h_r2 * scale_factor;
				}
				r1_width_eq = r1_width_eq * scale_factor;
				r2_width_eq = r2_width_eq * scale_factor
				r1_width_div = r1_width_eq / r1_ims;
				r2_width_div = r2_width_eq / r2_ims;
				
				im_xs = newArray(num_ims);
				im_ys = newArray(num_ims);
				im_widths = newArray(num_ims);
				im_heights = newArray(num_ims);
				
				extra_width = pp_width - r1_width_eq;
				extra_width_div = extra_width / 2
				
				im_xs[0] = extra_width_div;
				im_xs[r1_ims] = extra_width_div;
				
				for (i=1; i<r1_ims; i++) {
					im_xs[i] = im_xs[i-1] + r1_width_div;
				}
				for(i=r2_ims; i<num_ims; i++) {
					im_xs[i] = im_xs[i-1] + r2_width_div;
				}
				
				for (i=0; i<r1_ims; i++) {
					im_ys[i] = first_y;
				}
				for(i=r1_ims; i<num_ims; i++) {
					im_ys[i] = first_y + scale_h_r1;
				}
				
				for (i=0; i<r1_ims; i++) {
					im_widths[i] = r1_width_div;
					im_heights[i] = scale_h_r1
				}
				for(i=r1_ims; i<num_ims; i++) {
					im_widths[i] = r2_width_div;
					im_heights[i] = scale_h_r2;
				}
				
				for (im=0; im<num_ims; im++) {
					open(im_dir+im_list[im]);
					width = im_widths[im];
					height = im_heights[im];
					run("Size...", "width=width height=height constrain average=true interpolation=Bilinear");
					Image.copy;
					close();
					selectWindow(pp_image);
					Image.paste(im_xs[im], im_ys[im]);
					run("Collect Garbage");
					run("Collect Garbage");
				}
			}
		}
		else {
			width_div = pp_width / r1_ims;
			scale_factor = width_div / im_width;
			scaled_h = im_height * scale_factor;
			im_xs = newArray(num_ims);
			im_ys = newArray(num_ims);
			im_heights = newArray(num_ims);
			if ((first_y + (2 * scaled_h)) > pp_height) {
				height_div = (pp_height - first_y) / 2;
				scale_factor = height_div / scaled_h;
				width_div = width_div * scale_factor;
				extra_width = pp_width - (r1_ims * width_div)
				extra_width_div = extra_width / (r1_ims + 1);
				im_xs[0] = extra_width_div;
				im_ys[0] = first_y;
				for (i=1; i<r1_ims; i++) {
					im_xs[i] = im_xs[i-1] + width_div;
					im_ys[i] = first_y;
				}
				for (i=r1_ims; i<num_ims; i++) {
					im_xs[i] = im_xs[i-r1_ims];
					im_ys[i] = first_y + height_div;
				}
				for (i=0; i<num_ims; i++) {
					im_heights[i] = height_div;
				}
			}
			im_xs[0] = 0;
			for (i=1; i<r1_ims; i++) {
					im_xs[i] = im_xs[i-1] + width_div;
					im_ys[i] = first_y;
			}
			for (i=r1_ims; i<num_ims; i++) {
				im_xs[i] = im_xs[i-r1_ims];
				im_ys[i] = first_y + scaled_h;
			}
			for (i=0; i<num_ims; i++) {
				im_heights[i] = scaled_h;
			}
			for (im=0; im<num_ims; im++) {
				open(im_dir+im_list[im]);
				height = im_heights[im];
				run("Size...", "width=width_div height=height constrain average=true interpolation=Bilinear");
				Image.copy;
				close();
				selectWindow(pp_image);
				Image.paste(im_xs[im], im_ys[im]);
				run("Collect Garbage");
				run("Collect Garbage");
			}
		}
	}
	
	save(im_dir+filename);
	run("Collect Garbage");
	run("Collect Garbage");
	exit("Saved New Image");
}
