import "deps/phoenix_html/web/static/js/phoenix_html"
import React from "react"
import ReactDOM from "react-dom"
import ReactQuill from "react-quill"
import {Editor, EditorState, ContentState, convertToRaw, convertFromRaw, getCurrentContent} from 'draft-js';
import socket from './socket'

// // class Collab extends React.Component {
//   constructor(props) {
//     super(props)
//     this.state = {
//       content: '',
//       channel: socket.channel("topic:general"),
//       editorState: EditorState.createEmpty()
//     }
//     this.state.channel.join()
//       .receive("ok", (cool) => { console.log('you in') })
//       .receive("error", () => { console.log('something bad happened') })
//     this.state.channel.on("message", payload => {
//       this.setState({content: payload.body})
//     })
//     //this.state = {editorState: EditorState.createEmpty()};
//     this.onChange = (editorState) => {
//       debugger
//       this.setState({editorState})
//     }
//   }
//
//   // onChange(content) {
//   //   debugger
//   //   // TODO: figure out loop shit
//   //   this.state.channel.push("message", {body: content})
//   // }
//
//   render() {
//     const {editorState} = this.state
//     return (
//       <div>
//       <Editor editorState={editorState} onChange={this.onChange}/>
//       <ReactQuill
//         theme="snow"
//         onChange={this.onChange.bind(this)}
//         value={this.state.content}
//       />
//       </div>
//     )
//   }
// }


class MyEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      channel: socket.channel("topic:general"),
      editorState: EditorState.createEmpty(),
    }

    this.state.channel.join()
      .receive("ok", cool => { console.log('you in') })
      .receive("error", () => { console.log('something bad happened') })

    this.state.channel.on("message", payload => {
      const parsed = convertFromRaw(JSON.parse(payload.body))
      //console.log(this.state.editorState)
      //this.state.editorState.push(this.state.editorState, ContentState.createFromBlockArray(parsed))

      this.setState({editorState: EditorState.createWithContent(ContentState.createFromBlockArray(parsed))})
    })

    this.onChange = (editorState) => {
      this.state.channel.push("message", {body: JSON.stringify(convertToRaw(editorState.getCurrentContent()))})
      //console.log(convertToRaw(editorState.getCurrentContent()))
      this.setState({editorState})
    }
  }

  render() {
    const {editorState} = this.state;
    return <div>
      <Editor editorState={editorState} onChange={this.onChange} />
      <div onClick={() => this.state.channel.push("message", {body: JSON.stringify(convertToRaw(this.state.editorState.getCurrentContent()))})}>
      lol
      </div>
    </div>
  }
}

ReactDOM.render(
  <MyEditor/>,
  document.getElementById('editor')
)
