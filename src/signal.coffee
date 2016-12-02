{Adapter, Robot, TextMessage} = require 'hubot'
{spawn} = require('child_process')
util = require 'util'
String::startsWith ?= (s) -> @slice(0, s.length) == s

class Signal extends Adapter

  constructor: (robot) ->
    @robot = robot

  send: (envelope, strings...) ->
    @robot.logger.info "Send"


  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

  run: ->
    @robot.logger.info "Run"
    @emit "connected"
    options =
      username: process.env.HUBOT_SIGNAL_USERNAME
      path: process.env.HUBOT_SIGNALCLI_BINARY
    @robot.logger.info util.inspect(options)
    @options = options
    @buildCli()

  buildCli: () ->
    signal = spawn(@options.path, ['-u', @options.username, 'receive', '-t', '-1']);
    signal.stdout.on 'data', (data) =>
      parsedMessage = @parseMessage(data.toString().trim())
      @robot.logger.info parsedMessage
      if (parsedMessage? && parsedMessage.username?)
        user = @robot.brain.userForId parsedMessage.username, room: 'Signal'
        @receive new TextMessage user, 'badger', 'messageId'

    # @receive new TextMessage user, data, 'messageId'
    signal.stderr.on 'data', (data) -> console.log data.toString().trim()

  parseMessage: (message) ->
    if (message.match(/^Envelope from:/))
      username: message.match(/\+[0-9]+/)[0]
    else if (message.match(/\nBody:/))
      body: message.match(/\nBody:.*$/)[0].substr(7)
    else
      null


exports.use = (robot) ->
  new Signal robot
