document.addEventListener('DOMContentLoaded', () => {

  let button = document.querySelector("#button-1");
  let tools = document.querySelector(".button-and-search")
  let search = document.querySelector(".input-text");
  let container = document.getElementById('container');

  tools.addEventListener('click', () => {
    event.preventDefault();
    if (event.target==button){


      console.log(search.value)
      fetch(`https://api.binance.com/api/v1/exchangeInfo`)
      .then(response => response.json())
      .then(json => {
        let result = json.symbols.find( (crypto) => {
          return crypto.symbol == search.value
        })
        allCryptos.push(result.symbol)

        let crypto = `
          <div class="card">
          <ul><h2>Crypto: </h2>${result.symbol}</ul>
          <ul>Max: ${result.filters[0].maxPrice}</ul>
          <ul>Min: ${result.filters[0].minPrice}}</ul>
          </div>
          `
        container.innerHTML += crypto;
      })
    }
  })
})
