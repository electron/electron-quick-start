chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
  console.log(`Received`, {message, sender, sendResponse});
  sendResponse('world');
});