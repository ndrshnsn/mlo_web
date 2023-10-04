import { Controller } from "@hotwired/stimulus"
import "@/base/datatables"
import "@/base/sweetalert2"

export default class extends Controller {
  connect() {
    $('#dt-user-trades-buy').dataTable({
      iDisplayLength: 25,
      ajax: {
        url: '/trades/buy/get_proc_dt',
        data: function(d) {
          d.minOverall = $('#player_overall_min').val(),
          d.maxOverall = $('#player_overall_max').val(),
          d.minPlayerValue = $('#player_value_min').val(),
          d.maxPlayerValue = $('#player_value_max').val(),
          d.minAge = $('#player_age_min').val(),
          d.maxAge = $('#player_age_max').val()
        },
      },
      order: [
        [2, "desc"]
      ],
      columns: [
      { data: 'playerName'},
      { data: 'position' },
      { data: 'overallRating'},
      { data: 'playerTeam'},
      { data: 
        {
          _: 'playerValue',
          sort: 'playerValueOnly'
        }
      },
      { data: 'nationality'},
      { data: 'DT_Actions'}
      ],
      createdRow: function( row, data, dataIndex ) {
        $(row).attr('id', 'defPlayer_' + row.id);
      },
      initComplete: function (settings) {
        sessionStorage.setItem('initialSort', JSON.stringify([[2,"desc"]]));
      },
      columnDefs: [
        {
          targets: [1,2,3,4,-1],
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
          targets: [5],
          visible: false
        },
        {
          targets: 3,
          createdCell: function(td, cellData, rowData, row, col) {
            $(td).attr('id', 'playerTeam_' + rowData.id);
          }
        },
        {
          targets: 4,
          createdCell: function(td, cellData, rowData, row, col) {
            $(td).attr('id', 'playerValue_' + rowData.id);
          }
        },
        {
          targets: 6,
          createdCell: function(td, cellData, rowData, row, col) {
            $(td).attr('id', 'pActions_' + rowData.id);
          }
        }
      ],
    });

    // Search
    function filterColumn(i, val) {
      $('#dt-user-trades-buy').DataTable().column(i).search(val, false, true).draw();
    }

    $('#player_name').on('keyup', function () {
        filterColumn($(this).attr('data-column'), $(this).val());
    });

    $('#player_nationality').on('change', function() { 
        filterColumn($(this).attr('data-column'), $(this).val());
    });

    $('#player_position').on('change', function() { 
        filterColumn($(this).attr('data-column'), $(this).val());
    });

    $('#player_overall_min').on('change', function () {
        filterColumn($(this).attr('data-name'), $(this).val());
    });

    $('#player_overall_max').on('change', function () {
        filterColumn($(this).attr('data-name'), $(this).val());
    });

    $('#club_filter').on('change', function() { 
        filterColumn($(this).attr('data-column'), $(this).val());
    });

    $('#player_value_min').on('change', function() { 
        filterColumn($(this).attr('data-name'), $(this).val());
    });

    $('#player_value_max').on('change', function() { 
        filterColumn($(this).attr('data-name'), $(this).val());
    });

    $('#player_age_min').on('change', function() { 
        filterColumn($(this).attr('data-name'), $(this).val());
    });

    $('#player_age_max').on('change', function() { 
        filterColumn($(this).attr('data-name'), $(this).val());
    });
  }
}
