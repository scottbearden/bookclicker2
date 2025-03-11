const MyBooksApi = {
  
  getMyBooks: function(){
    let url = "/api/my_books";
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  getMyBook: function(id) {
    let url = "/api/my_books/" + id;
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  loadLaunchData: function(id) {
    let url = "/api/my_books/" + id + "/launch_data";
    return $.when(
      $.ajax({
        method: "GET",
        url: url
      })
    )
  },
  
  create: function(title, pen_name_id) {
    let url = "/api/my_books"
    return $.when(
      $.ajax({
        method: "POST",
        url: url,
        dataType: 'json',
        data: {
          title: title,
          pen_name_id: pen_name_id
        }
      })
    )
  },
  
  update: function(book) {
    book.book_links_attributes = book.book_links;
    let url = "/api/my_books/" + book.id
    return $.when(
      $.ajax({
        method: "PUT",
        url: url,
        dataType: 'json',
        data: {
          book: book
        }
      })
    )
  },

  deleteMyBook: function(id) {
    let url = "/api/my_books/" + id;
    return $.when(
      $.ajax({
        method: "DELETE",
        url: url
      })
    )
  }

};

export default MyBooksApi;