<<<<<<< HEAD
({
    doInit : function(component, event, helper) {
        var availability = component.get('v.availability');
        var trainerId = component.get('v.trainerId');
        if(availability==="Available"){
            component.set('v.isAvailable', true);
        } else{
            component.set('v.isAvailable', false);
        }
        
    },
    selectIsClicked : function(component, event, helper){
        var selectedEvt = $A.get('e.c:TrainerSelected');
        var trainerId = component.get('v.trainerId');
        console.log(trainerId);
        selectedEvt.setParams({'trainerId':trainerId});
        selectedEvt.fire();
    },
=======
({
    doInit : function(component, event, helper) {
        var availability = component.get('v.availability');
        var trainerId = component.get('v.trainerId');
        if(availability==="Available"){
            component.set('v.isAvailable', true);
        } else{
            component.set('v.isAvailable', false);
        }
        
    },
    selectIsClicked : function(component, event, helper){
        var selectedEvt = $A.get('e.c:TrainerSelected');
        var trainerId = component.get('v.trainerId');
        console.log(trainerId);
        selectedEvt.setParams({'trainerId':trainerId});
        selectedEvt.fire();
    },
>>>>>>> 3fb98fe170202194ecee298609c3303f56548c4b
})