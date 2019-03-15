<<<<<<< HEAD
({
    sortPTOs : function(List) {
        return List.sort(function compare(a, b) {
            var dateA = new Date(a.StartDate__c);
            var dateB = new Date(b.StartDate__c);
            return dateA - dateB;
        });
    }
=======
({
    sortPTOs : function(List) {
        return List.sort(function compare(a, b) {
            var dateA = new Date(a.StartDate__c);
            var dateB = new Date(b.StartDate__c);
            return dateA - dateB;
        });
    }
>>>>>>> 3fb98fe170202194ecee298609c3303f56548c4b
})