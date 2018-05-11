module.exports =
  completions: require './runtime/completions'
  modules:     require './runtime/modules'
  evaluation:  require './runtime/evaluation'
  console:     require './runtime/console'
  workspace:   require './runtime/workspace'
  plots:       require './runtime/plots'
  frontend:    require './runtime/frontend'
  debugger:    require './runtime/debugger'
  profiler:    require './runtime/profiler'

  activate: ->
    @modules.activate()
    @frontend.activate()
    @debugger.activate()

  deactivate: ->
    mod.deactivate() for mod in [@modules, @console, @frontend, @debugger, @profiler]

  consumeInk: (ink) ->
    @evaluation.ink = ink
    @debugger.consumeInk ink
    @profiler.activate ink
    for mod in [@console, @workspace, @plots]
      mod.ink = ink
      mod.activate()

  provideHyperclick: -> @evaluation.provideHyperclick()    

  consumeStatusBar: (bar) ->
    @modules.consumeStatusBar bar
