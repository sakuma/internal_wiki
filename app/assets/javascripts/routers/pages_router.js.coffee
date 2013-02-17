class InternalWiki.Routers.Pages extends Backbone.Router
  routes:
    '/:wiki_name/pages/:id': 'show'

  show: (wiki_id, id) ->
    alert "show: #{id} page!"
