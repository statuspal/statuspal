import { h, render, Component } from 'preact';
import { Charts, ChartContainer, ChartRow, YAxis, LineChart, Baseline, Resizable } from 'react-timeseries-charts';
import { TimeSeries } from 'pondjs';

const baselineStyleLite = {
  line: {
    stroke: 'steelblue',
    strokeWidth: 0.1,
    opacity: 0.3
  }
};

const lineStyle = {
  value: { normal: { strokeWidth: 2, stroke: '#2389f1' } }
};

function pad (n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

var DAY = 24 * 60 * 60 * 1000;
const DAYS = 90;
const calcAvg = times => Math.round(times.reduce(function (sum, t) { return sum + t.time_ms }, 0) / times.length);

const renderChart = ([title, times], small) => {
  var avg = calcAvg(times);
  var points = [];
  for (var i = DAYS; i > 0; i--) {
    var d = new Date(Date.now() - i * DAY);
    var day = d.getFullYear() + '-' + pad(d.getMonth() + 1, 2) + '-' + pad(d.getDate(), 2);
    var t = times.find(t1 => t1.day === day);
    points.push([Date.parse(day), t ? t.time_ms : (Math.floor(Math.random() * 30) + avg)]);
  }

  const series = new TimeSeries({
    name: title,
    columns: ['time', 'value'],
    points
  });
  return (
    <div className='response-time-chart'>
      <span className='rtime-title'>{title}</span>
      <span className='rtime'>{avg} ms</span>
      <div className='chart-container'>
        <Resizable>
          <ChartContainer timeRange={series.range()} format='%d %b' timeAxisTickCount={small ? 4 : 10}>
            <ChartRow height='100'>
              <YAxis
                id='axis1'
                min={series.min() - 100}
                max={series.max() + 100}
                width='30'
              />
              <Charts>
                <LineChart axis='axis1' series={series} style={lineStyle} />
                <Baseline axis='axis1' style={baselineStyleLite} value={series.max()} label='Max' position='right' />
                <Baseline axis='axis1' style={baselineStyleLite} value={series.min()} label='Min' position='right' />
                <Baseline axis='axis1' style={baselineStyleLite} value={series.avg()} label='Avg' />
              </Charts>
            </ChartRow>
          </ChartContainer>
        </Resizable>
      </div>
    </div>
  );
}

const SMALL_WIDTH = 500;

class RTCharts extends Component {
  constructor () {
    super();
    this.state = { small: window.innerWidth < SMALL_WIDTH };
    window.onresize = () => {
      this.setState({ small: window.innerWidth < SMALL_WIDTH });
    };
  }

  render ({ rTimes }, { small }) {
    return (
      <div>
        {rTimes.map((t) => renderChart(t, small))}
      </div>
    )
  }
}

export const renderCharts = (rTimes) => {
  render((
    <RTCharts rTimes={rTimes} />
  ), document.getElementsByClassName('charts')[0]);
}
