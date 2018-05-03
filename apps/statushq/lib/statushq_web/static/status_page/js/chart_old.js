var $ = document.querySelector.bind(document);
function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}
function vEl(n, v) {
  n = document.createElementNS("http://www.w3.org/2000/svg", n);
  for (var p in v) n.setAttributeNS(null, p, v[p]);
  return n
}
function el(type, attrs) {
  var n = document.createElement(type);
  for (var k in attrs) n[k] = attrs[k];
  return n
}



var DAY = 24*60*60*1000;
var VB_X = 1000;
var VB_Y = 100;
var DAYS = 90;
var MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
var X_N_LABELS = 10;

// response times graph

// var rTimes = <%= raw Poison.encode! @r_times %>;

var times = [];
for (var i = DAYS; i > 0; i--) {
  var d = new Date(Date.now() - i * DAY);
  times.push({
    day: d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate(),
    time_ms: (Math.floor(Math.random() * 5) + 150),
  });
}
var rTimes = [['API', times]];

rTimes.forEach(function(chartData) {
  var times = chartData[1];
  var maxY = Math.max.apply(this, times.map(function(t) { return t.time_ms }));
  var minY = Math.min.apply(this, times.map(function(t) { return t.time_ms }));
  var diff = maxY - minY;
  var Y_STEP = diff > 1000 ? 500 : (diff > 500 ? 250 : 100);
  // var Y_STEP
  // if (diff > 1000) Y_STEP = 500;
  // else if (diff > 500) Y_STEP = 250;
  // else if (diff > 100) Y_STEP = 100;
  // else if (diff > 10) Y_STEP = 25;
  // else Y_STEP = 10;
  var MAXY = Math.ceil(maxY / Y_STEP) * Y_STEP;
  var MINY = Math.floor(minY / Y_STEP) * Y_STEP;
  var AVG = Math.round(times.reduce(function(sum, t) { return sum + t.time_ms }, 0) / times.length);

  var aTimes = [];
  for (var i = DAYS; i > 0; i--) {
    var d = new Date(Date.now() - i * DAY);
    var day = d.getFullYear()+'-'+pad(d.getMonth()+1, 2)+'-'+pad(d.getDate(), 2);
    if (day === '2018-4-23') debugger;
    var t = times.find(function(t1) { return t1.day === day; })
    aTimes.push({ day: day, time_ms: t ? t.time_ms : (Math.floor(Math.random() * 30) + AVG) });
  }
  times = aTimes;

  var getVBX = function (v) { return VB_X-(v/DAYS)*VB_X; };
  var getVBY = function (v) { return VB_Y-((v-MINY)/(MAXY-MINY))*VB_Y; };

  var container = el('div', { className: 'response-time-chart' });
  var svg = vEl('svg', { viewBox: '0 0 '+VB_X+' '+VB_Y });
  container.appendChild(el('span', { className: 'rtime-title', innerText: chartData[0]+' Response Time' }));
  container.appendChild(el('span', { className: 'rtime', innerText: AVG+' ms' }));
  container.appendChild(svg);

  // vertical lines + y-labels
  for (var i = MINY; i <= MAXY; i+=Y_STEP) {
    var y = getVBY(i);
    svg.appendChild(vEl('line', { class: 'grid', x1: 0, y1: y, x2: VB_X, y2: y }));
    var t = vEl('text', { class: 'y-labels', x: 0, y: y - 4 });
    t.textContent = i;
    svg.appendChild(t);
  }

  // x-labels
  var start = Date.now() - DAY;
  for (var i = 0; i < X_N_LABELS; i++) {
    var d = new Date(start - i * (DAYS/X_N_LABELS) * DAY);
    var t = vEl('text', { class: 'x-labels', x: getVBX(i * (DAYS/X_N_LABELS)) - 50, y: VB_Y + 18 });
    t.textContent = MONTHS[d.getMonth()]+' '+d.getDate();
    svg.appendChild(t);
  }

  // line
  var timesStr = times.reverse().map(function(t, i) { return [getVBX(i), getVBY(t.time_ms)].join(','); }).join('\n');
  var r = vEl('polyline', { points: timesStr, class: 'line' });
  svg.appendChild(r);

  $('.charts').appendChild(container);
});
