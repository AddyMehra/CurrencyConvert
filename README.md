# CurrenyConvert
Created a minimalistic currency converting iPhone application that utilises Open Exchange Rates API service to request latest conversion data in JSON and parses it to get latest currency rates.

The application allows user to choose base currency and then fetches latest conversion rates.

Don’t have internet connection!! Don’t worry, it remembers the conversion rates from the last time it was synced.

Fetching and saving of data is performed on the background thread, without disturbing the user interface.

Want to refresh rates, UITable pull to refresh implemented.

*** DO ADD YOUR API KEY TO USER.SWIFT ***
