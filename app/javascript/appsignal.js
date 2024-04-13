import Appsignal from '@appsignal/javascript'

const environment = process.env.NODE_ENV || 'development'

const appsignal =
  environment != 'development'
    ? new Appsignal({
        key: '<YOUR FRONTEND API KEY>',
        namespace: 'frontend',
      })
    : null

module.exports = { appsignal }
