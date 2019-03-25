({
    doInit: function(component, event, helper){
        var filterController = component.get("c.sortTrainersBySelectedCategories");
        filterController.setParams({
            startOfBatch : null,
            endOfBatch : null,
            chosenTrack : null,
            selectedLocation : null
        });
        filterController.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //ACTION to take when return is successful
                component.set('v.trainers', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message)
                    }
                }
            } else {
                console.log('Function callback error. Function call failed. {0010}');
            }
        });
        $A.enqueueAction(filterController);
    },

    userInputRecieved: function(component, event){
        
        var track = event.getParam("chosenTrack");
        var startBatch = event.getParam("startOfBatch");
        var endBatch = event.getParam("endOfBatch");
        var location = event.getParam("selectedLocation");
        
        //FOR DEBUGGING EVENT PASSED PARAMETERS
        console.log("EVENT INFO: " + typeof track + " ; " + startBatch + " ; " + endBatch + " ; " + location);
        
        var filterController = component.get("c.sortTrainersBySelectedCategories");
        filterController.setParams({
            startOfBatch : startBatch,
            endOfBatch : endBatch,
            chosenTrack : track,
            selectedLocation : location
        });
        filterController.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //ACTION to take when return is successful
                console.log(response.getReturnValue());
                component.set('v.trainers', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message)
                    }
                }
            } else {
                console.log('Function callback error. Function call failed. {0011}');
            }
        });
        $A.enqueueAction(filterController);
    },
    
    roomClick: function(component){
        console.log("PPLEASSEE");
        //when the rooms tab is clicked this method sets tab1Shown to false to switch tabs
        var isTab1Shown = component.get('v.tab1Shown');
        if(isTab1Shown){
            component.set('v.tab1Shown', false);
        }
    },
    
    trainerClick: function (component) {
        //when the trainers' tab is clicked this method sets tab1Shown to true to switch tabs
        var isTab1Shown = component.get('v.tab1Shown');
        if(!isTab1Shown){
            component.set('v.tab1Shown', true);
        }
    },
})