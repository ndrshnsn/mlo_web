import{C as n}from"./application-BzDBbQCT.js";import"./datatables-DSt6wVS0.js";import"./sweetalert2-DTWCJYMW.js";class c extends n{connect(){$("#dt-admin-accounts").dataTable({iDisplayLength:25,ajax:{url:"/admin/accounts/get_proc_dt"},initComplete:function(a){sessionStorage.setItem("initialSort",JSON.stringify([[0,"asc"]]))},order:[[0,"asc"]],columns:[{name:"avatar",data:"avatar"},{name:"email",data:"email"},{name:"role",data:"role"},{name:"status",data:"status"},{name:"DT_Actions",data:"DT_Actions"}],columnDefs:[{targets:[2,3,4],className:"text-center"},{orderable:!1,targets:[0,-1]},{searchable:!1,targets:[-1]}]});function t(a,e){$("#dt-admin-accounts").DataTable().column(a).search(e,!1,!0).draw()}$("input.dt-input").on("keyup",function(){t($(this).attr("data-column"),$(this).val())}),$(".dt-select").on("change",function(){t($(this).attr("data-column"),$(this).val())})}}export{c as default};
//# sourceMappingURL=admin-accounts_controller-D8GqZaAV.js.map
