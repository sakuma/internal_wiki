$ ->
  app = angular.module 'InternalWiki', []

  app.controller 'WikiItemCtrl', ($scope) ->
    # init
    $scope.isShow = false

    $scope.showActionBtn = ->
      $scope.isShow = true

    $scope.hideActionBtn = ->
      $scope.isShow = false

    $scope.$watch 'privatePolicy', (newValue, oldValue) ->
      $scope.isShow = (newValue == 'true')
