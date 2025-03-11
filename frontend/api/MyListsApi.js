const MyListsApi = {
  
  getMyLists: function(refresh, getAll){
    let url = "/api/my_lists?refresh=" + refresh;
    if (getAll) url += "&all=1";
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  getMyList: function(id) {
    let url = "/api/my_lists/" + id;
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  updateMyList: function(id, data) {
    let url = "/api/my_lists/" + id;
    return $.when(
      $.ajax({
        method: "PUT",
        url: url,
        dataType: 'json',
        data: data
      })
    )
  },
  
  updateCutoffDate: function(id, cutoff_date) {
    let url = "/api/my_lists/" + id + "/cutoff_date";
    return $.when(
      $.ajax({
        method: "PUT",
        url: url,
        dataType: 'json',
        data: {
          cutoff_date: cutoff_date
        }
      })
    )
  },
  
  updateInventoriesGenresPrices: function(id, inventories, genres, prices) {
    let url = "/api/my_lists/" + id + "/inventories_genres_prices";
    return $.when(
      $.ajax({
        method: "PUT",
        url: url,
        dataType: 'json',
        data: {
          inventories: inventories,
          genres: genres,
          prices: prices
        }
      })
    )
  }
    
};

export default MyListsApi;