var DAY = 24*60*60*1000;

export default function uptimeGraph(incidents) {
  incidents.forEach(function(i) {
    i.starts_at = new Date(i.starts_at);
    i.ends_at = i.ends_at ? new Date(i.ends_at) : null;
  });
  var days = 60;
  var d = new Date();
  var arr = [];
  var IC_MAJOR = 'red';
  var IC_MINOR = 'orange';
  var IC_OK = '#10bb70';

  for (var i = days; i > 0; i--) {
    var dayStart = new Date(d - i*DAY);
    dayStart.setHours(0,0,0,0);
    var dayEnd = dayStart.getTime() + DAY;
    var incidentTypes = {};
    incidents.forEach(function(i) {
      var iStart = i.starts_at < dayStart ? dayStart : i.starts_at;
      var iEnd = !i.ends_at || i.ends_at > dayEnd ? dayEnd : i.ends_at;
      if (iStart < dayEnd && iEnd > dayStart) {
        if (!incidentTypes[i.type]) incidentTypes[i.type] = { n: 0, hours: 0 };
        incidentTypes[i.type].n += 1;
        incidentTypes[i.type].hours += (iEnd - iStart) / (1000*60*60);
      }
    });
    arr.push({
      day: dayStart,
      incidents: incidentTypes
    });
    var segment = document.createElement('div');
    var gradientStyle = "";
    var mssg = dayStart.toString().split('00')[0]+"\n";
    var percTotal = 0;
    if (incidentTypes["a"]) {
      var incident = incidentTypes['a'];
      var perc = incident.hours/(24/100) + percTotal;
      gradientStyle += IC_MAJOR+' '+percTotal+'%, '+IC_MAJOR+' '+perc+'%, ';
      percTotal = perc;
      mssg += incident.n+' Major incidents\n';
    }
    if (incidentTypes['i']) {
      var incident = incidentTypes['i'];
      var perc = incident.hours/(24/100) + percTotal;
      gradientStyle += IC_MINOR+' '+percTotal+'%, '+IC_MINOR+' '+perc+'%, ';
      percTotal = perc;
      mssg += incident.n+' Minor incidents';
    }
    if (!incidentTypes['a'] && !incidentTypes['i']) mssg += 'No incidents';
    gradientStyle += IC_OK+' '+percTotal+'%, '+IC_OK+' 100% ';
    segment.style.background = 'linear-gradient(0deg,'+gradientStyle+')';
    segment.title = mssg;
    document.querySelectorAll('.incidents-history .segments')[0].append(segment);
  }
}
