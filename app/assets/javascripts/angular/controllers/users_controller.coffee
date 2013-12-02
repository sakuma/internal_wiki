$ ->
  'use strict'
  wikiItemControllers.controller 'usersController', ['$scope', ($scope) ->

    # init
    $scope.isShow = false
    $scope.showActionBtn = ->
      $scope.isShow = true
    $scope.hideActionBtn = ->
      $scope.isShow = false
  ]
