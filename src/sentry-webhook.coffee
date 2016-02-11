# Description
#   Listens as a webhook for Sentry
#
# Configuration:
#   PRE_ROOM - An optional String to prepend to the room string (i.e. for slack the '#' sign).
#   POST_ROOM - An optional String to append to the room string
#   TAGS - A comma seperated list of tags to post.
#
# Commands:
#   None
#
# Notes:
#   Listens to a sentry webhook at HUBOTURL/sentry/:room (where room is the channel to post too).
#   It should be noted since sentry doesn't send any "This for sure came from sentry" tags This
#   can also be used as a webhook elsewhere, with some minor adjustments.
#
#   This also listens for HUBOTURL/sentry_user/:user (to post to a specific user).
#
# Author:
#   Eric <ecoan@instructure.com>

filterTags = if process.env.tags then process.env.tags(',') else []

module.exports = (robot) ->
  robot.router.post '/sentry/:room', (req, res) ->
    room = (process.env.PRE_ROOM || '') + req.params.room + (process.env.POST_ROOM || '')
    template = req.body.project_name + ' triggered a new ' + req.body.level + ': ' + req.body.culprit  + ' [ ' + req.body.url + ' ] [ '
    tags = req.body.tags
    first = false
    i = 0
    while i < tags.length
      tag = tags[i]
      if filterTags.indexOf(tag) > -1
        if first
          template += tag.toSource().toString
          first = true
        else
          template += ',' + tag.toSource().toString
      ++i
    template += ' ].'
    robot.messageRoom room, template
    res.status(201).end 'OK'

  robot.router.post '/sentry_user/:user', (req, res) ->
    user = req.params.user
    envelope = {}
    envelope.user = {}
    envelope.user.room = user
    envelope.room = user
    envelope.user.type = 'chat'
    template = req.body.project_name + ' triggered a new ' + req.body.level + ': ' + req.body.message + ' (' + req.body.url + ')'
    robot.send envelope, template
    res.status(201).end 'OK'
