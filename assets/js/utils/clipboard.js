const Clipboard = {
  copy() {
    if (!navigator.clipboard){
    // use old commandExec() way
    } else{
      navigator.clipboard.writeText(text_to_copy)
    }
  }
}

export default Clipboard
