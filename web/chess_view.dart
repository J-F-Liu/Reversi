import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'view_switcher.dart';
import 'reversi_game.dart';
import 'game_client.dart';

abstract class ChessView extends View {

  int size;
  List<Element> elements = new List<Element>();

  var chess = new ChessBoard();
  var cells = new Map<DivElement,BoardCell>();
  var blackScore = querySelector("#blackScore");
  var whiteScore = querySelector("#whiteScore");
  var message = new Element.html('<p id="message"></p>');

  ChessView(name){
    this.id = name;
    this.urlSegment = name.toString();
    this.size = ChessBoard.BoardSize;
    var board = new TableElement();
    board.id = 'board';
    for(int i=0;i<ChessBoard.BoardSize;i++){
      var row = board.addRow();
      for(int j=0;j<ChessBoard.BoardSize;j++){
        var cell = row.addCell();
        var piece = new DivElement();
        cell.children.add(piece);
        piece.onClick.listen(pieceClick);
        cells[piece] = chess.cells[i][j];
      }
    }
    elements.add(board);
    elements.add(message);
  }

  Iterable<Element> render() {
    return elements;
  }


  void updateCells(){
    cells.forEach((piece, boardCell){
      piece.classes.clear();
      if(!boardCell.isEmpty){
        piece.classes.add(boardCell.piece);
      }
    });
    blackScore.text = chess.blackScore.toString();
    whiteScore.text = chess.whiteScore.toString();
    updateMessage();
  }

  void updateMessage(){
    message.text = chess.message;
    if(chess.message.contains('无棋')){
      message.style.color = 'red';
    }else{
      message.style.color = 'black';
    }
  }

  void updateHistory(){
    window.history.pushState(chess.step, "", "#step${chess.step}");
    document.title = "$id#step${chess.step}";
  }

  void pieceClick(MouseEvent event);

  bool placePiece(piece, BoardCell boardCell){
    if(chess.placePiece(boardCell)){
      updateCells();
      piece.classes.add('last');
      return true;
    }else if(boardCell.isEmpty){
      message.text = chess.message;
      piece.classes.add('last');
    }
    return false;
  }

  void restoreGameState(PopStateEvent event){
    var step = event.state;
    if(step is int){
      chess.gotoStep(step);
      updateCells();
    }
  }
}

class HumanVsComputerChessView extends ChessView {

  var random = new Random();

  HumanVsComputerChessView(name):super(name){

    onLoad = (){
      chess.gameStart = true;
      updateCells();
      updateHistory();
      window.onPopState.listen(restoreGameState);
    };

  }

  void pieceClick(MouseEvent event) {
    if(chess.currentTurn == "black"){
      var piece = event.target;
      var boardCell = cells[piece];
      placePiece(piece, boardCell);

      while(chess.currentTurn == "white"){
        var boardCells = chess.validPlacements();
        if(boardCells.length > 0){
          boardCell = boardCells[random.nextInt(boardCells.length)];
          var piece = cells.keys.firstWhere((k)=>cells[k]==boardCell);
          placePiece(piece, boardCell);
        }else{
          break;
        }
      }

      updateHistory();
    }
  }

}

class HumanVsHumanChessView extends ChessView {

  HumanVsHumanChessView(name):super(name){

    onLoad = (){
      chess.gameStart = true;
      updateCells();
      updateHistory();
      window.onPopState.listen(restoreGameState);
    };

  }

  void pieceClick(MouseEvent event) {
    var piece = event.target;
    var boardCell = cells[piece];
    if(placePiece(piece, boardCell)){
      updateHistory();
    }
  }

}

class HumanViaNetChessView extends ChessView {

  var player = null;
  var client = new GameClient();

  HumanViaNetChessView(name, server):super(name){

    onLoad = (){
      updateCells();

      client.connectServer(server).then((success){
        if(!success){
          window.alert("无法连接服务器");
          window.history.back();
        }
      });

      client.receivedData = (data){
        var msg = JSON.decode(data);
        switch(msg['action'])
        {
          case 'open':
            chess.gameStart = true;
            updateMessage();
            break;
          case 'move':
            if(msg['player'] == chess.currentTurn){
              var boardCell = chess.cells[msg['row']][msg['col']];
              var piece = cells.keys.firstWhere((k)=>cells[k]==boardCell);
              placePiece(piece, boardCell);
            }
            break;
          case 'close':
            window.alert("对方已退出游戏");
            chess.gameOver = true;
            updateMessage();
            break;
        }
      };
    };

  }

  void pieceClick(MouseEvent event) {
    if(chess.gameStart == false){
      return;
    }
    var piece = event.target;
    var boardCell = cells[piece];
    if(player == null){
      player = chess.currentTurn;
    }
    if(player == chess.currentTurn){
      placePiece(piece, boardCell);
      var step = {'action': 'move', 'player': player, 'row':boardCell.row, 'col': boardCell.col};
      client.sendData(JSON.encode(step));
    }else{
      if(chess.tip == null){
        chess.tip = "执${player == 'black'? '黑':'白' }棋";
        message.text = chess.message;
      }
    }
  }

}