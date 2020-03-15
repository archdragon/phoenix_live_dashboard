/** LiveView Hook **/

const checkCookie = (params) => {
  const resultsCount = document.cookie
    .split(';')
    .filter((item) => item.includes(`${params.key}=${params.value}`))
    .length

  return resultsCount > 0
}

const setCookie = (params) => {
  document.cookie = `${params.key}=${params.value};samesite=strict;path=/`;
}

const removeCookie = (params) => {
  const pastDate = 'Thu, 01 Jan 1970 00:00:00 GMT'
  document.cookie = `${params.key}=; expires=${pastDate}`
}

const isCookieEnabled = (hook) => {
  return hook.el.getAttribute('data-cookie-enabled') === 'true'
}

const cookieParams = (hook) => {
  return {
    key: hook.el.getAttribute('data-cookie-key'),
    value: hook.el.getAttribute('data-cookie-value')
  }
}

const PhxRequestLoggerCookie = {
  mounted() {
    const loggerCookieParams = cookieParams(this)
    let eventParams = {}

    alert(checkCookie(loggerCookieParams))

    if (checkCookie(loggerCookieParams)) {
      eventParams = {enable: "true"}
    }

    this.pushEvent("toggle_cookie", eventParams)
  },

  updated() {
    const loggerCookieParams = cookieParams(this)
    removeCookie(loggerCookieParams)

    if (isCookieEnabled(this)) {
      setCookie(loggerCookieParams)
    }
  },
}

export default PhxRequestLoggerCookie

