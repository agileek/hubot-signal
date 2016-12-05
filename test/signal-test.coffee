Bot = require '../src/signal'

{Adapter, Robot, EnterMessage, LeaveMessage, TextMessage} = require 'hubot'

assert = require 'assert'
sinon = require 'sinon'

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

    it 'should parse Body to extract content', ->
      message = """Timestamp: 1480507876164 (2016-11-30T12:11:16.164Z)
Message timestamp: 1480507876164 (2016-11-30T12:11:16.164Z)
Body: Plop
"""
      result = bot.parseMessage message

      assert.equal result.body, 'Plop'

    it 'should parse and extract All', ->
      message = """Envelope from: +33605040302
Timestamp: 1480941940320 (2016-12-05T12:45:40.320Z)
Body: badger
"""
      result = bot.parseMessage message

      assert.equal result.body, 'badger'
      assert.equal result.username, '+33605040302'
