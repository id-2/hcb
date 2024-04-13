import Appsignal from '@appsignal/javascript'
import { plugin as breadcrumbsConsole } from '@appsignal/plugin-breadcrumbs-console'
import { plugin as breadcrumbsNetwork } from '@appsignal/plugin-breadcrumbs-network'
import { plugin as pathDecorator } from '@appsignal/plugin-path-decorator'

const environment = process.env.NODE_ENV || 'development'

const appsignal =
  environment != 'development'
    ? new Appsignal({
        key: '<YOUR FRONTEND API KEY>',
        namespace: 'frontend',
      })
    : null

if (appsignal) {
  appsignal.use(breadcrumbsConsole())
  appsignal.use(breadcrumbsNetwork())
  appsignal.use(pathDecorator())
}

export default appsignal
