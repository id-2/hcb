import PropTypes from 'prop-types'
import React from 'react'
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { CustomTooltip } from './components'
import { generateColor, USDollarNoCents, useDarkMode } from './utils'

export default function Users({ data }) {
  const isDark = useDarkMode()

  return (
    <ResponsiveContainer
      width="100%"
      height={420}
      padding={{ top: 32, left: 32 }}
    >
      <BarChart data={data} width={256} height={128} layout="vertical">
        <CartesianGrid
          strokeDasharray="3 3"
          stroke={'rgba(200, 200, 200, 0.3)'}
        />
        <XAxis
          type="number"
          tickFormatter={n => USDollarNoCents.format(n)}
          width={
            USDollarNoCents.format(Math.max(data.map(d => d['value']))).length *
            18
          }
        />
        <YAxis
          type="category"
          dataKey="name"
          textAnchor="end"
          verticalAnchor="start"
          interval={0}
          height={80}
        />
        <Tooltip content={CustomTooltip} cursor={{ fill: 'transparent' }} />
        <Bar dataKey="value">
          {data.map((c, i) => (
            <Cell key={c.name} fill={generateColor(i, isDark)} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  )
}

Users.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string,
      value: PropTypes.number,
    })
  ).isRequired,
}