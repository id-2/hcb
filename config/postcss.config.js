module.exports = {
  syntax: 'postcss-scss',
  map: false,
  plugins: {
    '@csstools/postcss-sass': {},
    tailwindcss: { config: 'config/tailwind.config.js' },
    autoprefixer: {},
    cssnano: process.env.NODE_ENV !== 'development' ? {} : false,
  },
}
