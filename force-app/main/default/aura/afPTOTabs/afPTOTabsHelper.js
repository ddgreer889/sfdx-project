({
    sortPTOs : function(List) {
        return List.sort(function compare(a, b) {
            var dateA = new Date(a.StartDate__c);
            var dateB = new Date(b.StartDate__c);
            return dateA - dateB;
        });
    },

    //Gets the component's Lists of Pending/Approved PTOs and sets the hasPending/hasApproved attribute accordingly
    setPTOTabs : function(component) {
        var ptos = component.get('v.pendingPTOs');
        component.set('v.hasPending', ptos.length != 0);
        
        ptos = component.get('v.approvedPTOs');
        var newptos = component.get('v.newApprovedPTOs');
        var oldptos = component.get('v.oldApprovedPTOs');
        component.set('v.hasApproved', ptos.length != 0 || 
                        oldptos.length != 0 || newptos.length != 0);
    }
})