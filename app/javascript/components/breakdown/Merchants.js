import React from 'react'
import {
  Tooltip,
  ResponsiveContainer,
  BarChart,
  YAxis,
  Bar,
  Cell,
  XAxis,
  CartesianGrid,
} from 'recharts'
import Intl from 'intl'
import 'intl/locale-data/jsonp/en-US'
import PropTypes from 'prop-types'

export const USDollar = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
})

const colors = [
  "#000000", "#111111", "#222222", "#333333", "#444444", "#555555", "#666666", "#777777", "#888888", "#999999",
  "#aaaaaa", "#bbbbbb", "#cccccc", "#dddddd", "#eeeeee", "#f0f0f0", "#f1f1f1", "#f2f2f2", "#f3f3f3", "#f4f4f4",
]

const shuffle = array => {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
      ;[array[i], array[j]] = [array[j], array[i]]
  }
  return array
}

export const USDollarNoCents = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
})

const CustomTooltip = ({ active, payload }) => {
  if (active && payload && payload.length) {
    return (
      <div
        style={{
          color: 'white',
          background: '#1f2d3d',
          borderRadius: '8px',
          padding: '0.25rem 0.75rem',
        }}
      >
        {payload[0].payload.name} <br />
        {USDollar.format(payload[0].value)}
      </div>
    )
  }

  return null
}

CustomTooltip.propTypes = {
  active: PropTypes.bool,
  payload: PropTypes.arrayOf(
    PropTypes.shape({
      payload: PropTypes.shape({
        name: PropTypes.string,
      }),
      value: PropTypes.number,
    })
  ),
}

export default function Users({ data }) {
  let shuffled = shuffle(colors)
  return (
    <ResponsiveContainer
      width="100%"
      height={450}
      padding={{ top: 32, left: 32 }}
    >
      <BarChart data={data} width={256} height={200}>
        <CartesianGrid strokeDasharray="3 3" />
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
            angle={'-60'}
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

Users.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      truncated: PropTypes.string,
      value: PropTypes.number,
    })
  ).isRequired,
}
