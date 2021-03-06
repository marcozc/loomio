angular.module('loomioApp').directive 'startProposalButton', ->
  scope: { discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/start_proposal_button/start_proposal_button.html'
  replace: true
  controller: ($scope, Records, ModalService, ProposalForm, CurrentUser, AbilityService) ->

    $scope.canStartProposal = ->
      AbilityService.canStartProposal $scope.discussion

    $scope.startProposal = ->
      ModalService.open ProposalForm, proposal: -> Records.proposals.initialize(discussion_id: $scope.discussion.id)
