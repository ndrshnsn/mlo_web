import{C as a}from"./application-BzDBbQCT.js";import"./datatables-DSt6wVS0.js";import"./sweetalert2-DTWCJYMW.js";class i extends a{connect(){$("#dt-manager-active-users").dataTable({iDisplayLength:25,ajax:{url:"/manager/users/get_aproc_dt"},initComplete:function(t){sessionStorage.setItem("initialSort",JSON.stringify([[0,"asc"]]))},order:[[0,"asc"]],columns:[{name:"avatar",data:"avatar"},{name:"email",data:"email"},{name:"status",data:"status"},{name:"DT_Actions",data:"DT_Actions"}],columnDefs:[{targets:[2,-1],className:"text-center"},{orderable:!1,targets:[-1]},{searchable:!1,targets:[1,2,-1]}]}),$("#searchUsers").keyup(function(){$("#dt-manager-active-users").DataTable().search($(this).val()).draw()})}}export{i as default};
//# sourceMappingURL=manager-active-users_controller-D7bbgmkN.js.map
