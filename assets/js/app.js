// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

const colors = [
  "#B28DFF",
  "#85E3FF",
  "#FFABAB",
  "#6EB5FF",
  "#F6A6FF",
  "#FFF5BA",
  "#AFCBFF"
]

function getCursorPosition(el) {
  let sel = window.getSelection()
  let anchorOffset = sel.anchorOffset
  let focusOffset = sel.focusOffset
  let anchorNodeIndex = Array.from(el.childNodes).findIndex((element) => {
    return element == sel.anchorNode
  })
  let focusNodeIndex = Array.from(el.childNodes).findIndex((element) => {
    return element == sel.focusNode
  })

  return [anchorOffset, focusOffset, anchorNodeIndex, focusNodeIndex]
}

function sortById(a, b) {
  (a.id > b.id) - (a.id < b.id)
}

function debounce(func, timeout = 300){
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => { func.apply(this, args); }, timeout);
  };
}

let Hooks = {}
Hooks.ContentEditable = {
  cursors: [],
  sendLocalUpdates(e) {
    this.pushEvent("edit-pad", {text: this.el.innerText})
  },
  sendCursorUpdates(e) {
    let [anchorOffset, focusOffset, anchorNodeIndex, focusNodeIndex] = getCursorPosition(this.el)
    this.pushEvent("update-cursor", {anchor_offset: anchorOffset, focus_offset: focusOffset, anchor_node: anchorNodeIndex, focus_node: focusNodeIndex})
  },
  mounted() {
    this.handleEvent("updated-content", this.updateContent.bind(this))
    this.handleEvent("updated-cursors", this.updateCursors.bind(this))
    this.el.addEventListener("input", debounce(this.sendLocalUpdates.bind(this)), false)
    this.el.addEventListener("click", debounce(this.sendCursorUpdates.bind(this)), false)
    this.el.addEventListener("keyup", debounce(this.sendCursorUpdates.bind(this)), false)
    setInterval(this.renderCursors.bind(this), 250)
  },
  updateContent({text}) {
    let [anchorOffset, focusOffset, anchorNodeIndex, focusNodeIndex] = getCursorPosition(this.el)

    this.el.innerText = text

    let range = document.createRange()

    if (anchorNodeIndex < 0 || anchorNodeIndex >= this.el.childNodes.length) anchorNodeIndex = 0
    let anchorNode = this.el.childNodes[anchorNodeIndex]

    if (focusNodeIndex < 0 || focusNodeIndex >= this.el.childNodes.length) focusNodeIndex = 0
    let focusNode = this.el.childNodes[focusNodeIndex]

    let anchorPosition = [anchorNode, Math.min(anchorOffset, anchorNode.length)]
    let focusPosition = [focusNode, Math.min(focusOffset, focusNode.length)]
    let positions = {true: anchorPosition, false: focusPosition}

    range.setStart(...positions[anchorNodeIndex < focusNodeIndex])
    range.setEnd(...positions[anchorNodeIndex > focusNodeIndex])

    sel = window.getSelection()
    if (sel.rangeCount > 0) sel.removeAllRanges();
    sel.addRange(range)
  },
  renderCursors() {
    document.querySelectorAll(".caret").forEach(el => el.remove())

    this.cursors.forEach(({anchor_offset, focus_offset, anchor_node, focus_node}, index) => {
      // TODO: do all this w/ anchor node too
      if (anchor_node < 0 || anchor_node >= this.el.childNodes.length) return
      if (focus_node < 0 || focus_node >= this.el.childNodes.length) return

      let anchorNode = this.el.childNodes[anchor_node]
      let focusNode = this.el.childNodes[focus_node]

      let range = document.createRange()

      range.setStart(anchorNode, Math.min(anchor_offset, anchorNode.length))
      range.setEnd(focusNode, Math.min(focus_offset, focusNode.length))
      let rectList = range.getClientRects()

      for(let i = 0; i < rectList.length; i++) {
        let rect = rectList.item(i)

        let div = document.createElement("div")
        div.style.height = `${rect.height}px`
        div.style.width = `${rect.width+1}px`
        div.style.left = `${rect.x-1}px`
        div.style.top = `${rect.y}px`
        div.style.backgroundColor = colors[index % colors.length]
        div.classList.add("caret")
        document.querySelector("body").appendChild(div);
      }
    })
  },
  updateCursors({cursors}) {
    this.cursors = cursors.sort(sortById);
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

