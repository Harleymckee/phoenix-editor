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
      saving: false,
      channel: socket.channel("topic:general"),
    }
    this.state.channel.join()
      .receive("ok", (cool) => { console.log('you in') })
      .receive("error", () => { console.log('something bad happened') })
    this.state.channel.on("message", payload => {
      if (!this.state.saving) {
        this.setState({content: payload.body})
        this.previousValue = payload.body
      }
    })
    setInterval(() => {
      if(this.didChangeOccur) {
        this.state.channel.push("message", {body: this.state.content})
        this.state.saving = false
      }
    }, 1000)
  }

  get didChangeOccur(){
    if(this.previousValue != this.state.content){
       return true
    }
    return false
  }

  get saving() {
    if (this.state.saving) {
      return <div>
          ... saving
        </div>
    }
    return null
  }

  onChange(content) {
    this.state.saving = true
    this.setState({content: content})
  }

  render() {
    return (
      <div>
        <ReactQuill
          theme="snow"
          onChange={this.onChange.bind(this)}
          value={this.state.content}
        />
        {this.saving}
      </div>
    )
  }
}

ReactDOM.render(
  <Editor/>,
  document.getElementById('editor')
)
