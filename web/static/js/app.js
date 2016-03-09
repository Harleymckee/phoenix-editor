// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import React from "react"
import ReactDOM from "react-dom"
import ReactQuill from "react-quill"
import socket from './socket'

class Editor extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      content: '',
      channel: socket.channel("topic:general"),
    }
    this.state.channel.join()
      .receive("ok", (cool) => { console.log('you in') })
      .receive("error", () => { console.log('something bad happened') })
    this.state.channel.on("message", payload => {
      this.setState({content: payload.body})
    })
  }

  onChange(e) {
    this.setState({content: e.target.innerHTML})
    this.state.channel.push("message", {body: e.target.innerHTML})
  }

  render() {
    return (
      <ReactQuill
        theme="snow"
        onKeyUp={this.onChange.bind(this)}
        value={this.state.content}
      />
    )
  }
}

ReactDOM.render(
  <Editor/>,
  document.getElementById('editor')
)
