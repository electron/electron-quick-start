const { session } = require('electron')

exports.session = function(){


    // Query all cookies.
  session.defaultSession.cookies.get({})
  .then((cookies) => {
    console.log(cookies)
    console.log('got all');
  }).catch((error) => {
    console.log(error)
  })

  // Query all cookies associated with a specific url.
  session.defaultSession.cookies.get({ url: 'http://localhost' })
  .then((cookies) => {
    console.log(cookies)
  }).catch((error) => {
    console.log(error)
  })

  // Set a cookie with the given cookie data;
  // may overwrite equivalent cookies if they exist.
  const cookie = { url: 'http://www.github.com', name: 'dummy_name', value: 'dummy' }
  session.defaultSession.cookies.set(cookie)
  .then(() => {
    // success
  }, (error) => {
    console.error(error)
  });

}