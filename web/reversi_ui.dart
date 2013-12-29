import 'dart:html';
import 'reversi_game.dart';

var chess = new ChessBoard();
var cells = new Map<DivElement,BoardCell>();
var blackScore = querySelector("#blackScore");
var whiteScore = querySelector("#whiteScore");
var message = querySelector("#message");

void main() {
  TableElement board = querySelector("#board");
  for(int i=0;i<ChessBoard.BoardSize;i++){
    var row = board.addRow();
    for(int j=0;j<ChessBoard.BoardSize;j++){
       var cell = row.addCell();
       var piece = new DivElement();
       cell.children.add(piece);
       piece.onClick.listen(placePiece);
       cells[piece] = chess.cells[i][j];
    }
  }
  updateCells();
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
  message.text = chess.message;
  if(chess.message.contains('无棋')){
    message.style.color = 'red';
  }else{
    message.style.color = 'black';
  }
}

void placePiece(MouseEvent event) {
  var piece = event.target;
  var boardCell = cells[piece];
  if(chess.placePiece(boardCell)){
    updateCells();
    piece.classes.add('last');
  }else if(boardCell.isEmpty){
    message.text = chess.message;
    piece.classes.add('last');
  }
}
