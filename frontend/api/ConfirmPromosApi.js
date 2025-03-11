const ConfirmPromosApi = {

  create: function(reservation_id, reservation_type, campaign_id, campaign_preview_url, book_owner_email) {
    return $.when(
      $.ajax({
        url: "/api/confirm_promos",
        method: "POST",
        dataType:"json",
        data: {
          reservation_id,
          reservation_type,
          campaign_id,
          campaign_preview_url,
          book_owner_email,
          as: 'seller'
        }
      })
    )
  },
  
  fetchOptions: function(reservation_id, reservation_type) {
    return $.when(
      $.ajax({
        url: "/api/confirm_promos/" + reservation_id + "/options?reservation_type=" + reservation_type,
        method: "GET"
      })
    )
  },
  
  fetchCampaigns: function(list_id, offset) {
    return $.when(
      $.ajax({
        url:  "/api/lists/" + list_id + "/campaigns?offset=" + offset,
        method: "GET",
        dataType:"json"
      })
    )
  } 

}

export default ConfirmPromosApi;