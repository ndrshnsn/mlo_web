import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"

export default class extends Controller {
  connect() {
    $('#dt-admin-insights-activities').dataTable({
      iDisplayLength: 50,
      ajax: {
          url: '/admin/insights/activities/get_proc_dt',
      },
      order: [
          [0, "desc"]
      ],
      columns: [
        { name: 'created', data: 'created'},
        { name: 'type', data: 'type' },
        { name: 'element', data: 'element' },
        { name: 'action', data: 'action' },
        { name: 'owner', data: 'owner' },
        { name: 'params', data: 'params' }
      ],
      columnDefs: [
          {
              targets: [0,1],
              className: 'text-center'
          },
          {
              orderable: false,
              targets: [-1]
          },
          {
              searchable: false,
              targets: []
          }
      ]
    })
  }
}
