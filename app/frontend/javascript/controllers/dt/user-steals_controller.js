import { Controller } from "@hotwired/stimulus"
import "@js/base/datatables"
import "@js/base/sweetalert2"

export default class extends Controller {
  connect() {
    $('#dt-user-steals').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/steals/get_proc_dt',
      },
      order: [
        [2, "desc"]
      ],
      columns: [
        { data: 'playerName' },
        { data: 'position' },
        { data: 'overallRating' },
        { data: 'playerTeam' },
        { data: 'playerValue' },
        { data: 'DT_Actions' }
      ],
      createdRow: function (row, data, dataIndex) {
        $(row).attr('id', 'defPlayer_' + row.id);
      },
      initComplete: function (settings) {
        sessionStorage.setItem('initialSort', JSON.stringify([[2, "desc"]]));
      },
      columnDefs: [
        {
          targets: [1, 2, 3, 4, -1],
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
          targets: 3,
          createdCell: function (td, cellData, rowData, row, col) {
            $(td).attr('id', 'playerTeam_' + rowData.id);
          }
        },
        {
          targets: 4,
          createdCell: function (td, cellData, rowData, row, col) {
            $(td).attr('id', 'playerValue_' + rowData.id);
          }
        },
        {
          targets: 5,
          createdCell: function (td, cellData, rowData, row, col) {
            $(td).attr('id', 'pActions_' + rowData.id);
          }
        }
      ],
    });

    // Search
    function filterColumn(i, val) {
      $('#dt-user-steals').DataTable().column(i).search(val, false, true).draw();
    }

    $('#player_name').on('keyup', function () {
      filterColumn($(this).attr('data-column'), $(this).val());
    });

    $('#club_filter').on('change', function () {
      filterColumn($(this).attr('data-column'), $(this).val());
    });
  }
}
