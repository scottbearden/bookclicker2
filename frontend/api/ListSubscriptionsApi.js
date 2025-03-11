const ListSubscriptionsApi = {


  update: function(listSubscriptionId, subscribed) {
    let data = subscribed ? { subscribed: true } : {};
    return $.when(
      $.ajax({
        url: "/api/list_subscriptions/" + listSubscriptionId,
        method: "PUT",
        dataType:"json",
        data: data
      })
    )
  }

}

export default ListSubscriptionsApi;