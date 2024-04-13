import Appsignal from '@appsignal/javascript'

const appsignal =
  environment != 'development'
    ? new Appsignal({
        key: '<YOUR FRONTEND API KEY>',
        namespace: 'frontend',
      })
    : null

module.exports = { appsignal }
