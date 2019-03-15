<<<<<<< HEAD
({
   TrainersPTO : function (component, event, helper){
       component.set('v.empPTORecordset', [

           { label: 'Start Date', fieldName: 'startDate', type: 'date', sortable: 'true' },
           { label: 'End Date', fieldName: 'endDate', type: 'date', sortable: 'true' },
           { label: 'Status', fieldName: 'status', type: 'text', sortable: 'true'},
           { label: 'Reason', fieldName: 'reason', type: 'text', sortable: 'true'},

       ]);
       helper.getData(component, event);
   },
=======
({
   TrainersPTO : function (component, event, helper){
       component.set('v.empPTORecordset', [

           { label: 'Start Date', fieldName: 'startDate', type: 'date', sortable: 'true' },
           { label: 'End Date', fieldName: 'endDate', type: 'date', sortable: 'true' },
           { label: 'Status', fieldName: 'status', type: 'text', sortable: 'true'},
           { label: 'Reason', fieldName: 'reason', type: 'text', sortable: 'true'},

       ]);
       helper.getData(component, event);
   },
>>>>>>> 3fb98fe170202194ecee298609c3303f56548c4b
})