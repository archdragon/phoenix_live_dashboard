/** LiveView Hook **/

const setCookie = (cookieKey, cookieValue) => {
  document.cookie = `${cookieKey}=${cookieValue}`;
}

const removeCookie = (cookieKey) => {
  document.cookie = `${cookieKey}=; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
}

const PhxRequestLoggerCookie = {
  updated() {
    const cookieEnabled = this.el.getAttribute('data-cookie-enabled')
    const cookieKey = this.el.getAttribute('data-cookie-key')
    const cookieValue = this.el.getAttribute('data-cookie-value')

    if (cookieEnabled === "true") {
      setCookie(cookieKey, cookieValue)
    } else {
      removeCookie(cookieKey)
    }
  }
}

export default PhxRequestLoggerCookie

