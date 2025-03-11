const CalendarsApi = {
  
  getAvailability: function(data) {
    return $.when(
      $.ajax({
        url: "/api/calendars/availability",
        method: "POST",
        dataType:"json",
        data: {
          list_id: data.list_id,
          num_of_months: data.num_of_months
        }
      })
    )
  }
  
};

export default CalendarsApi;