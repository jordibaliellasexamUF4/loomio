angular.module('loomioApp').directive 'commentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ($scope, FormService, Records, CurrentUser) ->
    group = $scope.comment.discussion().group()
    discussion = $scope.comment.discussion()

    applyFormService = (=>
      $scope.submit = FormService.submit $scope, $scope.comment,
        flashSuccess: 'comment_form.messages.created'
        successCallback: =>
          $scope.comment.body = ''
          $scope.comment.newAttachmentIds = []
    )()

    $scope.$on 'replyToCommentClicked', (event, parentComment) ->
      $scope.comment.parentId = parentComment.id

    $scope.removeAttachment = (attachment) ->
      ids = $scope.comment.newAttachmentIds
      ids.splice ids.indexOf(attachment.id), 1
      Records.attachments.destroy(attachment.id)

    $scope.updateMentionables = (fragment) ->
      allMentionables = _.filter group.members(), (member) ->
        member.id != CurrentUser.id and \
        (~member.name.search(new RegExp(fragment, 'i')) or \
         ~member.label.search(new RegExp(fragment, 'i')))
      $scope.mentionables = _.take allMentionables, 5 # filters are being annoying

    $scope.fetchByNameFragment = (fragment) ->
      $scope.updateMentionables(fragment)
      Records.memberships.fetchByNameFragment(fragment, group.key).then -> $scope.updateMentionables(fragment)
