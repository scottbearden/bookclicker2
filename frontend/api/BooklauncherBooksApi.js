const BooklauncherBooksApi = {
  
  index: function() {
    return $.when(
      $.ajax({
        url: "/api/booklauncher/books",
        dataType:"json"
      })
    )
  },
  
  show: function(bookId) {
    return $.when(
      $.ajax({
        url: "/api/booklauncher/books/" + bookId,
        dataType:"json"
      })
    )
  },
  
  create: function(data) {
    return $.when(
      $.ajax({
        url: "/api/booklauncher/books",
        method: "POST",
        dataType:"json",
        data: data
      })
    )
  },
    
  update: function(data) {
    return $.when(
      $.ajax({
        url: "/api/booklauncher/books/" + data.id,
        method: "PUT",
        dataType:"json",
        data: data
      })
    )
  },
  
  destroy: function(bookId) {
    return $.when(
      $.ajax({
        url: "/api/booklauncher/books/" + bookId,
        method: "DELETE",
        dataType:"json",
        data: {}
      })
    )
  }
    
}

export default BooklauncherBooksApi;