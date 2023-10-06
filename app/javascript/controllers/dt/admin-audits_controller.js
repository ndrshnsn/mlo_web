import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"

export default class extends Controller {
  connect() {
    $('#dt-admin-insights-audits').DataTable({
      iDisplayLength: 50,
      ajax: {
          url: '/admin/insights/audits/get_proc_dt',
      },
      initComplete: function (settings) {
        sessionStorage.setItem('initialSort', JSON.stringify([[0,"desc"]]));
      },
      order: [
          [0, "desc"]
      ],
      columns: [
        {data: 'created'},
        {data: 'version'},
        {data: 
          {
            _: 'type',
            sort: 'type_id'
          }
        },
        {data: 'owner'},
        {data: 'action'},
        {data: 'DT_Actions'}
      ],
      columnDefs: [
        {
          targets: [0,1,3,4,-1],
          className: 'text-center'
        },
        {
          orderable: false,
          targets: [-1]
        },
        {
          searchable: false,
          targets: []
        },
        {
          visible: false,
          targets: []
        }
      ]
    })
  }
}
