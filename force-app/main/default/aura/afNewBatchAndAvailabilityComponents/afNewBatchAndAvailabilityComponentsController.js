({
	doInit : function(component, event, helper) {
        //Get all locations
        var allLocs = [];
        var locAction = component.get("c.masterLocations");      
        locAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                allLocs = response.getReturnValue();
                allLocs.unshift(null);
                component.set("v.allLocations", allLocs);   
                
            } else if (state === "ERROR") {
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
        $A.enqueueAction(locAction);
        
        //Get all Rooms
        var roomAction = component.get("c.masterRooms");       
        roomAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.allRooms", response.getReturnValue());                
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message)
                    }
                }
            } else {
                console.log('Unknown error.')
            }
        })
        $A.enqueueAction(roomAction);
        
        //Get all Skills
        var getSkills = component.get("c.masterSkills");
        getSkills.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.allSkills', response.getReturnValue());
            } else {
                console.log('Error1');
            }
        });
        $A.enqueueAction(getSkills);
        
        //Get all Trainers
        var action = component.get("c.masterTrainers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.allTrainers', response.getReturnValue());
            } else {
                console.log('Error3');
            }
        });
        $A.enqueueAction(action);
        
        //Get all Trainings
        var getTrainings = component.get("c.masterTrainings");
        getTrainings.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.allTrainings', response.getReturnValue());                
            } else {
                console.log('Error2');
            }
        });
        $A.enqueueAction(getTrainings);
		        
	}
})