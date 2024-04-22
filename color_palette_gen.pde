/*
    @Context    An appplet (main entry point) to generate color palettes based on an image and send the palettes to th DMX/Art-Net
    @Location   Berlin, Germany
    @author     Saurabh Datta (Prophet GMBH)
    @Date       April 2024
 */


String FilePath = "";
boolean imgIsFile, imgIsURL;


/* ----- UI related ------ */
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.net.*;
import java.util.regex.*;

boolean isMac, isWin, isNix;

String clipboardText = "";
String imgURL = "";
String pastePromptTxt = "";
boolean loadImgFromUrl = false;

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

int heightOfPaletteCell = 64;


import processing.data.JSONObject;
import processing.data.*;
JSONArray palette;
/* ------------------------------ */


void setup() {
    // Applet setup
    size(640, 480);
    background(0);

    detectOs();
    if (isMac || isNix) {
        pastePromptTxt = "or\npaste an image URL (cmd+v)";
    } else if (isWin) {
        pastePromptTxt = "or\npaste an image URL (ctrl+v)";
    }

    cp5 = new ControlP5(this);
    cp5.enableShortcuts();

    myConsole = cp5.addTextarea("txt")
        .setPosition(5, 0)
        .setSize(300, 250)
        .setFont(createFont("", 9))
        .setLineHeight(12)
        .setColor(color(255))
        .setColorBackground(color(0, 150))
        .setColorForeground(color(255));
    ;
    if (debugView) {
        myConsole.show();
    } else {
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

    // image laoding method for Drop event and File selection
    if (m != null && m.width > 0) {
        resizeAndDisplayImg(m);       // resizes and center places the loaded image 
        displayClearImageText();      // user prompt as "clear" the image
        displayColorPalette(colors);  // shows the generated color scheme/palettes at the bottom
    } else {
        displayImgLoadPrompt();       // shows prompt for user to "drop a file"
    }

    // image loading method for Pasted URL
    if (loadImgFromUrl && clipboardText != null && clipboardText.length() > 0) {
        loadImgFromUrl = false;
        // 1. download the image in Data folder with a specific name
        m = null;       // set the img object to null
        FilePath = "";  // reste FilePath
        getImgData = false;
        m = loadImage(clipboardText, "png"); // then load the img (blocking)
        m.save("data/webImg.png");
        // 2. Load the image now
        m = loadImage("webImg.png");
        // 3. assign it to the global var "FilePath" for the palette generator
        FilePath = sketchPath() + "/data/webImg.png";
        // 4. Tell the sketch to rpoceed to resizing, etc. now
        getImgData = true;
    }

    // Visual divider for Lower "control area" (footer section) of the applet
    strokeWeight(0.5);
    stroke(255);
    line(0, adjustedAppletHeight, width, adjustedAppletHeight);

    // keyboard shortcut info on screen
    textAlign(CENTER);
    textSize(12);
    fill(255);
    text("L: Load Img,  P: Create Palette,   C: Clear Img,   D: Toggle Debug View,  0: Clear Console", width/2, height-8);
}



void keyPressed(KeyEvent event) {
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
    if (key == 'd' || key == 'D') {
        debugView = !debugView;
        if (debugView) {
            myConsole.show();
        } else {
            myConsole.hide();
        }
    }
    if (key == '0') {
        console.clear();
    }

    // Check if Ctrl+V or Cmd+V is pressed
    if ((key == 'v' || key == 'V') && (event.isControlDown() || event.isMetaDown())) {
        // Access the system clipboard
        Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
        Transferable contents = clipboard.getContents(null);

        // Check if clipboard contains text
        if (contents != null && contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
            try {
                // Get the text from the clipboard
                clipboardText = (String)contents.getTransferData(DataFlavor.stringFlavor);
                print("Pasted String: ");
                println(clipboardText);
                print("Is Img URL: ");
                println(isImageUrl(clipboardText));

                if (isImageUrl(clipboardText)) {
                    loadImgFromUrl = true;
                } else {
                    loadImgFromUrl = false;
                }
            } 
            catch (Exception e) {
                e.printStackTrace();
            }
        }
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
        
        imgIsFile = true;
        imgIsURL = false;

        println("\nLoading image ...");
    } else {
        // show user that it wasn't an image
        promptText = "\nNot image! Try again!";
        println(promptText);

        imgIsFile = false;
        imgIsURL = false;
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
            
            imgIsFile = true;
            imgIsURL = false;
            
            println("\nLoading image ...");
        } else {
            // show user that it wasn't an image
            promptText = "\nNot image! Try again!";
            println(promptText);

            imgIsFile = false;
            imgIsURL = false;
        }
    } else {
        println("Image selection was cancelled! Try again?");

        imgIsFile = false;
        imgIsURL = false;
    }
}

