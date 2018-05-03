import uptimeGraph from './uptime-graph';

var $ = document.querySelector.bind(document);

if (window.incidents) uptimeGraph(window.incidents);
if (window.rTimes && window.rTimes.length > 0) {
  import(/* webpackChunkName: "renderChart" */ './chart').then(({ renderCharts }) => {
    renderCharts(window.rTimes);
  });
}

window.onload = function () {
  var subsBtn = $('.subscribe');
  var modal = $('.modal');
  var modalBackdrop = $('.modal-backdrop');

  if (subsBtn) {
    subsBtn.onclick = function () {
      modal.classList.add('shown');
      modalBackdrop.classList.add('shown');
      return false;
    };
  }

  modalBackdrop.onclick = function () {
    modal.classList.remove('shown');
    modalBackdrop.classList.remove('shown');
  };
};
