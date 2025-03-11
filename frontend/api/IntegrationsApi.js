const IntegrationsApi = {
  
  getStatus: function(apiKeyId){
    let url = "/api/integrations/" + apiKeyId;
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
    
  createApiKey: function(data) {
    let url = "/api/integrations";
    return $.when(
      $.ajax({
        method: "POST",
        url: url,
        data: data
      })
    )
  },
  
  updateApiKey: function(apiKeyId, key) {
    let url = "/api/integrations/" + apiKeyId;
    return $.when(
      $.ajax({
        method: "PUT",
        url: url,
        data: {
          key: key
        }
      })
    )
  },
  
  deleteApiKey: function(apiKeyId) {
    let url = "/api/integrations/" + apiKeyId;
    return $.when(
      $.ajax({
        method: "DELETE",
        url: url,
        data: {}
      })
    )
  }
    
  
}

export default IntegrationsApi;