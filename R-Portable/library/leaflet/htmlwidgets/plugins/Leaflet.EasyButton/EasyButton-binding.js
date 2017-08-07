getEasyButton = function(button) {

  var options = {};

  options.position = button.position;

  // only add ID if provided
  if(button.id) {
    options.id = button.id;
  }

  // if custom states provided use that
  // else use provided icon and onClick
  if(button.states) {
    options.states = button.states;
    return L.easyButton(options);
  } else {
    return L.easyButton(button.icon, button.onClick,
      button.title, options );
  }
};

LeafletWidget.methods.addEasyButton = function(button) {
  getEasyButton(button).addTo(this);
};

LeafletWidget.methods.addEasyButtonBar = function(buttons, position, id) {

  var options = {};

  options.position = position;

  // only add ID if provided
  if(id) {
    options.id = id;
  }

  var easyButtons = [];
  for(var i=0; i < buttons.length; i++) {
    easyButtons[i] = getEasyButton(buttons[i]);
  }
  L.easyBar(easyButtons).addTo(this);

};
