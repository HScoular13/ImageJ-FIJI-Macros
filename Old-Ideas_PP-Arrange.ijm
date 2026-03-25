macro "PowerPoint_Arranger-DiscardedIdeas" {
	
	// This does not actually do anything 
	// just wanted to store old ideas for reference
	
	if ((row1_ims+row2_ims) != num_ims) {
		Dialog.create("Warning");
		Dialog.addMessage(
			"Inputted number of images does not match\nnumber of images in folder"
			)
		Dialog.addMessage(
			"Continuing will most likely cause an error"
	}
	print(grid_rows+" ", row1_ims+" ", row2_ims);

	if (num_ims > 3) {
		Dialog.create("Image Layout");
		Dialog.addMessage("How do you want the images arranged?");
		check_rows = 2;
		check_cols = round(num_ims / 2);
		check_labels = newArray(num_ims);
		check_states = newArray(num_ims);
		
		for (i=0; i<num_ims; i++) {
			check_labels[i] = "Position "+(i+1);
			check_states[i] = false;
		}
		
		Dialog.addCheckboxGroup(check_rows, check_cols, check_labels, check_states);
		Dialog.show();
		checkbox_states = newArray(num_ims);
		for (i=0; i<num_ims; i++) {
			checkbox_states[i] = Dialog.getCheckbox();
		}
		Array.print(checkbox_states);
		
		if (num_ims == 4) {
			Dialog.create("Message");
			Dialog.addMessage("How do you want the images arranged?");
			Dialog.addChoice("Layout", newArray("1x4", "2x2");
			Dialog.show();
			print("Continued");
			user_choice = Dialog.getChoice();
		}
	}
}
