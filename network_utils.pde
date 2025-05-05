/*
 @Context    Supporting Utils to hold Network and comms related functions for the color palette gen project
 @Location   Berlin, Germany
 @author     Saurabh Datta
 @Date       April 2024
 */


// ----------- WEBSOCKETS -------------- //
import websockets.*;

WebsocketClient wsc;


void setupSocksClient(String URL, int PORT, String HEADER) {
    String subs_url = "ws://" + URL + ":" + str(PORT) + "/" + HEADER;
    wsc = new WebsocketClient(this, subs_url);
}

// void setupSecureSocksClient(String URL, int PORT, String HEADER) {
//     String subs_url = "wss://" + URL + ":" + str(PORT) + "/" + HEADER;
//     wsc = new WebsocketClient(this, subs_url);
// }


// Method to read a message to the server
void webSocketEvent(String msg) {
    println("[Web Sockets] Received msg:", msg);
}

// Method to send a message to the server
void socketSendMessage(String message) {
    wsc.sendMessage(message);
    // wsc.sendMessageTo("message", "userID");
    // wsc.sendMessageTo(byteArray, "userID");
}



// ---------------- MQTT --------------- // 
// import mqtt.*;
// MQTTClient mqttc;

// void setupMQTTClient() {
// }
