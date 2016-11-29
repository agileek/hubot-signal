Bot = require '../src/signal'

{Adapter,Robot,EnterMessage,LeaveMessage,TextMessage} = require 'hubot'

assert = require 'assert'
sinon  = require 'sinon'

describe 'XmppBot', ->
  describe '#parseMessages()', ->
    bot = Bot.use()

    it 'should parse enveloppe to extract username', ->
      message = 'Envelope from: +33605040302 (device: 3)'
      result = bot.parseMessage message

      assert.equal result.username, '+33605040302'

      message = 'Envelope from: +33605040301 (device: 1)'
      result = bot.parseMessage message

      assert.equal result.username, '+33605040301'