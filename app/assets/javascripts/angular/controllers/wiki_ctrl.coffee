$ ->
  app = angular.module 'InternalWiki', []

  app.controller 'WikiItemCtrl', ($scope) ->
    $scope.isShow = false
    $scope.showActionBtn= ->
      $scope.isShow = true
    $scope.hideActionBtn= ->
      $scope.isShow = false
