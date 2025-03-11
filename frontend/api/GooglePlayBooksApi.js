const GOOGLE_BOOKS_API_KEY = 'AIzaSyADxBFQL3WRpc0K66Uakye9VVSYQgWGy8U';

const GooglePlayBooksApi = {

  apiUrl: function(volumeId) {
    return `https://www.googleapis.com/books/v1/volumes/${volumeId}?key=${GOOGLE_BOOKS_API_KEY}`
  },

  parseVolumeId: function(url) {
    let regexMatch = /id\=([A-Za-z0-9]+)/.exec(url)
    return regexMatch && regexMatch[1]
  },

  getItemAttrs: function(url){
    let volumeId = this.parseVolumeId(url);
    if (!volumeId) {
      return new Promise(function(resolve, reject) {
        resolve({});
      })
    }
    return $.when(
      $.ajax({
        method: "GET",
        url: this.apiUrl(volumeId)
      })
    )
  }
  
};

export default GooglePlayBooksApi;
