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
import PropTypes from 'prop-types'
import { colors, shuffle, USDollarNoCents, useDarkMode } from './utils'
import { CustomTooltip } from './components'

export default function Merchants({ data }) {
  let shuffled = shuffle(colors)
  const isDark = useDarkMode()

  return (
    <ResponsiveContainer
      width="100%"
      height={420}
      padding={{ top: 32, left: 32 }}
    >
      <BarChart data={data} width={256} height={128}>
        <CartesianGrid
          strokeDasharray="3 3"
          stroke={isDark ? '#252429' : '#e0e6ed'}
        />
        <YAxis
          tickFormatter={n => USDollarNoCents.format(n)}
          width={
            USDollarNoCents.format(Math.max(data.map(d => d['value']))).length *
            18
          }
        />
        {data.length > 8 ? (
          <XAxis
            dataKey="name"
            textAnchor="end"
            verticalAnchor="start"
            interval={0}
            angle={-60}
            height={80}
          />
        ) : (
          <XAxis dataKey="name" />
        )}
        <Tooltip content={CustomTooltip} />
        <Bar dataKey="value">
          {data.map((c, i) => (
            <Cell key={c.name} fill={shuffled[i % shuffled.length]} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  )
}

Merchants.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string,
      value: PropTypes.number,
    })
  ).isRequired,
}
