({
   doInit : function(component, event, helper) {
       var trainers    = [];
       var cotrainers    = [];
<<<<<<< HEAD
       var trnrAction     = component.get("c.allTrainers");

=======
       //This variable is assigned the list of Users that are Trainers from the Apex Controller
       var trnrAction     = component.get("c.allTrainers");

       //setCallbacj runs when the remote method call returns.
       //For more information on callbacks, see this Unit https://trailhead.salesforce.com/en/content/learn/modules/lex_dev_lc_basics/lex_dev_lc_basics_server
>>>>>>> 3fb98fe170202194ecee298609c3303f56548c4b
       trnrAction.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               trainers = response.getReturnValue();
               component.set("v.trainers", trainers);
			
           } else if (state === "ERROR"){
               var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       console.log('Error message: ' + errors[0].message);
                   }
               }
           } else {
               console.log('Unknown error.')
           }
       })
       $A.enqueueAction(trnrAction);
   },


})