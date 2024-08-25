// (msw) This should be loaded syncronously (don't defer or async) before the page
// loads in. It prevents users in dark mode from getting flashed by a bright
// light when the page loads in.

try {
  ; (function () {
    if (
      document.querySelector('html').getAttribute('data-ignore-theme') != null
    ) {
      // Ignore the user's theme preference
      return
    }

    // type: 'dark' | 'light' | 'system' | null
    const darkModeConfig = localStorage.getItem('theme') || "system";

    if (
      darkModeConfig === 'dark' ||
      (darkModeConfig === 'system' && window.matchMedia?.('(prefers-color-scheme: dark)')?.matches)
    ) {
      document.querySelector('html').setAttribute('data-dark', darkModeConfig)
      document.querySelector('meta[name=theme-color]')?.setAttribute('content', '#17171d')
    }
  })()
} catch (e) {
  if (e instanceof DOMException) {
    // when used inside the donation iframe, localStorage will throw a DOMException in some browsers that block third-party cookies
  } else {
    throw e
  }
}
