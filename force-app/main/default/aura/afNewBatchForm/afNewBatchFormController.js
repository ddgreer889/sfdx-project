({
    /*----------------------------------------------------------
    				Init and Extra Section
    ----------------------------------------------------------*/
    doInit : function(component, event, helper) {
                
    },
    
    clearBatchFields : function(component, event, helper) {
        helper.clear(component, event);
    },
    
    /*----------------------------------------------------------
    				Create New Batch Section
    ----------------------------------------------------------*/
    onSubmit : function(component, event, helper) {
        // in-built functionality to handle recordEditForm submission
        // console.log('onSubmit new');
        // var form = component.find("newBatchForm");
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        
        component.find('newBatchForm').submit(fields);
    },
    
    onSuccess : function(component, event, helper) {
        console.log('onSuccess');
        
        var newBatch = [{
            CoTrainer__c         : component.get("v.cotrainer"),
            EndDate__c             : component.get("v.endDate"),
            Trainer__c             : component.get("v.trainer"),
            TrainingLocation__c : component.get("v.location"),
            TrainingRoom__c     : component.get("v.hiddenRoom"),
            TrainingTrack__c     : component.get("v.track"),
            StartDate__c         : component.get("v.startDate"),
            Status__c             : component.get("v.status")
        }];
        
        // records have been submitted, clear form
        helper.clear(component, event);  
        
        // display toast informing user of successful submission
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            title : 'Success!',
            message: 'The new batch has been created.',
            duration: '2000',
            type: 'success',
        });
        toastEvent.fire();
        
        // send new batch to other components
        var newBatchEvent = $A.get("e.c:afNewBatchCreatedEvent");
        
        newBatchEvent.setParams({
            "newBatch" : newBatch
        });
        
        console.log('newBatch JSON ' + JSON.stringify(newBatchEvent.getParam("newBatch")));
        newBatchEvent.fire();
    },
    
    
    /*----------------------------------------------------------
    				Training Track Section 
    ----------------------------------------------------------*/
    trackChanged : function(component, event, helper) {
        var track = component.get("v.track");
        // console.log('track: ' + track);
        // pass selected training track to application event
        var trackEvent = $A.get("e.c:afNewBatchFormTrackEvent");
        trackEvent.setParams({
            "track" : track
        });
        // console.log('trackChanged');
        trackEvent.fire();  
    },
    
    /*----------------------------------------------------------
    						Time Section
    ----------------------------------------------------------*/
    dateChanged : function(component, event, helper) {
        
        helper.changeEndDate(component, event, helper);
        
        // get and set trainer/cotrainer to invoke showTrainerToast indirectly 
        var trainer   = component.get("v.trainer");
        var cotrainer = component.get("v.cotrainer");
        component.set("v.trainer", trainer);
        component.set("v.cotrainer", cotrainer);
    },
    
    /*----------------------------------------------------------
    					Trainer Section 
    ----------------------------------------------------------*/
    setTrainerField : function(component, event, helper) {
        
        component.set("v.trainerUncleared", false);
        component.set("v.trainerUncleared", true);
        
        var trainer = event.getParam("trainerId");
        component.set("v.trainer", trainer);
        
        var trainings = component.get("v.openTrainings");
        var startDate = component.get("v.startDate");
        var endDate	  = component.get("v.endDate");
        
        helper.showTrainerToast(helper, event, trainings, trainer, startDate, endDate);
        
    },
    
    trainerChanged : function(component, event, helper) {
        var trainings   = component.get("v.openTrainings");
        var trainer     = event.getParam("value");
        var startDate   = component.get("v.startDate");
        var endDate     = component.get("v.endDate");
        
        // pass appropriate values to helper function for display of toast
        helper.showTrainerToast(helper, event, trainings, trainer, startDate, endDate);
    },
    
    /*----------------------------------------------------------
    					Location Section
    ----------------------------------------------------------*/
    setRoomField : function(component, event, helper){
        var room = event.getParam("room");
        var allRooms = component.get("v.roomList");
        var roomsForLoc = [];
        
        component.set("v.locUncleared", false);
        component.set("v.locUncleared", true);
        
        for (var i = 0; i < allRooms.length; i++) {
            if (allRooms[i].TrainingLocation__c == room.TrainingLocation__c) {
                roomsForLoc.push(allRooms[i]);
            }
        }
        
        console.log(room.TrainingLocation__c);
        component.set("v.location", room.TrainingLocation__c);
        component.set("v.hiddenRoom", room.Id);
        component.set("v.roomsForLocation", roomsForLoc);
        component.set("v.room", room.Id);
        
    },
    
    selectRoom : function(component, event, helper) {
        var room    = component.get("v.room");
        var rooms   = component.get("v.roomsForLocation");
        
        for (var i = 0; i < rooms.length; i++) {
            if(rooms[i].Id == room) {
                room = rooms[i];
            }
        }
        // set to hidden inputField for form submission
        component.set("v.hiddenRoom", room.Id);
    },
    
    locationChanged : function(component, event, helper) {
        component.set("v.locUncleared", false);
        component.set("v.locUncleared", true);
        
        var loc 	= component.get("v.location");
        var roomsList = component.get("v.allRooms");
		
		var filteredRooms = component.get("c.filterRoomByLocation");        
        filteredRooms.setParams({
			location : loc,
            rooms : roomsList,			            
        });
        filteredRooms.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //ACTION to take when return is successful
                component.set('v.roomsForLocation', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message)
                    }
                }
            } else {
                console.log('Function callback error. Function call failed. {0002}');
            }
        });
        $A.enqueueAction(filteredRooms);
        
        
        // pass new location and all rooms to application event <--NEEDS TO BE COMPONENT EVENT NOT APPLICATION EVENT
        var locEvent = $A.get("e.c:afNewBatchFormLocationEvent");
        locEvent.setParams({
            "location" : loc,
        });
        locEvent.fire();
    },
    
    
})