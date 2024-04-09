/*
  @Context An appplet to generate color palettes based on an image
 @Location Berlin, Germany
 @author Saurabh Datta (Prophet GMBH)
 @Date May 2024
 */


String FilePath = "";

/* ---- UI related ----- */
// boolean isMac, isWin, isNix;
import controlP5.*;
ControlP5 cp5;
Textarea myConsole;
int c = 0;
Println console;
boolean debugView = true;

import drop.*;
SDrop drop;

PImage loadImageIcon;
PImage m;

boolean getImgData = false;
int loadingCounter = 0;

int footerHeight = 80;
int padding = 20;
int adjustedAppletWidth = 0;
int adjustedAppletHeight = 0;
int bottomLineY = 0;

int textSizePxL = 24;
int textSizePxM = 18;

String browseStr = "browse";
float browserStrX, browserStrY, browserStrWidth;
boolean overBrowseLink = false;

String clrStr = "CLEAR";
float clrStrX, clrStrY, clrStrWidth;
boolean overClearText = false;

String promptText = "Drop an image here";

color highlightColor = unhex("FF00FFB5");  // Add 'FF' at the beginning for the alpha channel
/* ----------------------- */


/* -- color extraction related -- */
import jto.colorscheme.*;
ColorScheme cs;

color[] colors;
boolean colArrIsNonZero = false;
/* ------------------------------ */


void setup() {
    // Applet setup
    size(640, 480);
    background(0);

    cp5 = new ControlP5(this);
    cp5.enableShortcuts();

    myConsole = cp5.addTextarea("txt")
        .setPosition(5, 5)
        .setSize(250, 250)
        .setFont(createFont("", 9))
        .setLineHeight(12)
        .setColor(color(200))
        .setColorBackground(color(0, 100))
        .setColorForeground(color(255, 100));
    ;
    if(debugView){
      myConsole.show();
    }else{
      myConsole.hide();
    }
    console = cp5.addConsole(myConsole);

    // Inititlaize color palette array to zeros
    colors = new color[0];

    loadImageIcon = loadImage("img_icon_mint.png");
    loadImageIcon.resize(0, 75);

    // Calculations for image positioning in the applet (after it has loaded)
    adjustedAppletWidth = width - padding * 2;
    bottomLineY = height - footerHeight;
    adjustedAppletHeight = bottomLineY - padding;

    // "File drop" object initialization
    drop = new SDrop(this);

    smooth();
}


void draw () {
    background(0);

    if (m != null) {
        resizeAndDisplayImg(m);       // resizes and center places the loaded image 
        displayClearImageText();      // user prompt as "clear" the image
        displayColorPalette(colors);  // shows teh generated color scheme/palettes at the bottom
    } else {
        displayImgLoadPrompt();       // shows prompt for user to "drop a file"
    }

    // Visual divider for Lower "control area" (footer section) of the applet
    strokeWeight(0.5);
    stroke(255);
    line(0, adjustedAppletHeight, width, adjustedAppletHeight);
}


void keyPressed() {
  if (key == 'l' || key == 'L') {
    selectInput("Select an image", "fileSelected");
  }

  if (key == 'c' || key == 'C') {
    resetParameters();
  }

  if (key == 'p' || key == 'P') {
    generatePalette(FilePath);
  }

  // for console
  if(key == 'd' || key == 'D'){
    debugView = !debugView;
    if(debugView){
      myConsole.show();
    }else{
      myConsole.hide();
    }
  }
  if(key == '0'){
    console.clear();
  }
}


void mousePressed() {
    if (overBrowseLink) {
        selectInput("Select an image", "fileSelected");
    }
    if (overClearText) {
        resetParameters();
    }
}

void mouseMoved() {
    checkOverText();
}

void mouseDragged() {
    checkOverText();
}


void resetParameters() {
    println("\nclearing up image & reseting things ...");
    m = clearImg(m);          // make the image object null
    FilePath = "";            // reset the file Path global var
    cs = null;                // reset the color scheme object to null
    colors = new color[0];    // re-initialize color palette array to all zeros
    colArrIsNonZero = false;  //
}

void checkOverText() {
    // line(width/2-browserStrWidth/2, browserStrY+2, width/2+browserStrWidth/2, browserStrY+2);
    if (mouseX >= width/2-browserStrWidth/2 && mouseX <= width/2+browserStrWidth/2 && mouseY >= browserStrY-10 && mouseY <= browserStrY+2) {
        overBrowseLink = true;
    } else {
        overBrowseLink = false;
    }

    if (m != null) {
        //  text(clrString, width-(clrStringWidth+10), adjustedAppletHeight-5);
        if (mouseX >= clrStrX && mouseX <= clrStrX+clrStrWidth && mouseY >= clrStrY-20 && mouseY <= clrStrY) {
            overClearText = true;
        } else {
            overClearText = false;
        }
    } else {
        overClearText = false;
    }
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
    text("or Press \"L\"", width/2, height/2 - footerHeight/2+(textSizePxL*3));

    noFill();
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



// Callback for detecting drop event of image file
public void dropEvent(DropEvent theDropEvent) {
    // Check if the dropped object is an image and if so, load it
    if (theDropEvent.isImage()) {
        m = theDropEvent.loadImage();
        // Once ensured that this file is an image,
        // assign it to the global var "FilePath" for the palette generator
        FilePath = theDropEvent.file().getAbsolutePath();
        // println(FilePath);
        getImgData = true;   // this var is used to ensure that image has been loaded now grab info to do resizing if needed
        println("\nLoading image ...");
    } else {
        // show user that it wasn't an image
        promptText = "\nNot image! Try again!";
        println(promptText);
    }
}


// Callback for window based image file selection (image file)
public void fileSelected(File selection) {
    if (selection != null) {
        // check it is an image or not
        if (selectionIsImage(selection)) {
            // Once ensured that this file is an image,
            m = loadImage(selection.getAbsolutePath());
            // assign it to the global var "FilePath" for the palette generator
            FilePath = selection.getAbsolutePath();
            getImgData = true;   // this var is used to ensure that image has been loaded now grab info to do resizing if needed
            println("\nLoading image ...");
        } else {
            // show user that it wasn't an image
            promptText = "\nNot image! Try again!";
            println(promptText);
        }
    } else {
        println("Image selection was cancelled! Try again?");
    }
}



// Custom function to check file type 
public boolean selectionIsImage(File file) {
    String[] imgExtensions = {"jpg", "jpeg", "png", "gif", "bmp"};
    String fileName = file.getName();
    String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    for (String ext : imgExtensions) {
        if (extension.equals(ext)) {
            return true;
        }
    }
    return false;
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
            rect(x, adjustedAppletHeight, x + widthOfCell, 64);
        }
    }
}
