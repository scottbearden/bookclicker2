const ConversationsApi = {
  
  replyToConversation: function(conversationId, message){
    let url = "/api/conversations/" + conversationId + "/reply";
    return $.when(
      $.ajax({
        method: "POST",
        url: url,
        data: {
          message_body: message.body
        },
        dataType: "json"
      })
    )
  },

  showConversation: function(conversationId) {
    let url = "/api/conversations/" + conversationId;
    return $.when(
      $.ajax({
        method: "GET",
        url: url,
        dataType: "json"
      })
    )
  },

  moveToTrash: function(conversationId) {

    let url = "/api/conversations/" + conversationId + "/move_to_trash";
    return $.when(
      $.ajax({
        method: "PUT",
        url: url,
        data: {},
        dataType: "json"
      })
    )

  },

  untrash: function(conversationId) {

    let url = "/api/conversations/" + conversationId + "/untrash";
    return $.when(
      $.ajax({
        method: "PUT",
        url: url,
        data: {},
        dataType: "json"
      })
    )

  },
  
  startConversation: function(data) {
    let url = "/api/conversations";
    return $.when(
      $.ajax({
        method: "POST",
        url: url,
        data: data,
        dataType: "json"
      })
    )
  }
  
};

export default ConversationsApi;
