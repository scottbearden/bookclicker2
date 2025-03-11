const UsersApi = {
  
  sendVerificationEmail: function(){
    return $.when(
      $.ajax({
        method: "GET",
        url: "/api/users/send_verification_email",
        dataType:"json"
      })
    )
  },

  updateAutoSubscriptions: function(data) {
    return $.when(
      $.ajax({
        method: "PUT",
        url: "/api/users/auto_subscribe",
        dataType:"json",
        data: data
      })
    )
  },
  
  updateEmailSubscribed: function(data) {
    return $.when(
      $.ajax({
        method: "PUT",
        url: "/api/users/email_subscribe",
        dataType:"json",
        data: data
      })
    )
  },
  
  getCurrentUser: function() {
    return $.when(
      $.ajax({
        method: "GET",
        url: "/api/user"
      })
    )
  },
  
  updateBasicInfo: function(data) {
    return $.when(
      $.ajax({
        method: 'PUT',
        url: "/api/user/basic_info",
        dataType: 'json',
        data: data
      })
    )
  },
  
  updateCountry: function(country) {
    return $.when(
      $.ajax({
        method: 'PUT',
        url: "/api/user/country",
        dataType: 'json',
        data: {
          country: country
        }
      })
    )
  },
    
  deleteAssistantAccount(userId) {
    document.location = "/user/destroy_assistant/" + userId;
  },  
  
  deleteMemberAccount() {
    return $.when(
      $.ajax({
        method: 'DELETE',
        url: "/api/user/destroy_member",
        dataType: 'json',
        data: {}
      })
    )
  }
  
};

export default UsersApi;