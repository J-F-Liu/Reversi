import 'dart:html';
import 'view_switcher.dart';
import 'chess_view.dart';

$(String selectors) => querySelector(selectors);

void main() {
  var switcher = new Switcher($("#container"));
  var buttons = new ButtonList("GameMenu", [
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
        switcher.loadView(new HumanViaNetChessView("ChessBoard", "ws://192.168.1.100:9223/ws"));
      }
    }]);

    switcher.loadView(buttons);
}
