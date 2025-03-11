const ExternalReservationsApi = {
  
  create: function(data) {
    return $.when(
      $.ajax({
        url: "/api/external_reservations",
        method: "POST",
        dataType:"json",
        data: data
      })
    )
  },
  
  update: function(extBookingId, data) {
    return $.when(
      $.ajax({
        url: "/api/external_reservations/" + extBookingId,
        method: "PUT",
        dataType:"json",
        data: data
      })
    )
  }
  
}

export default ExternalReservationsApi;