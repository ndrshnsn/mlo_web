import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"
import "@/base/sweetalert2"

export default class extends Controller {
  connect() {
    $('#dt-manager-active-users').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/manager/users/get_aproc_dt'
      },
      order: [
          [0, "asc"]
      ],
      columns: [
        { name: 'avatar', data: 'avatar'},
        { name: 'email', data: 'email' },
        { name: 'status', data: 'status' },
        { name: 'DT_Actions', data: 'DT_Actions'}
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
    $('#searchUsers').keyup(function(){
      $('#dt-manager-active-users').DataTable().search($(this).val()).draw();
    })
  }
}
