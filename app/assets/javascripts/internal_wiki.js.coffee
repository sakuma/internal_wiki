window.InternalWiki =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
    new InternalWiki.Routers.Pages
    Backbone.history.start()

$(document).ready ->
  InternalWiki.initialize()
