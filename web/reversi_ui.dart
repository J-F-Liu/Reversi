import 'dart:html';
import 'view_switcher.dart';
import 'chess_view.dart';

$(String selectors) => querySelector(selectors);

void main() {
  var switcher = new Switcher($("#container"));
  var buttons = new ButtonList("menuItems", [
    {
      "text":"人机对弈",
      "action": (e){
        switcher.loadView(new HumanVsComputerChessView("ChessBoard"));
      }
    },
    {
      "text":"双人对弈",
      "action": (e){
        switcher.loadView(new HumanVsHumanChessView("ChessBoard"));
      }
    },
    {
      "text":"联网对弈",
      "action": (e){
        switcher.loadView(new HumanViaNetChessView("ChessBoard", $("#serverUrl").value));
      }
    }]);
  var description = new ParagraphElement();
  description.innerHtml = """<br><b>游戏规则</b>：黑白双方轮流落子。<br>
只要落子和棋盘上任一枚己方的棋子在一条线上（横、直、斜线皆可）夹着对方棋子，就能将对方的这些棋子转变为我方。<br>
如果在任一位置落子都不能夹住对手的任一颗棋子，就要让对手下子。当双方皆不能下子时，游戏就结束，子多的一方胜。""";
  var gameMenu = new ComposedView("GameMenu", [buttons], [description]);
  switcher.loadView(gameMenu);
}
