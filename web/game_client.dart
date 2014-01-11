import 'dart:html';
import 'dart:async';

class GameClient {

  WebSocket webSocket;

  void connectServer(String serverUrl){
    webSocket = new WebSocket(serverUrl);
    webSocket.onOpen.first.then((_){
      if (webSocket.readyState == WebSocket.OPEN) {
        webSocket.send("connect reversi");
      } else {
        print('WebSocket server can not be connected.');
      }

      webSocket.onMessage.listen((MessageEvent e) {
        receivedData(e.data);
      });

    });
  }

  void sendData(data) {
    webSocket.send(data);
  }

  Function receivedData;
}