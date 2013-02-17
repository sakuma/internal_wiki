class InternalWiki.Routers.Pages extends Backbone.Router
  routes:
    'edit_page': 'edit'

  edit: ->
    path = location.pathname.split('/')
    @wiki_name = path[1]
    @page_name = path[2]
    # alert "edit: page!"
    view = new InternalWiki.Views.PagesEdit(wiki_name: @wiki_name)
    $('#container').html(view.render().el)

