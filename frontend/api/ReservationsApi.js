const ReservationsApi = {

  dismiss: function(reservationId, sentFeed) {
    var data = {};

    var url = "/api/reservations/" + reservationId + "/dismiss";
    if (sentFeed) {
      data = { sent_feed: true }
    }

    return $.when(
      $.ajax({
        url: url,
        method: "PUT",
        dataType:"json",
        data: data
      })
    )
  },

  accept: function(reservationId, reply_message) {
    return $.when(
      $.ajax({
        url: "/api/reservations/" + reservationId + "/accept",
        method: "PUT",
        dataType:"json",
        data: {
          reply_message: reply_message
        }
      })
    )
  },

  decline: function(reservationId, reply_message) {
    return $.when(
      $.ajax({
        url: "/api/reservations/" + reservationId + "/decline",
        method: "PUT",
        dataType:"json",
        data: {
          reply_message: reply_message
        }
      })
    )
  },

  requestConfirmation: function(reservationId) {
    return $.when(
      $.ajax({
        url: "/api/reservations/" + reservationId + "/confirmation_request",
        method: "POST",
        dataType:"json",
        data: {}
      })
    )
  },

  requestRefund: function(reservationId) {
    return $.when(
      $.ajax({
        url: "/api/reservations/" + reservationId + "/refund_request",
        method: "POST",
        dataType:"json",
        data: {}
      })
    )
  },
  
  
  sellerCancel: function(reservationId) {
    return $.when(
      $.ajax({
        url: "/api/reservations/" + reservationId + "/seller_cancel",
        method: "POST",
        dataType:"json",
        data: {}
      })
    )
  },
  
  buyerCancel: function(reservationId) {
    return $.when(
      $.ajax({
        url: "/api/reservations/" + reservationId + "/buyer_cancel",
        method: "POST",
        dataType:"json",
        data: {}
      })
    )
  },
  
  sellerRefund: function(reservationId) {
    return $.when(
      $.ajax({
        url: "/api/reservations/" + reservationId + "/seller_refund",
        method: "POST",
        dataType:"json",
        data: {}
      })
    )
  },
  
  buyerRefund: function(reservationId) {
    return $.when(
      $.ajax({
        url: "/api/reservations/" + reservationId + "/buyer_refund",
        method: "POST",
        dataType:"json",
        data: {}
      })
    )
  },
  
  sellerCancelAll: function(reservationIds) {
    return $.when(
      $.ajax({
        url: "/api/reservations/seller_cancel_all",
        method: "POST",
        dataType:"json",
        data: {
          reservation_ids: reservationIds
        }
      })
    )
  },
  
  buyerCancelAll: function(reservationIds) {
    return $.when(
      $.ajax({
        url: "/api/reservations/buyer_cancel_all",
        method: "POST",
        dataType:"json",
        data: {
          reservation_ids: reservationIds
        }
      })
    )
  }

}

export default ReservationsApi;