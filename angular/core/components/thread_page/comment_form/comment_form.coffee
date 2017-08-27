angular.module('loomioApp').directive 'commentForm', ($translate, FormService, Records, Session, KeyEventService, AbilityService, MentionService, AttachmentService, ScrollService, EmojiService) ->
  scope: {discussion: '=', parentComment: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ($scope, $rootScope) ->
    $scope.commentHelptext = ->
      if $scope.discussion.private
        $translate.instant 'comment_form.private_privacy_notice', groupName: $scope.comment.group().fullName
      else
        $translate.instant 'comment_form.public_privacy_notice'

    $scope.commentPlaceholder = ->
      if $scope.comment.parentId
        $translate.instant('comment_form.in_reply_to', name: $scope.comment.parent().authorName())
      else
        $translate.instant('comment_form.say_something')

    $scope.init = ->
      $scope.comment = Records.comments.build
        discussionId: $scope.discussion.id
        authorId: Session.user().id
        parentId: ($scope.parentComment || {}).id

      $scope.submit = FormService.submit $scope, $scope.comment,
        drafts: true
        submitFn: $scope.comment.save
        flashSuccess: ->
          if $scope.comment.isReply()
            'comment_form.messages.replied'
          else
            'comment_form.messages.created'
        flashOptions:
          name: ->
            $scope.comment.parent().authorName() if $scope.comment.isReply()

        successCallback: $scope.init
      KeyEventService.submitOnEnter $scope
      #NOTE: listen for emoji events
      $scope.$broadcast 'reinitializeForm', $scope.comment
    $scope.init()

    # $scope.$on 'replyToCommentClicked', (event, parentComment) ->
    #   $scope.comment.parentId = parentComment.id
    #   $scope.comment.parentAuthorName = parentComment.authorName()
    #   ScrollService.scrollTo('.comment-form textarea', offset: 150)

    AttachmentService.listenForAttachments $scope, $scope.comment
