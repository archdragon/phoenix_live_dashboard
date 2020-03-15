/** LiveView Hook **/

const copyToClipboard = (textarea) => {
    if (!navigator.clipboard){
      // Depracated clipboard API
      textarea.select()
      textarea.setSelectionRange(0, 99999)
      document.execCommand('copy')
    } else {
      // Modern Clipboard API
      const text = textarea.value
      navigator.clipboard.writeText(text)
    }
  }

const PhxRequestLoggerQueryParameters = {
  mounted() {
    this.el.querySelector('.btn-primary').addEventListener('click', e => {
      const textarea = this.el.querySelector('textarea')
      copyToClipboard(textarea)
    })
  }
}

export default PhxRequestLoggerQueryParameters
