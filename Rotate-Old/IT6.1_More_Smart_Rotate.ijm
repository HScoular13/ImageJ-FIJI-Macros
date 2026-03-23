macro "Image Flipper" {
	origIM = getTitle();
	origH = Image.height;
	origW = Image.width;
	
	run("Duplicate...", "title=flipper");
	newW = origW*0.05;
	newH = origH*0.05;
	run("Select None");
	run("Size...", "width=newW height=newH average=true interpolation=Bilinear");
	
	halfH = newH / 2;
	
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
	
	selectWindow(origIM);
	
	if (color2 > color1) {
		run("Flip Vertically");
	}
}
