const BooklauncherPromosApi = {
  
  create: function(bookId, promos) {
    return $.when(
      $.ajax({
        method: "POST",
        url: "/api/booklauncher/promos",
        data: {
          book_id: bookId,
          promos_attributes: promos
        }
      })
    )
  }
    
};

export default BooklauncherPromosApi;