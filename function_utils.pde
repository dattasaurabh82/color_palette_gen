

boolean isImageUrl(String urlString) {
    try {
        URL url = new URL(urlString);
        String file = url.getFile();

        // Define regular expression pattern to match common image file extensions
        Pattern pattern = Pattern.compile("\\.(jpg|jpeg|png|gif|bmp)$", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(file);

        // Check if URL ends with a known image file extension
        if (matcher.find()) {
            return true;
        }

        // Check if URL contains image-related query parameters
        String query = url.getQuery();
        if (query != null && (query.contains("format=image") || query.contains("auto=format"))) {
            return true;
        }

        // Check if URL contains a known image path
        if (file.endsWith("/photo") || file.contains("/photos/") || file.contains("/images/")) {
            return true;
        }

        // download the image
        // TBD []

        imgIsFile = false;
        imgIsURL = true;

        return false;
    } 
    catch (MalformedURLException e) {
        imgIsFile = false;
        imgIsURL = false;
        
        // URL is not valid
        return false;
    }
}


void detectOs() {
    if (platform == PConstants.WINDOWS) {
        isMac = false;
        isWin = true;
        isNix = false;
    } else if (platform == PConstants.MACOSX) {
        isMac = true;
        isWin = false;
        isNix = false;
    } else if (platform == PConstants.LINUX) {
        isMac = false;
        isWin = false;
        isNix = true;
    }
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