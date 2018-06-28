$(function() {
  if (gon.run) {
    const subscription = App.cable.subscriptions.create({channel: "RunChannel", run_id: gon.run.id}, {received: function(payload) {
      document.getElementById('time-since-upload').textContent = payload.time_since_upload
    }})
    $(document).on("page:before-change turbolinks:before-visit", function() {
      App.cable.subscriptions.remove(subscription)
    })
  }
})
