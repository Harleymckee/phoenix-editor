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
    this.state = {activeRoom: "general", messages: '', channel: socket.channel("topic:general")}
  }
  // TODO: fluxify
  configureChannel(channel) {
    channel.join()
      .receive("ok", (cool) => {
        console.log('you in')
      })
      .receive("error", () => { console.log(`Unable to join the ${this.state.activeRoom} chat room.`) })
    channel.on("message", payload => {
      this.setState({messages: payload.body})
    })
  }

  handleMessageSubmit(message) {
    this.state.channel.push("message", {body: message})
  }

  // handleRoomLinkClick(room) {
  //   let channel = this.props.socket.channel(`topic:${room}`)
  //   this.setState({activeRoom: room, messages: [], channel: channel})
  //   this.configureChannel(channel)
  // }

  componentDidMount() {
    this.configureChannel(this.state.channel)
  }

  onChange(newValue) {
    this.handleMessageSubmit(newValue)
  }

  render() {
    return (
      <div>
        <ReactQuill
          onChange={this.onChange.bind(this)}
          value={this.state.messages}
        />
      </div>
    )
  }
}

ReactDOM.render(
  <Editor/>,
  document.getElementById('editor')
)
