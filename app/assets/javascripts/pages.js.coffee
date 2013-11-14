class @PageContent

  @get = (request_url, replaceElement, hash) ->
    $.ajax
      type: 'POST'
      url: request_url
      success: (data, textStatus, jqXHR) ->
        console.log data
        $(replaceElement).html data
      error: (data, textStatus, jqXHR) ->
        console.log textStatus

  @replace = (request_url, body, replaceElement) ->
    $.ajax
      type: 'POST'
      url: request_url
      data:
        body: body
      success: (data, textStatus, jqXHR) ->
        console.log data
        $(replaceElement).html data
      error: (data, textStatus, jqXHR) ->
        console.log textStatus
