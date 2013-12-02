$ ->
  'use strict'
  wikiItemControllers.controller 'wikiItemsController', ['$scope', ($scope) ->

    # init
    $scope.isShow = false
    $scope.showActionBtn = ->
      $scope.isShow = true
    $scope.hideActionBtn = ->
      $scope.isShow = false
    $scope.$watch 'privatePolicy', (newValue, oldValue) ->
      $scope.isShow = (newValue == 'true')
    ]
