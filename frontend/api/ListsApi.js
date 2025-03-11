const ListsApi = {
  
  getLists: function(queryString, preselected_book_id){
    let url = "/api/lists?" + queryString;
    
    if (preselected_book_id) {
      if (queryString) url += "&";
      url += "preselected_book_id=" + preselected_book_id
    }
    
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  rateList: function(listId, rating) {
    let url = "/api/lists/" + listId + "/rate";
    return $.when(
      $.ajax({
        method: "POST",
        url: url,
        datatType: "json",
        data: {
          rating: rating
        }
      })
    ) 
  }
  
};

export default ListsApi;