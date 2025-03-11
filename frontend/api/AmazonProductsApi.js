const AmazonProductsApi = {
  
  getItemAttrs: function(amazonUrl){
    let url = "/api/amazon_products?url=" + encodeURI(amazonUrl);
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  getProfileAttrs: function(amazonProfileUrl) {
    let url = "/api/amazon_products/profile?url=" + encodeURI(amazonProfileUrl);
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  }
  
};

export default AmazonProductsApi;