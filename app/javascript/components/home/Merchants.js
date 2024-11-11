import React from 'react'
import { Bar, BarChart, CartesianGrid, Cell, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import PropTypes from 'prop-types'
import { colors, shuffle, USDollarNoCents } from './utils'
import { CustomTooltip } from './components'

export default function Merchants({ data }) {
  let shuffled = shuffle(colors)

  return (
    <ResponsiveContainer
      width="100%"
      height={450}
      padding={{ top: 32, left: 32 }}
    >
      <BarChart data={data} width={256} height={200}>
        <CartesianGrid strokeDasharray="3 3" opacity={0.5} />
        <YAxis
          tickFormatter={n => USDollarNoCents.format(n)}
          width={
            USDollarNoCents.format(Math.max(data.map(d => d['value']))).length *
            18
          }
        />
        {data.length > 8 ? (
          <XAxis
            dataKey={'truncated'}
            textAnchor="end"
            verticalAnchor="start"
            interval={0}
            angle={-60}
            height={120}
          />
        ) : (
          <XAxis dataKey={'truncated'} />
        )}
        <Tooltip content={CustomTooltip} />
        <Bar dataKey="value">
          {data.map((c, i) => (
            <Cell key={c.truncated} fill={shuffled[i % shuffled.length]} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  )
}

Merchants.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      truncated: PropTypes.string,
      value: PropTypes.number,
    })
  ).isRequired,
}
