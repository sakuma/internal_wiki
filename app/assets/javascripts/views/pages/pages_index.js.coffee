class InternalWiki.Views.PagesIndex extends Backbone.View

  template: JST['pages/index']

  render: ->
    $(@el).html(@template())
    this

