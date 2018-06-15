// Listen for messages from parent frame. This file is only added when the
// shiny.testmode option is TRUE.
window.addEventListener("message", function(e) {
  var message = e.data;

  if (message.code)
    eval(message.code);
});
