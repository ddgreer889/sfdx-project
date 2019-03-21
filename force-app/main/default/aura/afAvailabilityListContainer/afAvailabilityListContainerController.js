({
    initRooms : function(component, event, helper) {                
        var getRooms = component.get("c.getRooms");
        getRooms.setParams({ allRooms : component.get("v.allRooms") });
        //sets a call back from the server to get an array of all the training room records
        getRooms.setCallback(this, function(response) {
            var state = response.getState();       
            if(component.isValid && state === 'SUCCESS'){  
                component.set("v.rooms", response.getReturnValue());
                component.set("v.currentLocRooms", response.getReturnValue());
            }else if(state === 'ERROR'){
                var errors = response.getError();               
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('Error message: ' + errors[0].message);
                        alert('Error message: ' + errors[0].message);
                    }
                }
            }else{
                console.log('Unknown error');
            }
        });
        $A.enqueueAction(getRooms); 
    },
    
    initTrainers : function(component, event, helper){
        var action = component.get("c.getAllTrainers");
        action.setParams({ Trainers : component.get("v.allTrainers") });
        //sets a call back from the server to get an array of users with the trainer role
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set('v.trainers', response.getReturnValue());
            } else{
                console.log('Error3');
            }
        });
        $A.enqueueAction(action);    
    },
    
    dateHasChanged: function(component, event, helper){
        //This method checks the start date and end date of every training within the dates selected from the afBatchFormDateEvent and changes the availability of the trainer accordingly
        var trainers = component.get('v.trainers');
        var trainings = component.get('v.allTrainings');
        var startDate = new Date(event.getParam('startDate'));
        var endDate = new Date(event.getParam('endDate'));
        var currentLocRooms = component.get('v.currentLocRooms');
        
        
        for(var i=0; i<trainers.length; i++){
            for (var j = 0; j < trainings.length; j++) {
                if(trainers[i].Id == trainings[j].Trainer__c || 
                   trainers[i].Id == trainings[j].CoTrainer__c) {
                    var prevStart = new Date(trainings[j].StartDate__c);
                    //prevStart date is a variable to store the Date value of the training start date
                    var prevEnd = new Date(trainings[j].EndDate__c);
                    //prevEnd date is a variable to store the Date value of the training end date
                    
                    if((prevStart <= startDate    && startDate <= prevEnd) || 
                       (prevStart <= endDate  && endDate <= prevEnd) || 
                       (prevStart >= startDate    && endDate >= prevEnd)){
                        trainers[i].Available__c = "Training";
                        break;
                    }else{
                        trainers[i].Available__c = "Available";
                    }
                }
            }
        }
        for(var i=0; i<currentLocRooms.length; i++){
            for (var j = 0; j < trainings.length; j++) {
                if(currentLocRooms[i].Id == trainings[j].TrainingRoom__c) {
                    var prevStart = new Date(trainings[j].StartDate__c);
                    var prevEnd = new Date(trainings[j].EndDate__c);
                    
                    if((prevStart <= startDate && startDate <= prevEnd) || 
                       (prevStart <= endDate  && endDate <= prevEnd) || 
                       (prevStart >= startDate    && endDate >= prevEnd)){
                        currentLocRooms[i].AVAvailability__c = "No";
                        break;
                    }else {
                        currentLocRooms[i].AVAvailability__c = "Yes";
                    }
                }
            }
        }
        
        component.set('v.currentLocRooms', null);
        component.set('v.currentLocRooms', helper.sortTrainingRoom(currentLocRooms));
        component.set('v.trainers', null);
        component.set('v.trainers', helper.sortTrainers(trainers));
        
    },
    
    handleLoc : function(component, event, helper) {
        var getNewRooms = component.get("c.RoomsMatchLocation");
        getNewRooms.setParams({location : event.getParam("location"),trl : component.get("v.rooms")});
        getNewRooms.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid && state === 'SUCCESS'){                
                component.set("v.currentLocRooms", response.getReturnValue());
            }else if(state === 'ERROR'){
                var errors = response.getError();
                
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('Error message: ' + errors[0].message);
                    }
                }
            }else{
                console.log('Unknown error');
            }
        });
        $A.enqueueAction(getNewRooms);
    },
    
    roomClick: function(component, helper){
        //when the rooms tab is clicked this method sets tab1Shown to false to switch tabs
        var isTab1Shown = component.get('v.tab1Shown');
        if(isTab1Shown){
            component.set('v.tab1Shown', false);
        }
    },
    
    skillHasChanged: function(component, event, helper){
        var trainingTrack = event.getParam('track').toString()
        if(trainingTrack==""||null){
            trainingTrack = null;
        }
        
        var trainerHasSkill = component.get("c.TrainerHasSkill");
        trainerHasSkill.setParams({ 
            						"track" : trainingTrack,
                                    "trainers" : component.get('v.trainers'),
                                    "skills" : component.get('v.allSkills')
                                  });
        //sets a call back from the server to get an array of all the trainers that have or don't have the skill
        trainerHasSkill.setCallback(this, function(response) {
            var state = response.getState();
            
            if(component.isValid && state === 'SUCCESS'){  
                //right now, it is using the helper sort trainers
                //whomever is doing the apex logic to sort trainers by hasSkill,
                //call that method within the apex and remove the helper.sortTrainers below
                component.set('v.trainers', helper.sortTrainers(response.getReturnValue() ));
            }else if(state === 'ERROR'){
                var errors = response.getError();               
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('Error message: ' + errors[0].message);
                        alert('Error message: ' + errors[0].message);
                    }
                }
            }else{
                console.log('Unknown error');
            }
        });
        $A.enqueueAction(trainerHasSkill);         
        
    },
    
    trainerClick: function (component, helper) {
        //when the trainers' tab is clicked this method sets tab1Shown to true to switch tabs
        var isTab1Shown = component.get('v.tab1Shown');
        if(!isTab1Shown){
            component.set('v.tab1Shown', true);
        }
    },
})