const PenNamesApi = {
  
  getPenNamesWithBooks: function() {
    let url = "/api/pen_names";
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  getPenNamesListForBuyer: function() {
    let url = "/api/pen_names/list_for_buyer";
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  create: function(penNameAttrs) {
    let url = "/api/pen_names";
    return $.when(
      $.ajax({
        method: "POST",
        url: url,
        dataType: 'json',
        data: penNameAttrs
      })
    )
  },
  
  update: function(penNameId, penNameAttrs) {
    let url = "/api/pen_names/" + penNameId;
    return $.when(
      $.ajax({
        method: "PUT",
        url: url,
        dataType: 'json',
        data: penNameAttrs
      })
    )
  },

  delete: function(penNameId) {
    let url = "/api/pen_names/" + penNameId;
    return $.when(
      $.ajax({
        method: "DELETE",
        url: url,
        dataType: 'json'
      })
    )
  }
    
  
}

export default PenNamesApi;
