window.allDropdownLinks = [
  '#user-header-nav-account-toggle', 
  '#user-header-nav-impersonate-toggle'
]


$(function() {

  var hideDropdownOnClick = function(delayMs, event) {
    if (!$(event.target).parents('#header-nav').length) {
      setTimeout(function() {
        $('.nav-dropdown-target').hide()
      }, delayMs)
    }
  }

  window.allDropdownLinks.forEach(function(linkId, idx) {
    $(linkId).on('click mouseover', function(event) {
      $('.nav-dropdown-target').hide()
      $(linkId + '-target').show();
    });
  });
  
  window.ontouchstart = hideDropdownOnClick.bind(this, 170);
  window.onclick = hideDropdownOnClick.bind(this, 20)
  
  $(document).on('shown.bs.modal', function() {
    $('.modal-backdrop').on('click touchend', function() {
      $('.modal').modal('hide')
    })
  })
  $(document).on('hidden.bs.modal', function() {
    $('.modal-backdrop').off('click touchend')
  })

  window.showConversation = function(conversationId) {
    document.location = "/conversations/" + conversationId;
  }
})

