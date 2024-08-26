// This script is only used to set the theme when the cookie `theme` is set to `system`

try {
  ; (function () {
    if (
      document.querySelector('html').getAttribute('data-ignore-theme') != null
    ) {
      // Ignore the user's theme preference
      return
    }

    const isThemeExplicitlySet = !['dark', 'light'].includes(document.cookie.split('; ').find(row => row.startsWith('theme='))?.split('=')[1]);

    if (!isThemeExplicitlySet && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      document.querySelector('html').setAttribute('data-dark', isThemeExplicitlySet ? "true" : "false")
      document.querySelector('meta[name=theme-color]')?.setAttribute('content', '#17171d')
    }
  })()
} catch (e) {
  console.log('Dark theme script error:', e)
}
