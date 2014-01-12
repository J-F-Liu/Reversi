import 'dart:html';
import 'dart:async';

class GameClient {

  WebSocket webSocket;

  Future<bool> connectServer(String serverUrl){
    Completer<bool> completer = new Completer<bool>();
    webSocket = new WebSocket(serverUrl);

    webSocket.onMessage.listen((MessageEvent e) {
      receivedData(e.data);
    });

    webSocket.onOpen.first.then((_){
      if (webSocket.readyState == WebSocket.OPEN) {
        webSocket.send("connect reversi");
        completer.complete(true);
      } else {
        print('WebSocket server can not be connected.');
        completer.complete(false);
      }
    });

    webSocket.onError.first.then((Event e) {
      print('WebSocket server $serverUrl can not be connected.');
      completer.complete(false);
    });

    return completer.future;
  }

  void sendData(data) {
    webSocket.send(data);
  }

  Function receivedData;
}