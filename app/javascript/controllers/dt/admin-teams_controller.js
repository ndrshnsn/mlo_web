import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"
import "@/base/sweetalert2"

export default class extends Controller {
  connect() {
    $('#dt-admin-playerdb-teams').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/admin/playerdb/teams/get_proc_dt'
      },
      initComplete: function (settings) {
        sessionStorage.setItem('initialSort', JSON.stringify([[0,"asc"]]));
      },
      order: [
          [0, "asc"]
      ],
      columns: [
      { data: 'name' },
      { data: 'platform' },
      { data: 'country'},
      { data: 'status'},
      { data: 'DT_Actions'}
      ],
      columnDefs: [
          {
              targets: [2,3,-1],
              className: 'text-center'
          },
          {
              orderable: false,
              targets: [2,-1]
          },
          {
              searchable: false,
              targets: [1,2,3,-1]
          },
      ],
    });

    $('#searchTeams').keyup(function(){
      $('#dt-admin-playerdb-teams').DataTable().search($(this).val()).draw();
    })
  }
}
