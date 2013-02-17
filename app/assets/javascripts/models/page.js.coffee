class InternalWiki.Models.Page extends Backbone.Model

  urlRoot: ->
    path = location.pathname.split('/')[1]
    "/#{path}"

