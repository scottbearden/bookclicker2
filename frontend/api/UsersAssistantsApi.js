const UsersAssistantsApi = {
  
  create: function(assistantId) {
    return $.when(
      $.ajax({
        method: 'POST',
        url: "/api/users_assistants",
        dataType: 'json',
        data: {
          assistant_id: assistantId
        }
      })
    )
  },
  
  update: function(joinId, assistant_id) {
    return $.when(
      $.ajax({
        method: 'PUT',
        url: "/api/users_assistants/" + joinId,
        dataType: 'json',
        data: {
          assistant_id: assistant_id
        }
      })
    )
  },
  
  destroy: function(joinId) {
    return $.when(
      $.ajax({
        method: 'DELETE',
        url: "/api/users_assistants/" + joinId,
        dataType: 'json'
      })
    )
  },
    
  invite: function(email, pen_name) {
    return $.when(
      $.ajax({
        method: 'POST',
        url: "/api/users_assistants/invite",
        dataType: 'json',
        data: {
          invitee_email: email,
          pen_name: pen_name
        }
      })
    )
  },
  
  createPaymentRequest: function(joinId, pay_amount) {
    return $.when(
      $.ajax({
        method: 'POST',
        url: '/api/users_assistants/' + joinId + '/assistant_payment_requests',
        dataType: 'json',
        data: {
          pay_amount: pay_amount
        }
      })
    )
  },
  
  declinePaymentRequest: function(joinId, requestId) {
    return $.when(
      $.ajax({
        method: 'PUT',
        url: '/api/users_assistants/' + joinId + '/assistant_payment_requests/' + requestId + "/decline",
        dataType: 'json',
        data: { }
      })
    )
  },
  
  endPayAgreement: function(joinId, requestId) {
    return $.when(
      $.ajax({
        method: 'PUT',
        url: '/api/users_assistants/' + joinId + '/assistant_payment_requests/' + requestId + "/terminate",
        dataType: 'json',
        data: { }
      })
    )
  }
    
    
  
}

export default UsersAssistantsApi;