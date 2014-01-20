library reversi_game;

class BoardCell {
  int row;
  int col;
  var piece;

  BoardCell(this.row, this.col);

  bool get isEmpty{
    return piece == null;
  }
}

class CellPos {
  int row;
  int col;
  CellPos(this.row, this.col);
}

class ChessBoard {
  static const BoardSize = 8;
  static const white = 'white';
  static const black = 'black';

  var currentTurn = black;
  List<List<BoardCell>> cells;
  int blackScore = 2;
  int whiteScore = 2;

  bool gameStart = false;
  bool gameOver = false;
  String tip;
  int step = 0;
  Map<int, String> history = new Map<int, String>();

  ChessBoard(){
    cells = new List<List<BoardCell>>();
    for(int i=0;i<BoardSize;i++){
      var row = new List<BoardCell>();
      for(int j=0;j<BoardSize;j++){
        var cell = new BoardCell(i, j);
        row.add(cell);
      }
      cells.add(row);
    }

    cells[3][3].piece = white;
    cells[3][4].piece = black;
    cells[4][3].piece = black;
    cells[4][4].piece = white;
    history[step] = encodeChessboard();

    tip = "游戏开始";
  }

  String encodePiece(piece){
    if(piece == white){
      return 'w';
    }else if(piece == black){
      return 'b';
    }else{
      return ' ';
    }
  }

  String decodePiece(String code){
    if(code == 'w'){
      return white;
    }else if(code == 'b'){
      return black;
    }else{
      return null;
    }
  }

  String encodeChessboard(){
    StringBuffer chars = new StringBuffer();
    for(int i=0;i<BoardSize;i++){
      for(int j=0;j<BoardSize;j++){
        chars.write(encodePiece(cells[i][j].piece));
      }
    }
    chars.write(encodePiece(currentTurn));
    return chars.toString();
  }

  void decodeChessboard(String chars){
    int c=0;
    for(int i=0;i<BoardSize;i++){
      for(int j=0;j<BoardSize;j++){
        cells[i][j].piece = decodePiece(chars[c++]);
      }
    }
    currentTurn = decodePiece(chars[c++]);
  }

  switchTurn(){
    currentTurn = getReverse(currentTurn);
  }

  String getReverse(String piece){
    if(piece == black){
      return white;
    }else if(piece == white){
      return black;
    }else{
      return null;
    }
  }

  bool placePiece(BoardCell cell){
    if(cell.isEmpty){
      var success = reverseOpponents(cell, currentTurn);
      if(success){
        cell.piece = currentTurn;
        switchTurn();
        calculateScore();
        step++;
        history[step] = encodeChessboard();
        if(canPlacePiece(currentTurn)){
          tip = null;
        }else{
          switchTurn();
          if(canPlacePiece(currentTurn)){
            tip = "${players[getReverse(currentTurn)]}无棋";
          }else{
            gameOver = true;
          }
        }
        return true;
      }else{
        tip = "落子无效";
      }
    }
    return false;
  }

  static List<CellPos> w(int row, int col){
    List<CellPos> adjacentCells = [];
    for(int j = col - 1; j >= 0; j--){
      adjacentCells.add(new CellPos(row, j));
    }
    return adjacentCells;
  }

  static List<CellPos> e(int row, int col){
    List<CellPos> adjacentCells = [];
    for(int j = col + 1; j < BoardSize; j++){
      adjacentCells.add(new CellPos(row, j));
    }
    return adjacentCells;
  }

  static List<CellPos> n(int row, int col){
    List<CellPos> adjacentCells = [];
    for(int i = row - 1; i >= 0; i--){
      adjacentCells.add(new CellPos(i, col));
    }
    return adjacentCells;
  }

  static List<CellPos> s(int row, int col){
    List<CellPos> adjacentCells = [];
    for(int i = row + 1; i < BoardSize; i++){
      adjacentCells.add(new CellPos(i, col));
    }
    return adjacentCells;
  }

  static List<CellPos> ne(int row, int col){
    List<CellPos> adjacentCells = [];
    for(int i = row - 1, j = col + 1; i >= 0 && j < BoardSize; i--, j++){
      adjacentCells.add(new CellPos(i, j));
    }
    return adjacentCells;
  }

  static List<CellPos> se(int row, int col){
    List<CellPos> adjacentCells = [];
    for(int i = row + 1, j = col + 1; i < BoardSize && j < BoardSize; i++, j++){
      adjacentCells.add(new CellPos(i, j));
    }
    return adjacentCells;
  }

  static List<CellPos> sw(int row, int col){
    List<CellPos> adjacentCells = [];
    for(int i = row + 1, j = col - 1; i < BoardSize && j >= 0; i++, j--){
      adjacentCells.add(new CellPos(i, j));
    }
    return adjacentCells;
  }

  static List<CellPos> nw(int row, int col){
    List<CellPos> adjacentCells = [];
    for(int i = row - 1, j = col - 1; i >= 0 && j >= 0; i--, j--){
      adjacentCells.add(new CellPos(i, j));
    }
    return adjacentCells;
  }

  var directions = [n, ne, e, se, s, sw, w, nw];

  List<BoardCell> findReverible(BoardCell cell, String piece){
    List<BoardCell> allOpponents = [];
    for(var direction in directions){
      List<BoardCell> opponents = [];
      for(var cellPos in direction(cell.row, cell.col)){
        var nextCell = cells[cellPos.row][cellPos.col];
        if(nextCell.piece == getReverse(piece)){
          opponents.add(nextCell);
        }else{
          if(nextCell.piece == piece){
            allOpponents.addAll(opponents);
          }
          break;
        }
      }
    }
    return allOpponents;
  }

  bool reverseOpponents(BoardCell cell, String piece){
    List<BoardCell> allOpponents = findReverible(cell, piece);
    if(allOpponents.length > 0){
      allOpponents.forEach((opp){opp.piece=piece;});
      return true;
    }else{
      return false;
    }
  }

  bool canPlacePiece(String piece){
    for(int i=0;i<BoardSize;i++){
      for(int j=0;j<BoardSize;j++){
        var cell = cells[i][j];
        if(cell.isEmpty &&
            findReverible(cell, piece).length > 0){
          return true;
        }
      }
    }
    return false;
  }

  Map<BoardCell, int> validPlacements(){
    Map<BoardCell, int> placements = {};
    for(int i=0;i<BoardSize;i++){
      for(int j=0;j<BoardSize;j++){
        var cell = cells[i][j];
        if(cell.isEmpty) {
          int count = findReverible(cell, currentTurn).length;
          if(count > 0){
            placements[cell] = count;
          }
        }
      }
    }
    return placements;
  }

  void gotoStep(int step){
    if(history.containsKey(step)){
      decodeChessboard(history[step]);
      calculateScore();
      this.step = step;
    }
  }

  void calculateScore(){
    whiteScore = 0;
    blackScore = 0;
    for(int i=0;i<BoardSize;i++){
      for(int j=0;j<BoardSize;j++){
        var piece = cells[i][j].piece;
        if(piece == white){
          whiteScore++;
        }else if(piece == black){
          blackScore++;
        }
      }
    }
  }

  var players = {black:"黑方", white:"白方"};

  String get message {
    if(gameStart){
      if(gameOver){
        if(whiteScore > blackScore){
          return "白方胜！";
        }else if(whiteScore < blackScore){
          return "黑方胜！";
        }else{
          return "双方平局！";
        }
      }
      if(tip == null){
        return "${players[currentTurn]}走棋";
      }else{
        return "$tip，${players[currentTurn]}走棋";
      }
    }else{
      return "等待对方加入……";
    }
  }
}