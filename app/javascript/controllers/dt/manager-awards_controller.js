import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"
import "@/base/sweetalert2"

export default class extends Controller {
  connect() {
    $('#dt-manager-awards').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/manager/awards/get_proc_dt'
      },
      initComplete: function (settings) {
        sessionStorage.setItem('initialSort', JSON.stringify([[0,"asc"]]));
      },
      order: [
          [0, "asc"]
      ],
      columns: [
        { data: 'name'},
        { data: 
          {
              _: 'prizeValue',
              sort: 'prize'
          }
        },
        { data: 'ranking'},
        { data: 'status' },
        { data: 'DT_Actions'}
      ],
      columnDefs: [
          {
              targets: [2,-1],
              className: 'text-center'
          },
          {
              orderable: false,
              targets: [-1]
          },
          {
              searchable: false,
              targets: [1,2,-1]
          }
      ],
    });

    // Search
    $('#searchAwards').keyup(function(){
      $('#dt-manager-awards').DataTable().search($(this).val()).draw();
    })
  }
}
