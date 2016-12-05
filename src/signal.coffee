{Adapter, Robot, TextMessage} = require 'hubot'
{spawn} = require('child_process')
util = require 'util'
String::startsWith ?= (s) -> @slice(0, s.length) == s

class Signal extends Adapter

  constructor: (robot) ->
    @robot = robot

  send: (envelope, strings...) ->
    for string in strings
      signal = spawn(@options.path, ['--dbus', 'send', '-m', string, envelope.user.id]);
      signal.stdout.on 'data', (data) =>
        @robot.logger.debug data.toString().trim()
      signal.stderr.on 'data', (data) =>
        @robot.logger.error data.toString().trim()


  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

  run: ->
    @emit "connected"
    options =
      username: process.env.HUBOT_SIGNAL_USERNAME
      path: process.env.HUBOT_SIGNALCLI_BINARY
    @robot.logger.info util.inspect(options)
    @options = options
    @buildCli()

  buildCli: () ->
    signal_daemon = spawn(@options.path, ['-u', @options.username, 'daemon']);
    signal_daemon.stdout.on 'data', (data) => @robot.logger.debug data.toString().trim()
    signal_daemon.stderr.on 'data', (data) => @robot.logger.error data.toString().trim()

    signal = spawn(@options.path, ['--dbus', 'receive', '-t', '-1']);
    signal.stdout.on 'data', (data) =>
      parsedMessage = @parseMessage(data.toString().trim())
      if (parsedMessage? && parsedMessage.body?)
        user = @robot.brain.userForId parsedMessage.username, room: 'Signal'
        @receive new TextMessage user, parsedMessage.body, 'messageId'

    signal.stderr.on 'data', (data) => @robot.logger.error data.toString().trim()


  parseMessage: (message) ->
    if (message.match(/^Envelope from:/) && message.match(/\nBody:/))
      username: message.match(/\+[0-9]+/)[0], body: message.match(/\nBody:.*$/)[0].substr(7)
    else if (message.match(/^Envelope from:/))
      username: message.match(/\+[0-9]+/)[0]
    else if (message.match(/\nBody:/))
      body: message.match(/\nBody:.*$/)[0].substr(7)
    else
      null


exports.use = (robot) ->
  new Signal robot
