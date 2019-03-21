public class afNewBatchFormApexController {
    @AuraEnabled
    public static List<Training_Room__c> filterRoomByLocation(String location, List<Training_Room__c> rooms ){
        System.debug('YELLOW');
        System.debug(location);
        List<Training_Room__c> filteredRooms = new List<Training_Room__c>();
        filteredRooms.add(new Training_Room__c());
        for(Training_Room__c room : rooms){
            if(location == room.TrainingLocationName__c)
                filteredRooms.add(room);
        }
        system.debug(filteredRooms);
        return filteredRooms;
    }
}