import React from 'react'
import { Cell, Legend, Pie, PieChart, Tooltip } from 'recharts'
import 'intl/locale-data/jsonp/en-US'
import PropTypes from 'prop-types'
import { colors, shuffle, useDarkMode } from './utils'
import { CustomTooltip, renderLegend } from './components'

export default function Users({ data }) {
  let shuffled = shuffle(colors)
  const isDark = useDarkMode()

  return (
    <PieChart width={400} height={400}>
      <Pie
        data={data}
        dataKey="value"
        nameKey="name"
        cx="50%"
        cy="50%"
        outerRadius={140}
        fill="#82ca9d"
        label={({ percent }) =>
          percent > 0.1 ? `${(percent * 100).toFixed(0)}%` : ''
        }
        labelLine={false}
        strokeWidth={2}
        stroke={isDark ? '#252429' : '#FFFFFF'}
      >
        {data.map((_, index) => (
          <Cell
            key={`cell-${index}`}
            style={{ outline: 'none' }}
            fill={shuffled[index % colors.length]}
          />
        ))}
      </Pie>
      <Tooltip content={CustomTooltip} />
      <Legend layout="horizontal" content={renderLegend} />
    </PieChart>
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
