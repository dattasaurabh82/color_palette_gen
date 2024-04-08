import drop.*;

/*
  Context: An appplet to generate color palettes based on an image
 Loc: Berlin, Germany
 Author: Saurabh Datta (Prophet GMBH)
 Date: May 2024
 */

SDrop drop;

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
String promptText = "Drop an image here";


void setup() {
  // Applet setup
  size(640, 480);
  background(0);

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
    resizeAndDrawImg(m);
  } else {
    // Prompt Space for user to "drop a file"
    displayImgLoadPromnpt();
  }

  // Lower "control area" divider (footer section) of the applet
  strokeWeight(0.5);
  stroke(255);
  line(0, adjustedAppletHeight, width, adjustedAppletHeight);


  //fill(255);
  //text(str(mouseX)+", "+str(mouseY), mouseX+10, mouseY-10);
}

void mousePressed() {
  if (overBrowseLink) {
    selectInput("Select an image", "fileSelected");
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
}


// Display Prompt for user to drop image
void displayImgLoadPromnpt() {
  noStroke();
  fill(30);
  rectMode(CENTER);
  rect(width/2, height/2 - footerHeight/2-10, width/2+50, width/2);
  fill(255);
  textSize(textSizePxL);
  //textMode(SHAPE);
  textAlign(CENTER);
  text(promptText, width/2, height/2 - footerHeight/2-textSizePxL/2);
  textSize(textSizePxM);
  text("or", width/2, height/2 - footerHeight/2+textSizePxL/2);


  if (overBrowseLink) {
    fill(#00ABD3);
    stroke(#00ABD3);
  } else {
    fill(255);
    stroke(255);
  }
  text("browse", width/2, height/2 - footerHeight/2+(textSizePxL/2*3));
  strokeWeight(1);
  line(292, 240, 346, 240);

  noFill();
}



// Callback for detecting drop event of image file
void dropEvent(DropEvent theDropEvent) {
  // if the dropped object is an image, then load the image.
  if (theDropEvent.isImage()) {
    println("\n\nisImage():\t" + theDropEvent.isImage());
    println("> loading image ...");
    m = theDropEvent.loadImage();
    getImgData = true;
  } else {
    // show user that it wasn't an image
    promptText = "Not image! Try again!";
    println(promptText);
  }
}

// Callback for window based image file selection
void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
  }
}


// Display function of image and upon when the image has been dropped
void resizeAndDrawImg(PImage img) {
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
  image(img, (width - m.width) / 2, adjustedAppletHeight/2-img.height/2);
}
