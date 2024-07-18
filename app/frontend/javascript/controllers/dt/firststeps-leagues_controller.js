import { Controller } from "@hotwired/stimulus"
import "@js/base/datatables"

export default class extends Controller {
  connect() {
    $('#dt-firststeps-leagues').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/firststeps/get_proc_dt'
      },
      initComplete: function (settings) {
        sessionStorage.setItem('initialSort', JSON.stringify([[0,"asc"]]));
      },
      order: [
          [0, "asc"]
      ],
      columns: [
        { name: 'name', data: 'name'},
        { name: 'platform', data: 'platform'},
        { name: 'slots', data: 'slots'},
        { name: 'users', data: 'users' },
        { name: 'DT_Actions', data: 'DT_Actions'}
      ],
      columnDefs: [
          {
              targets: [1,2,3,-1],
              className: 'text-center'
          },
          {
              orderable: false,
              targets: [-1]
          },
          {
              searchable: false,
              targets: [1,3,-1]
          }
      ],
    });
  }
}
