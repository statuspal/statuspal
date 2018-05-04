import { h, render, Component } from 'preact';
import Plotly from 'plotly.js/lib/core';
import createPlotlyComponent from 'react-plotly.js/factory';

Plotly.register([require('plotly.js/lib/scatter')]);
const Plot = createPlotlyComponent(Plotly);

function pad (n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

var DAY = 24 * 60 * 60 * 1000;
const DAYS = 90;
const calcAvg = times =>
  times.length === 0 ? 0 : times.reduce((sum, t) => sum + t.time_ms, 0) / times.length;

const renderChart = ([title, times], width) => {
  var avg = calcAvg(times);
  var pointsX = [];
  var pointsY = [];
  for (var i = DAYS; i >= 0; i--) {
    var d = new Date(Date.now() - i * DAY);
    var day = d.getFullYear() + '-' + pad(d.getMonth() + 1, 2) + '-' + pad(d.getDate(), 2);
    var t = times.find(t1 => t1.day === day);
    pointsX.push(day);
    pointsY.push(t ? t.time_ms : avg === 0 ? 0 : (Math.random() * (avg * 0.1) + avg));
  }

  return (
    <div className='response-time-chart'>
      <span className='rtime-title'>{title} Response Time</span>
      <span className='rtime'>{Math.round(avg)} ms</span>
      <div className='chart-container'>
        <Plot
          data={[
            {
              x: pointsX,
              y: pointsY,
              type: 'scatter',
              mode: 'lines+points',
            },
          ]}
          layout={{
            height: 130,
            width,
            margin: { t: 23, l: 35, r: 20, b: 35 },
            font: { size: 10 },
            yaxis: {
              rangemode: 'tozero',
              fixedrange: true,
            },
            xaxis: { fixedrange: true },
          }}
          config={{ displayModeBar: false }}
        />
      </div>
    </div>
  );
}

const getWidth = () => document.querySelector('.charts').clientWidth - 2;

class RTCharts extends Component {
  constructor () {
    super();
    this.state = { width: getWidth() };
    window.onresize = () => {
      this.setState({ width: getWidth() });
    };
  }

  render ({ rTimes }, { width }) {
    return (
      <div>
        {rTimes.map((t) => renderChart(t, width))}
      </div>
    )
  }
}

export const renderCharts = (rTimes) => {
  render((
    <RTCharts rTimes={rTimes} />
  ), document.getElementsByClassName('charts')[0]);
}
