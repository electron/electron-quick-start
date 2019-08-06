# Location
* from: github.com/schloerke/leaflet-providers@urlProtocol

* Inspiration taken from https://github.com/leaflet-extras/leaflet-providers/commit/dea786a3219f9cc824b8e96903a17f46ca9a5afc to use the 'old' relative url protocols and to 'upgrade' them at js runtime.



# Notes...

* Copy/paste provider information into `providers.json`
```js
var providers = L.TileLayer.Provider.providers;
JSON.stringify(providers, null, "  ");
```
  * `./data-raw/providerNames.R` was re-ran to update to the latest providers

* Some providers had their protocols turned into '//'.
  * This allows browsers to pick the protocol
  * To stop files from the protocols staying as files, a ducktape patch was applied to `L.TileLayer.prototype.initialize` and `L.TileLayer.WMS.prototype.initialize`
