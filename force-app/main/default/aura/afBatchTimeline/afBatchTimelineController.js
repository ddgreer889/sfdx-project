({
    doInit : function(component, event, helper)
    {
        helper.getNames(component, event);

    },

    testingAccounts: function(component) {
        var getAccounts = component.get('c.AccountList');
        var testArray = [];
        var i;
        getAccounts.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                for(i = 0; i < getAccounts.length; i++){
                    testArray.push(getAccounts[i]);
                }
                // component.set('v.testingTime', testArray);
                component.set('v.testingTime', response.getReturnValue());
                //alert(testArray);
            } else{
                alert('Server side response not successful');
            }
        });
        $A.enqueueAction(getAccounts);
    },
    
    
    updateChart : function(component, event, helper)
    {
        
        if (event.getSource().getName() === 'cFilterChartComponent') {
            component.set('v.data', event.getParam('data'));
        }
        var names = component.get('v.trainers');
        helper.createChart(component, event, names);
        
    },
    
    createJSON : function(component, event, helper)
    {
        var action = component.get("c.wrapTrainingToJSON");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var dataObj = response.getReturnValue();
                component.set("v.data",dataObj);
                var names = null;
                if(event.getSource().getName() === 'cAfNewBatchForm'){
                $A.get('e.force:refreshView').fire();
                }
                
                
            }
            else if(state === 'ERROR')
            {
                alert('Callback has failed!');
            }
        });
        $A.enqueueAction(action);
    },
    /*
    refreshChart : function(component, event, helper){
      	component.set("v.resetBoolean",false);
        component.set("v.resetBoolean",true);
        
        component.reInit();
    },*/
    
})