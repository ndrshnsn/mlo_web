import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"
import "@/base/sweetalert2"

export default class extends Controller {
  connect() {
    $('#dt-admin-accounts').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/admin/accounts/get_proc_dt'
      },
      order: [
          [0, "asc"]
      ],
      columns: [
        { name: 'avatar', data: 'avatar'},
        { name: 'email', data: 'email' },
        { name: 'role', data: 'role' },
        { name: 'status', data: 'status' },
        { name: 'DT_Actions', data: 'DT_Actions'}
      ],
      columnDefs: [
          {
              targets: [2,3,4],
              className: 'text-center'
          },
          {
              orderable: false,
              targets: [0,-1]
          },
          {
              searchable: false,
              targets: [-1]
          }
      ],
    });

    // Search
    function filterColumn(i, val) {
      $('#dt-admin-accounts').DataTable().column(i).search(val, false, true).draw();
    }

    // on key up from input field
    $('input.dt-input').on('keyup', function () {
        filterColumn($(this).attr('data-column'), $(this).val());
    });

    $('.dt-select').on('change', function() { 
        filterColumn($(this).attr('data-column'), $(this).val());
    });
  }
}
