/*
 @Context    Supporting Utils to hold direct UI related functions for the color palette gen project
 @Location   Berlin, Germany
 @author     Saurabh Datta
 @Date       April 2024
 */

// Display Prompt for user to drop image
void displayImgLoadPrompt() {
    noStroke();
    fill(30);
    rectMode(CENTER);
    rect(width/2, height/2 - footerHeight/2-10, width/2+50, width/2);
    imageMode(CENTER);
    image(loadImageIcon, width/2, height/2-125);
    fill(255);
    textSize(textSizePxL);
    textAlign(CENTER);
    text(promptText, width/2, height/2 - footerHeight/2-textSizePxL/2);
    textSize(textSizePxM);
    text("or", width/2, height/2 - footerHeight/2+textSizePxL/2);
    if (overBrowseLink) {
        fill(highlightColor);
        stroke(highlightColor);
    } else {
        fill(255);
        stroke(255);
    }
    browserStrWidth = textWidth(browseStr);
    browserStrX = width/2;
    browserStrY = height/2 - footerHeight/2+(textSizePxL/2*3);
    text(browseStr, browserStrX, browserStrY);
    strokeWeight(1);
    line(width/2-browserStrWidth/2, browserStrY+2, width/2+browserStrWidth/2, browserStrY+2);

    fill(255);
    text(pastePromptTxt, width/2, height/2 - footerHeight/2+(textSizePxL*3));

    noFill();
}




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




void generatePalette(String filePath) {
    // check if the file exists
    File f = new File(filePath);
    if (f.exists()) {
        println("The file exists.");
        println(filePath);
        println("Preparing color palette ...");
        try {
            // create our color scheme object
            cs = new ColorScheme(filePath, this);
            // get the list of colors from the color scheme
            colors = cs.toArray();
            println("Color palette (and scheme) prepared!");
            println("\nYou can now cycle through schemes");

            // Create a JSONArray to store color objects
            palette = new JSONArray();

            // Print RGB values for each color
            for (int i = 0; i < colors.length; i++) {
                color c = colors[i];
                String ch = hex(c);
                int r = int(red(c));
                int g = int(green(c));
                int b = int(blue(c));

                println(String.valueOf(r) + ", " + String.valueOf(g) + ", " + String.valueOf(b) + ", " + ch);

                // Create a JSONObject for each color
                JSONObject colorObj = new JSONObject();
                colorObj.setInt("r", r);
                colorObj.setInt("g", g);
                colorObj.setInt("b", b);
                colorObj.setString("hex", ch);

                // Add the color object to the palette array
                palette.setJSONObject(i, colorObj);
            }

            // Print the JSON object
            // println(palette);

            // Check if the palette array is not empty
            println("");
            if (palette.size() > 0) {
                // Convert the JSON array to a string
                String jsonString = palette.toString();
                try {
                    // Save the JSON string to the sketch's data folder
                    saveStrings("data/curr_palette.json", new String[]{jsonString});
                    println("Palette JSON object saved successfully.");
                }
                catch(Exception e) {
                    println("Palette JSON object could not be writtent o a file");
                }
            } else {
                println("Palette JSON object is empty. Not saved.");
            }
        } 
        catch (OutOfMemoryError e) {
            // Handle the OutOfMemoryError
            println("Ran out of memory!\nImage too big and the respectivce color array is LAAARRGEEE ...");
            resetParameters();
            // You can add more error handling code here
        } 
        catch (Exception e) {
            // Handle other exceptions
            e.printStackTrace();
            resetParameters();
        }
    } else {
        println("The image file does not exist.");
        println("Can't proceed for palette Generation ...");
    }
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
