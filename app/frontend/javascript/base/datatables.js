import dataTable from "datatables.net-bs5"

$.extend( $.fn.DataTable.defaults, {
  searching: true,
  stateSave: true,
  paging: true,
  processing: true,
  serverSide: true,
  iDisplayLength: 15,
  drawCallback: function (settings) {
    if (sessionStorage.getItem('clearDTState') === 'true') {
      if ( sessionStorage.getItem('initialSort') ) {
        if ( parseInt(JSON.parse(sessionStorage.getItem('initialSort'))[0][0]) >= parseInt(this.DataTable().init().columns.length) ) {
          sessionStorage.setItem('initialSort', JSON.stringify([[1,"asc"]]))
        }
        this.DataTable().search('').columns().search('').order().state.clear()
        this.DataTable().columns().header()[JSON.parse(sessionStorage.getItem('initialSort'))]      
        this.DataTable().order(JSON.parse(sessionStorage.getItem('initialSort')))
        this.DataTable().draw()
      }
      sessionStorage.removeItem('initialSort')
    }
    sessionStorage.setItem('clearDTState', false)
  },
  ajax: {
    type: 'POST'
  },
  pagingType: "numbers",
  columnDefs: [
    {
      targets: '_all',
      defaultContent: '-'
    }
  ],
  language: { url: '/dt_i18n?locale=' + $('body').attr('data-locale') },
    dom: 't<"info d-flex justify-content-between mx-0 row mt-1"<"col-6 d-none d-sm-block"i><"col-6 d-block d-sm-none "><"col-6 "p>>r', "initComplete": function(settings, json) {
      $(".info").appendTo($("#tableDom"))
    }
} );
