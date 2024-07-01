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
  PieChart,
  Legend,
  Pie
} from 'recharts'
import Intl from 'intl'
import 'intl/locale-data/jsonp/en-US'
import PropTypes from 'prop-types'

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

const colors = [
  '#ec3750', // red
  '#ff8c37', // orange
  '#f1c40f', // yellow
  '#33d6a6', // green
  '#5bc0de', // cyan
  '#338eda', // blue
  '#a633d6', // purple
  "#f27b8d",
  "#ee5068",
  "#ca2f46",
  "#f29f73",
  "#ee834b",
  "#d66b32",
  "#8fc32d",
  "#80ae29",
  "#6d9523",
  "#3fb72b",
  "#379d25",
  "#30cc66",
  "#2bb75b",
  "#259d4e",
  "#2fc8b1",
  "#2ab39e",
  "#249988",
  "#5ebdf0",
  "#36a9e7",
  "#2e91c6",
  "#24739d",
  "#15435c",
  "#8a9af4",
  "#6c80f1",
  "#435ced",
  
]

const shuffle = array => {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[array[i], array[j]] = [array[j], array[i]]
  }
  return array
}

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

const RADIAN = Math.PI / 180;

const renderCustomizedLabel = ({ cx, cy, midAngle, innerRadius, outerRadius, percent, index }) => {
  const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
  const x = cx + radius * Math.cos(-midAngle * RADIAN);
  const y = cy + radius * Math.sin(-midAngle * RADIAN);
  if(percent < 0.10){
    return <></>
  }
  return (
    <text x={x} y={y} fill="white" textAnchor={x > cx ? 'start' : 'end'} dominantBaseline="central">
      {`${(percent * 100).toFixed(0)}%`}
    </text>
  );
};

const renderLegend = (props) => {
  const { payload } = props;
  return (
    <>
      <div style={{ textAlign: 'center', marginTop: '8px', textWrap: 'balance' }}>
        {
          payload.slice(0,7).map((entry, index) => (
            <span key={`item-${index}`} style={{color: entry.color, fontWeight: 400, textWrap: 'none', marginRight: '16px'}}>
              ●{'\u00A0'}{entry.payload.truncated}
            </span>
          ))
        }
      </div>
      { payload.length > 7 &&
        <div style={{ textAlign: 'center'}} className="muted mt1" >
          And {payload.length - 7} additional categories...
        </div>
      }
    </>
  );
}
<Legend content={renderLegend} />
   

export default function Users({ data }) {
  let shuffled = shuffle(colors)
  return (
    <PieChart width={400} height={400}>
      <Pie data={data} dataKey="value" nameKey="truncated" cx="50%" cy="50%" outerRadius={115} fill="#82ca9d" labelLine={false} label={renderCustomizedLabel}>
        {data.map((entry, index) => (
          <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />
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
      truncated: PropTypes.string,
      value: PropTypes.number,
    })
  ).isRequired,
}
