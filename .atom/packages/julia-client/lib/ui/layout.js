'use babel'

function getPanes() {
  if (atom.workspace.getBottomDock) {
    return atom.workspace.getPanes().slice(0, -3)
  } else {
    return atom.workspace.getPanes()
  }
}

export function isCustomLayout() {
  return getPanes().length > 1
}

function resetLayout() {
  pane = getPanes()[0]
  for (let p of getPanes().slice(1)) {
    for (let item of p.getItems()) {
      p.moveItemToPane(item, pane)
    }
  }
}

function createLayout(layout,
                    pane = atom.workspace.getActivePane(),
                    vertical = true) {
  if (!layout) {
  } else if (layout instanceof Array) {
    let ps = [pane]
    for (let l of layout.slice(1)) {
      ps.push(vertical ? pane.splitDown() : pane.splitRight())
    }
    for (let i = 0; i < ps.length; i++) {
      createLayout(layout[i], ps[i], !vertical)
    }
  } else if (layout.layout) {
    layout.scale && pane.setFlexScale(layout.scale)
    createLayout(layout.layout, pane, vertical)
  } else {
    pane.activateItem(layout)
  }
}

function workspace() { return require('../runtime').workspace.ws }
function cons() { return require('../runtime').console.c }
function plots() { return require('../runtime').plots.pane }

export function standard() {
  let ps = []
  for (let pane of [workspace(), cons(), plots()]) ps.push(pane.close())
  Promise.all(ps).then(() => {
    resetLayout()
    createLayout([
      [null, {layout: workspace(), scale: 0.5}],
      {layout: [cons(), plots()], scale: 0.5}
    ])
  })
}
