import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"
import "@/base/sweetalert2"

export default class extends Controller {
  connect() {
    $('#dt-admin-playerdb-players').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/admin/playerdb/players/get_proc_dt'
      },
      initComplete: function (settings) {
        sessionStorage.setItem('initialSort', JSON.stringify([[5,"desc"]]));
      },
      order: [
        [5, "desc"]
      ],
      columns: [
      { data: 'playerName' },
      { data: 'age' },
      { data: 'height' },
      { data: 'nationality' },
      { data: 'position' },
      { data: 'overallRating' },
      { data: 'platform'},
      { data: 'active'},
      { data: 'DT_Actions'}
      ],
      createdRow: function( row, data, dataIndex ) {
        $(row).attr('id', 'defPlayer_' + row.id);
      },
      columnDefs: [
          {
            targets: [1,2,3,4,5,6,7,-1],
            className: 'text-center'
          },
          {
            orderable: false,
            targets: [-1]
          },
          {
            searchable: false,
            targets: [-1]
          },
          {
            targets: 7,
            createdCell: function(td, cellData, rowData, row, col) {
                $(td).attr('id', 'pStatus_' + rowData.id);
            }
          },
          {
            targets: 8,
            createdCell: function(td, cellData, rowData, row, col) {
                $(td).attr('id', 'pActions_' + rowData.id);
          }
        }
      ],
    });

    // Search
    function filterColumn(i, val) {
      $('#dt-admin-playerdb-players').DataTable().column(i).search(val, false, true).draw();
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
