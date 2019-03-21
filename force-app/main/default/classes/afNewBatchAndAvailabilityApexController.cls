public class afNewBatchAndAvailabilityApexController {
    @AuraEnabled
    public static List<Training_Location__c> allLocs () {
        return [SELECT Id, Name, OfficeName__c 
                FROM Training_Location__c];
    }
    @AuraEnabled
    public static List<Training_Room__c> allRooms (){
        return [SELECT Id, name, TrainingLocation__c, TrainingLocationName__c, AVAvailability__c, RoomCapacity__c
                FROM Training_Room__c
                ORDER BY name];

    }
    @AuraEnabled
    public static List<Skill__c> getAllSkills(){
        return [SELECT Training_Track__c, Trainer__c 
                FROM Skill__c];
    }
    @AuraEnabled
    public static List<User> Trainers(){
        return [SELECT Id, Name, Available__c
                FROM User 
                WHERE UserRole.Name = 'Trainer'];
    }
    @AuraEnabled
    public static List<Training__c> Trainings(){
        return [SELECT Id, Name, CreatedDate, CoTrainer__c, CoTrainer__r.name, 
                       Trainer__c, Trainer__r.Name, TrainingTarget__c,
                       TrainingLocation__c, TrainingLocation__r.OfficeName__c, 
                       TrainingTrack__c, TrainingTrack__r.ShortName__c, TrainingTrack__r.Color__c, 
                       TrainingClass__c, TrainingRoom__c, StartDate__c, EndDate__c
                FROM Training__c];
    }



}