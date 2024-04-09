/*
  @Context An appplet to generate color palettes based on an image
  @Location Berlin, Germany
  @author Saurabh Datta (Prophet GMBH)
  @Date May 2024
 */


String FilePath = "";

/* ---- UI related ----- */
boolean isMac, isWin, isNix;

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

boolean overBrowseLink = false;
boolean overClearText = false;
String promptText = "Drop an image here";

color highlightColor = unhex("FF00FFB5");  // Add 'FF' at the beginning for the alpha channel
/* ----------------------- */


/* -- color extraction related -- */
import jto.colorscheme.*;

ColorScheme cs;

/* ------------------------------ */


void setup() {
  // Applet setup
  size(640, 480);
  background(0);

  // checkOS();

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
    resizeAndDisplayImg(m);
    displayClearImageText();
    // [TBD] Show color palette 
  } else {
    // Prompt Space for user to "drop a file"
    displayImgLoadPrompt();
  }

  // Visual divider for Lower "control area" (footer section) of the applet
  strokeWeight(0.5);
  stroke(255);
  line(0, adjustedAppletHeight, width, adjustedAppletHeight);
}


void keyPressed(){
  if(key == 'l' || key == 'L'){
    selectInput("Select an image", "fileSelected");
  }

  if(key == 'c' || key == 'C'){
    println("\nclearing up image ...");
    m = clearImg(m);
    FilePath = ""; // reset the file Path global var
  }

  if(key == 'p' || key == 'P'){
    println("Preparing color palette ...");
    // [TBD]
    generatePalette(FilePath);
  }
}


void mousePressed() {
  if (overBrowseLink) {
    selectInput("Select an image", "fileSelected");
  }
  if(overClearText){
    println("\nclearing up image ...");
    m = clearImg(m);
  }
}

void mouseMoved() {
  checkOverText();
}

void mouseDragged() {
  checkOverText();
}

void checkOverText() {
  if (mouseX >= 292 && mouseX <= 348 && mouseY >= 230 && mouseY <= 248) {
    overBrowseLink = true;
  } else {
    overBrowseLink = false;
  }

  if (m != null){
    if(mouseX >= width/2+(m.width/2-60) && mouseX <= width/2+m.width/2 && mouseY >= padding+10 && mouseY <= padding*3){
      overClearText = true;
    }else{
      overClearText = false;
    }
  }else{
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
  text("browse", width/2, height/2 - footerHeight/2+(textSizePxL/2*3));
  strokeWeight(1);
  line(290, 240, 350, 240);
  fill(255);
  text("or Press \"L\"", width/2, height/2 - footerHeight/2+(textSizePxL*3));

  noFill();
}


// Display Prompt for user to clear the image
void displayClearImageText(){
  if (overClearText) {
    fill(highlightColor);
  } else {
    fill(150);
  }
  textAlign(RIGHT);
  textSize(14);
  text("CLEAR", width/2+(m.width/2-10), padding*2);
}



// Callback for detecting drop event of image file
public void dropEvent(DropEvent theDropEvent) {
  // Check if the dropped object is an image and if so, load it
  if (theDropEvent.isImage()) {
    m = theDropEvent.loadImage();
    getImgData = true;

    // Once ensured that this file is an image,
    // assign it to the global var "FilePath" for the palette generator
    // println(theDropEvent.file()); // [TBD/WIP] returns a path

    println("\nLoading image ...");
  } else {
    // show user that it wasn't an image
    promptText = "\nNot image! Try again!";
    println(promptText);
  }
}


// Callback for window based image file selection (image file)
public void fileSelected(File selection) {
  // Check if a file was selected, then check if it is an image and if so, load it
  if (selection != null){
    if(selectionIsImage(selection)){
      m = loadImage(selection.getAbsolutePath());
      getImgData = true;

      // Once ensured that this file is an image,
      // assign it to the global var "FilePath" for the palette generator
      FilePath = selection.getAbsolutePath();

      println("\nLoading image ...");
    }else{
      // show user that it wasn't an image
      promptText = "\nNot image! Try again!";
      println(promptText);
    }
  }else{
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


void generatePalette(String filePath){
  // check if the file exists
  File f = new File(filePath);
  if (f.exists()) {
    println("The file exists.");
    println(filePath);

    // create our color scheme object
    cs = new ColorScheme(filePath, this);

    // get the list of colors from the color scheme
    color[] colors = cs.toArray();

    // print the colours [Debug]
    // int middleIndex = colors.length / 2;
    // println(colors.length, middleIndex);
    for (int i = 0; i < colors.length; i++) {
      println(hex(colors[i]));
    }
  } else {
    println("The image file does not exist.");
    println("Can't proceed for palette Generation ...");
  }

  // if(isMac || isNix){
  //   // diff space handling method ...
  // }else if (isWin){ 
  //   // diff space parsing method ...
  // }else{
  //   println("Further processes not possible");
  //   exit();
  // }
}


// void checkOS(){
//   if (platform == PConstants.WINDOWS) {
//     println("OS: Windows");
//     isWin = true;
//     isMac = false;
//     isNix = false;
//   } else if (platform == PConstants.MACOSX) {
//     println("OS: Mac OS");
//     isWin = false;
//     isMac = true;
//     isNix = false;
//   } else if (platform == PConstants.LINUX) {
//     println("OS: Some Linux ...");
//     isWin = false;
//     isMac = false;
//     isNix = true;
//   }else{
//     println("OS: Unknown ...");
//     isWin = false;
//     isMac = false;
//     isNix = false;
//   }
// }