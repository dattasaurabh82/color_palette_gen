

// --
PImage clearImg(PImage img) {
    if (img == null) {
        println("There was no image to be cleared ...");
        return null;
    } else {
        img = null;
        System.gc(); // garbage collection
        println("Image cleared up!");
        return img;
    }
}

// Display Prompt for user to clear the image
void displayClearImageText() {
    if (overClearText) {
        fill(highlightColor);
    } else {
        fill(150);
    }
    textAlign(LEFT);
    textSize(14);

    clrStrWidth = textWidth(clrStr);
    clrStrX = width-(clrStrWidth+12);
    clrStrY = adjustedAppletHeight-5;
    text(clrStr, clrStrX, clrStrY);
}


// Display function of image and upon when the image has been dropped
public void resizeAndDisplayImg(PImage img) {
    if (getImgData) {
        // ** We are using a counter, to pass few cycles, as the image doesn't get loaded immediately
        loadingCounter++;
        if (loadingCounter == 20) {
            println("orig img w:", img.width, " orig img h:", img.height);
            // Business logic for resizing image
            if (img.width > adjustedAppletWidth || img.height > adjustedAppletHeight) {
                // Check if the image is larger than the adjusted dimensions
                float aspectRatio = float(img.width) / img.height;  // Calculate aspect ratio of the image

                if (aspectRatio > 1) {
                    // Image is wider than tall
                    img.resize(adjustedAppletWidth, 0);  // Resize width to fit adjusted width, height will be auto-calculated
                } else {
                    // Image is taller than wide or square
                    img.resize(0, adjustedAppletHeight);  // Resize height to fit adjusted height, width will be auto-calculated
                }
                println("resized img w:", img.width, " resized img h:", img.height);
            } else {
                println("No resizing needed ...");
            }
            loadingCounter = 0;
            getImgData = false;
        }
    }
    // Draw the image
    imageMode(CORNER);
    image(img, (width - m.width) / 2, adjustedAppletHeight/2-img.height/2);
}



void displayColorPalette(color[] colors) {
    // check if the color is not black
    for (color c : colors) {
        if (c != color(0, 0, 0)) { 
            colArrIsNonZero = true;
            break;
        }
    }

    // if color scheme object is not null and if all the col elements in the the color array are non-zeros  
    if (cs != null && colArrIsNonZero) {
        for (int i = 0; i < colors.length; i++) {
            // println(hex(colors[i]));
            rectMode(CORNER);
            int widthOfCell = width/colors.length;
            int x = i*widthOfCell;

            strokeWeight(0.5);
            stroke(highlightColor);
            fill(colors[i]);
            rect(x, adjustedAppletHeight, x + widthOfCell, heightOfPaletteCell);

            if (debugView) {
                // Show the RGB on top of the color palettes
                color c = colors[i];
                String ch = hex(c);
                String r = String.valueOf(int(red(c)));
                String g = String.valueOf(int(green(c)));
                String b = String.valueOf(int(blue(c)));
                String dvColorStr = r + "," + g + "," + b;
                textSize(9);
                textAlign(CENTER);
                fill(255); // ** Adjust later based on rect color [TBD]
                text(dvColorStr, x+widthOfCell/2, adjustedAppletHeight+heightOfPaletteCell/2);
                text(ch, x+widthOfCell/2, (adjustedAppletHeight+heightOfPaletteCell/2)+10);
            }
        }
    }
}