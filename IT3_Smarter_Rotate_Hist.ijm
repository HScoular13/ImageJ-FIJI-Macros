macro "Smarter Rotate Hist" {
	requires("1.33o");
	getLine(x1, y1, x2, y2, lineWidth);
	if (x1==-1)
		exit("This macro requires a straight line selection");
	angle = (180.0/PI)*atan2(y1-y2, x2-x1);
	if (getBoolean("Tissue upside down?"))
		angle += 180;
	run("Arbitrarily...", "angle="+angle+" interpolate");

	waitForUser("Draw Box Around Tissue");
	full_file_name = getTitle();
	file_name_split = split(full_file_name, ".");
	file_name_noex = file_name_split[0];
	file_ex_dot = replace(full_file_name, file_name_noex, "");
//	file_ex = replace(file_ex_dot, ".", "");
	run("Crop");
	new_file_name = file_name_noex+"rotated"+file_ex_dot;
	directory = File.getDefaultDir;
	save(directory+new_file_name);
	File.close(f);
	exit("Saved new image");
}