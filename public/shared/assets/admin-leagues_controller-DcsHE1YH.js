import{C as s}from"./application-BzDBbQCT.js";import"./datatables-DSt6wVS0.js";class r extends s{connect(){$("#dt-admin-leagues").dataTable({iDisplayLength:25,ajax:{url:"/admin/leagues/get_proc_dt"},initComplete:function(a){sessionStorage.setItem("initialSort",JSON.stringify([[0,"asc"]]))},order:[[0,"asc"]],columns:[{name:"name",data:"name"},{name:"platform",data:"platform"},{name:"slots",data:"slots"},{name:"users",data:"users"},{name:"status",data:"status"},{name:"DT_Actions",data:"DT_Actions"}],columnDefs:[{targets:[1,2,3,4,-1],className:"text-center"},{orderable:!1,targets:[-1]},{searchable:!1,targets:[1,3,-1]}]});function t(a,e){$("#dt-admin-accounts").DataTable().column(a).search(e,!1,!0).draw()}$("input.dt-input").on("keyup",function(){t($(this).attr("data-column"),$(this).val())})}}export{r as default};
//# sourceMappingURL=admin-leagues_controller-DcsHE1YH.js.map
