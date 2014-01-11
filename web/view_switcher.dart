library view_switcher;

import 'dart:html';

abstract class View {
  var id;
  String urlSegment;
  Iterable<Element> render();
  Function onLoad;
}

class Switcher {

  DivElement container;
  View currentView;
  Map<dynamic, View> allViews = new Map<dynamic, View>();
  String title;

  Switcher(this.container){
    window.onPopState.listen(onPopState);
	  title = document.title;
  }

  void onPopState(PopStateEvent event) {
  	if (event.state != null) {
  	  restoreView(event.state);
  	}
  }

  View findView(var id){
    return allViews[id];
  }

  void restoreView(var id){
  	var view = findView(id);
  	if(view != null){
  	  container.children.clear();
  	  container.children.addAll(view.render());
  	  document.title = "$title#${view.urlSegment}";
  	  currentView = view;
  	}
  }

  void loadView(View view){
    window.history.pushState(view.id, "", "#${view.urlSegment}");
  	document.title = "$title#${view.urlSegment}";
  	allViews[view.id] = view;
    container.children.clear();
  	container.children.addAll(view.render());
  	currentView = view;
  	if(view.onLoad != null){
  	  view.onLoad();
  	}
  }
}

class ComposedView extends View {
  List<View> views;

  ComposedView(name, this.views){
    this.id = name;
    this.urlSegment = name.toString();
  }

  Iterable<Element> render() {
    List<Element> elements = new List<Element>();
	  views.forEach((view) => elements.addAll(view.render()));
    return elements;
  }

}

class ButtonList extends View {

  List<Element> elements = new List<Element>();

  ButtonList(name, menuitems){
    this.id = name;
    this.urlSegment = name.toString();
  	var panel = new DivElement();
  	panel.id = name;
    for(var menuitem in menuitems){
	  var button = new ButtonElement();
	  button.text = menuitem["text"];
	  button.onClick.listen(menuitem["action"]);
	  panel.children.add(button);
	}
	elements.add(panel);
  }

  Iterable<Element> render() {
    return elements;
  }
}