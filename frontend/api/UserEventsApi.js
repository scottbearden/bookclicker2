const UserEventsApi = {
  
  recordPageview: function(page){
    return $.when(
      $.ajax({
        method: "POST",
        url: "/api/user_events",
        dataType:"json",
        data: {
          event: 'page_view',
          event_detail: page
        }
      })
    )
  },

  
};

export default UserEventsApi;