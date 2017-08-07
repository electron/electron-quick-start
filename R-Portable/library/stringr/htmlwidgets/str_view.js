HTMLWidgets.widget({

  name: 'str_view',

  type: 'output',

  initialize: function(el, width, height) {
  },

  renderValue: function(el, x, instance) {
    el.innerHTML = x.html;
  },

  resize: function(el, width, height, instance) {
  }

});
