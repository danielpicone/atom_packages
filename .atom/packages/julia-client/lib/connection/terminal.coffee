child_process = require 'child_process'
net = require 'net'

tcp = require './process/tcp'
client = require './client'
{paths} = require '../misc'

platformioTerm = null

module.exports =

  escpath: (p) -> '"' + p + '"'
  escape: (sh) -> sh.replace(/"/g, '\\"')

  exec: (sh) ->
    child_process.exec sh, (err, stdout, stderr) ->
      if err?
        console.log err

  term: (sh) ->
    switch process.platform
      when "darwin"
        @exec "osascript -e 'tell application \"Terminal\" to activate'"
        @exec "osascript -e 'tell application \"Terminal\" to do script \"#{@escape(sh)}\"'"
      when "win32"
        @exec "#{@terminal()} \"#{sh}\""
      else
        @exec "#{@terminal()} \"#{@escape(sh)}\""

  terminal: -> atom.config.get("julia-client.terminal")

  defaultTerminal: ->
    if process.platform == 'win32'
      'cmd /C start cmd /C'
    else
      'x-terminal-emulator -e'

  repl: -> @term "#{@escpath paths.jlpath()}"

  connectCommand: ->
    tcp.listen().then (port) =>
      "#{@escpath paths.jlpath()} -i -e \"using Juno; Juno.connect(#{port})\""

  connectedRepl: -> @connectCommand().then (cmd) => @term cmd

  # PlatformIO Terminal integration

  consumeTerminal: (term) ->
    platformioTerm = term

  runPlatformIOTerm: ->
    @connectCommand().then (cmd) =>
      platformioTerm.run([cmd])
