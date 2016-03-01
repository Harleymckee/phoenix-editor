import "deps/phoenix_html/web/static/js/phoenix_html"
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
      busy: false
    }
    this.state.channel.join()
      .receive("ok", (cool) => { console.log('you in') })
      .receive("error", () => { console.log('something bad happened') })
    this.state.channel.on("message", payload => {
      this.setState({content: payload.body})
    })
  }

  onChange(content) {
    // TODO: figure out loop shit
    this.state.channel.push("message", {body: content})
  }

  render() {
    return (
      <ReactQuill
        theme="snow"
        onChange={this.onChange.bind(this)}
        value={this.state.content}
      />
    )
  }
}

ReactDOM.render(
  <Editor/>,
  document.getElementById('editor')
)
