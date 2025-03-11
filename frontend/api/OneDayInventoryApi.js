const OneDayInventoryApi = {

  get: function(date, list_id) {
    return $.when(
      $.ajax({
        url: "/api/one_day_inventories",
        method: "GET",
        dataType:"json",
        data: {
          date: date,
          list_id: list_id
        }
      })
    )
  },
  
  create(listId, date, inventory) {
    return $.when(
      $.ajax({
        url: "/api/one_day_inventories",
        method: "POST",
        dataType: "json",
        data: {
          list_id: listId,
          date: date,
          one_day_inventory: inventory
        }
      })
    )
  }
    
    

}

export default OneDayInventoryApi;