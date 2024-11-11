import Intl from 'intl'
import 'intl/locale-data/jsonp/en-US'
import { useEffect, useState } from 'react'

export const colors = Array.from(
  { length: 11 },
  (_, i) => `hsl(352, 83%, ${70 - i * 5}%)`
)

export const shuffle = array => {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[array[i], array[j]] = [array[j], array[i]]
  }
  return array
}

export const USDollar = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
})

export const USDollarNoCents = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
})

export const useDarkMode = () => {
  const [isDarkMode, setIsDarkMode] = useState(false)

  useEffect(() => {
    const currentTheme = document.documentElement.getAttribute('data-dark')
    setIsDarkMode(currentTheme === 'true')

    // Observer to watch for changes to data-theme attribute
    const observer = new MutationObserver(() => {
      const updatedTheme = document.documentElement.getAttribute('data-dark')
      setIsDarkMode(updatedTheme === 'true')
    })

    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-dark'],
    })

    return () => {
      observer.disconnect()
    }
  }, [])

  return isDarkMode
}
