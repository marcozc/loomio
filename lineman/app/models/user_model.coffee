angular.module('loomioApp').factory 'UserModel', (BaseModel) ->
  class UserModel extends BaseModel
    @singular: 'user'
    @plural: 'users'
    @indices: ['id']

    initialize: (data) ->
      @updateFromJSON(data)
      @label = data.username

    setupViews: ->
      @membershipsView = @recordStore.memberships.belongingTo(userId: @id)
      @notificationsView = @recordStore.notifications.belongingTo(userId: @id)
      @groupsView = @recordStore.groups.belongingTo(id: { $in: @groupIds() })
      @parentGroupsView = @recordStore.groups.collection.addDynamicView()
      @parentGroupsView.applyFind(parentId: {$eq: null}).applyFind(id: {$in: @groupIds()})

    groupIds: ->
      _.map(@memberships(), 'groupId')

    membershipFor: (group) ->
      _.first @recordStore.memberships
                          .where(groupId: group.id, userId: @id)
    memberships: ->
      @membershipsView.data()

    notifications: ->
      @notificationsView.data()

    groups: ->
      @recordStore.groups.find(id: { $in: @groupIds() })

    parentGroups: ->
      @parentGroupsView.data()

    canEditComment: (comment) ->
      @isAuthorOf(comment) && comment.group().membersCanEditComments

    canDeleteComment: (comment) ->
      @isAuthorOf(comment) or @isAdminOf(comment.group())

    canEditDiscussion: (discussion) ->
      @isAuthorOf(discussion) or
      @isAdminOf(discussion.group()) or
      discussion.group().membersCanEditDiscussions

    canEditProposal: (proposal) ->
      proposal.isActive() and
      proposal.canBeEdited() and
      (@isAdminOf(proposal.group()) or @isAuthorOf(proposal))

    canCloseOrExtendProposal: (proposal) ->
      proposal.isActive() and
      (@isAdminOf(proposal.group()) or @isAuthorOf(proposal))

    canCreateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and !proposal.hasOutcome()

    canUpdateOutcomeFor: (proposal) ->
      @canSetOutcomeFor(proposal) and proposal.hasOutcome()

    canSetOutcomeFor: (proposal) ->
      proposal.isClosed() and
      (proposal.authorId == @id or proposal.group().coordinatorsIncludes(@))

    canSeePrivateContentFor: (group) ->
      group.visibleTo == 'public' or
      @isMemberOf(group) or
      (group.visibleTo == 'parent_members' and @isMemberOf(group.parent()))

    isAuthorOf: (object) ->
      @id == object.authorId

    isAdminOf: (group) ->
      _.contains(group.adminIds(), @id)

    isMemberOf: (group) ->
      _.contains(group.memberIds(), @id)
