const BookingCalendarsApi = {
  
  getAvailability: function(data) {
    return $.when(
      $.ajax({
        url: "/api/booking_calendars/availability",
        method: "POST",
        dataType:"json",
        data: data
      })
    )
  }
  
};

export default BookingCalendarsApi;