const PaymentInfoApi = {
  
  delete: function(sourceId) {
    return $.when(
      $.ajax({
        method: 'DELETE',
        url: '/api/payment_infos/' + sourceId,
        dataType: 'json',
        data: {}
      })
    )
  },
  
  getDefaultSource: function() {
    return $.when(
      $.ajax({
        method: 'GET',
        url: '/api/payment_infos/default_source',
        dataType: 'json',
        data: {}
      })
    )
  },
  
  setDefaultSource(cardId) {
    return $.when(
      $.ajax({
        method: 'POST',
        url: '/api/payment_infos/set_default_source',
        dataType: 'json',
        data: {
          card_id: cardId
        }
      })
    )
  }
  
}

export default PaymentInfoApi;