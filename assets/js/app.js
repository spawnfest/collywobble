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
  let currentNode = sel.focusNode
  let currentNodeCount = Array.from(el.childNodes).findIndex((element) => {
    return element == currentNode
  })

  return [anchorOffset, focusOffset, currentNodeCount]
}

function sortById(a, b) {
  (a.id > b.id) - (a.id < b.id)
}

let Hooks = {}
Hooks.ContentEditable = {
  sendLocalUpdates(e) {
    this.pushEvent("edit-pad", {text: this.el.innerText})
  },
  sendCursorUpdates(e) {
    let [anchorOffset, focusOffset, currentNodeCount] = getCursorPosition(this.el)
    this.pushEvent("update-cursor", {anchor_offset: anchorOffset, focus_offset: focusOffset, node: currentNodeCount})
  },
  mounted() {
    this.handleEvent("updated-content", this.updateContent.bind(this))
    this.handleEvent("updated-cursors", this.updateCursors.bind(this))
    this.el.addEventListener("input", this.sendLocalUpdates.bind(this), false)
    this.el.addEventListener("click", this.sendCursorUpdates.bind(this), false)
    this.el.addEventListener("keyup", this.sendCursorUpdates.bind(this), false)
  },
  updateContent({text}) {
    let [anchorOffset, focusOffset, currentNodeCount] = getCursorPosition(this.el)

    this.el.innerText = text

    let range = document.createRange()
    range.setStart(this.el.childNodes[currentNodeCount], focusOffset)
    range.setEnd(this.el.childNodes[currentNodeCount], anchorOffset)

    sel = window.getSelection()
    if (sel.rangeCount > 0) sel.removeAllRanges();
    sel.addRange(range)
  },
  updateCursors({cursors}) {
    document.querySelectorAll(".caret").forEach(el => el.remove())

    cursors.sort(sortById).forEach(({id, anchor_offset, focus_offset, node}, index) => {
      let range = document.createRange()
      let ends = [anchor_offset, focus_offset]
      range.setStart(this.el.childNodes[node], Math.min(...ends))
      range.setEnd(this.el.childNodes[node], Math.max(...ends))
      let rect = range.getBoundingClientRect()
      let div = document.createElement("div")
      div.style.height = `${rect.height}px`
      div.style.width = `${rect.width+1}px`
      div.style.left = `${rect.x-1}px`
      div.style.top = `${rect.y}px`
      div.style.backgroundColor = colors[index % colors.length]
      div.classList.add("caret")
      document.querySelector("body").appendChild(div);
    })
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

