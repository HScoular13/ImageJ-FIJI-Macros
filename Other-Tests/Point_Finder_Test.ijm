macro "Point Finder Test" {
	im_dir = getDir("Pick a directory");
	im_list = getFileList(im_dir);
	num_ims = lengthOf(im_list);
	burn_center_x = newArray(num_ims);
	burn_center_y = newArray(num_ims);
	
	for (im=0; im<num_ims; im++) {
		open(im_dir+im_list[im]);
		waitForUser("Click the center of the burn, then click OK");
		getCursorLoc(point_x, point_y, z, modifiers);
		burn_center_x[im] = point_x;
		burn_center_y[im] = point_y;
		Array.print(burn_center_x);
		Array.print(burn_center_y);
		close("*");
	}
}
