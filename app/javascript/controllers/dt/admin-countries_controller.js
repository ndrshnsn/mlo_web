import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"
import "@/base/sweetalert2"

export default class extends Controller {
  connect() {
    $('#dt-admin-playerdb-countries').dataTable({
      iDisplayLength: 25,
      ajax: {
          url: '/admin/playerdb/countries/get_proc_dt',
      },
      order: [
          [1, "asc"]
      ],
      columns: [
      { name: 'flag', data: 'flag'},
      { name: 'name', data: 'name' },
      { name: 'alias', data: 'alias' },
      { name: 'DT_Actions', data: 'DT_Actions'}
      ],
      columnDefs: [
          {
              targets: [0, -1],
              className: 'text-center'
          },
          {
              orderable: false,
              targets: [0,-1]
          },
          {
              searchable: false,
              targets: [0,-1]
          }
      ]
    });

    $('#searchCountries').keyup(function(){
        $('#dt-admin-playerdb-countries').DataTable().search($(this).val()).draw();
    })
  }
}
