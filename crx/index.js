setTimeout(() => {
  console.log(`Send message from content_script`);
  chrome.runtime.sendMessage('hello', (resp) => {
    console.log('response received', { resp });
  });
}, 1000);