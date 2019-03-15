<<<<<<< HEAD
({
   //Initilizes inital chart values and calls helper function getData to do server call back
   TrainersBatches : function(component, event, helper) {
       component.set('v.empBatchesRecordset', [

           { label: 'Start Date', fieldName: 'startDate', type: 'date'  },
           { label: 'End Date', fieldName: 'endDate', type: 'date'  },
           { label: 'Status', fieldName: 'status', type: 'text', typeAttribute: {type: 'helpers.randomize', values: ['Planned', 'Confirmed', 'In Progress', 'Completed', 'Cancelled']}},
           { label: 'Track', fieldName: 'track', type: 'text', },

       ]);
           helper.getData(component, event);
           },
=======
({
   //Initilizes inital chart values and calls helper function getData to do server call back
   TrainersBatches : function(component, event, helper) {
       component.set('v.empBatchesRecordset', [

           { label: 'Start Date', fieldName: 'startDate', type: 'date'  },
           { label: 'End Date', fieldName: 'endDate', type: 'date'  },
           { label: 'Status', fieldName: 'status', type: 'text', typeAttribute: {type: 'helpers.randomize', values: ['Planned', 'Confirmed', 'In Progress', 'Completed', 'Cancelled']}},
           { label: 'Track', fieldName: 'track', type: 'text', },

       ]);
           helper.getData(component, event);
           },
>>>>>>> 3fb98fe170202194ecee298609c3303f56548c4b
})