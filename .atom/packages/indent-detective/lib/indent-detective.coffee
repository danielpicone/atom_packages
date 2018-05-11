{CompositeDisposable} = require 'atom'
status = require './status'
selector = require './selector'

module.exports = GuessIndent =

  activate: (state) ->
    @manual = new Set()
    @subs = new CompositeDisposable()

    status.activate()

    @subs.add atom.workspace.observeTextEditors (ed) =>
      setTimeout (=> @run ed), 1000
      @subs.add ed.onDidDestroy =>
        @manual.delete ed

    @command = atom.commands.add 'atom-text-editor',
      'smart-indent:choose-indent-settings': =>
        @select()

  deactivate: ->
    @subs.dispose()
    @manual.clear()
    @command?.dispose()
    status.deactivate()

  consumeStatusBar: (bar) -> status.consumeStatusBar(bar)

  indent: (s) -> s.match(/^[ \t]*/)[0]

  isblank: (s) -> s.match /^\s*$/

  after: (x, y) -> x.slice(y.length, x.length)

  count: (d, k) ->
    d[k] ?= 0
    d[k] += 1

  bestof: (d) ->
    best = ""
    score = 0
    for k, v of d
      if v > score
        best = k
        score = v
    best

  getIndent: (ed) ->
    votes = {}
    last = ""
    for l in ed.getBuffer().getLines().slice(0,100)
      if @isblank l then continue
      next = @indent l
      if next == last then continue
      if next.startsWith last
        @count votes, @after next, last
      else if last.startsWith next
        @count votes, @after last, next
      last = next
    @bestof votes

  parseIndent: (i) ->
    if i == "" then return
    if i == "\t" then return [null, false]
    count = 0
    for c in i
      return unless c == " "
      count += 1
    [count, true]

  getSettings: (ed) -> @parseIndent @getIndent ed

  setSettings: (ed, [length, soft]=[]) ->
    if soft == true
      ed.setSoftTabs true
      ed.setTabLength length
    else if soft == false
      ed.setSoftTabs false

  run: (ed) ->
    return if @manual.has(ed)
    @setSettings ed, @getSettings ed
    status.updateText()
    setTimeout (=> @run ed), 1000

  select: ->
    items = [{text: "Automatic"}]
    items.push {text: "1 Space", length: 1}
    items.push(({text: "#{n} Spaces", length: n} for n in [2, 3, 4, 6, 8])...)
    items.push {text: "Tabs"}
    s = selector.show items, ({text, length}={}) =>
      ed = atom.workspace.getActiveTextEditor()
      if text is "Automatic"
        @manual.delete ed
        @run ed
        return
      @setSettings ed, [length, length?]
      @manual.add ed
      status.update()
