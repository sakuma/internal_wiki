class InternalWiki.Views.PagesEdit extends Backbone.View

  template: JST['pages/edit']

  # initialize: ->
  #   @wiki_name.on('reset', @render, this)

  render: ->
    path = location.pathname.split('/')
    @wiki_name = path[1]
    @page_name = path[2]
    $(@el).html @template(wiki_name: @wiki_name, page_name: @page_name)
    this
