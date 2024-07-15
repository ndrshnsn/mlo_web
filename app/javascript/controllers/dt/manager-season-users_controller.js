import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"

export default class extends Controller {
  connect() {
    $('#dt-manager-season-users').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/manager/seasons/users/get_susers_dt',
        data: function(d) {
            d.season = $('#season').val()
        },
      },
      initComplete: function (settings) {
        sessionStorage.setItem('initialSort', JSON.stringify([[0,"asc"]]));
      },
      order: [
          [0, "asc"]
      ],
      columns: [
        { name: 'avatar', data: 'avatar'},
        { name: 'club', data: 'club'},
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
