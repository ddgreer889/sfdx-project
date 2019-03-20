@isTest
public class UtilityMethods {
    
    // Create dummy Training__c's and return them in a List.
    public static List<Training__c> createTrainingsData( Integer amount,
                                                         List<Training_Location__c> tLocList,
                                                         List<User> tTrainerList,
                                                         List<Date> tsDateList,
                                                         List<Training_Track__c> tTrackList) {
    
        List<Training__c> result = new List<Training__c>();

        for(integer i = 0; i < amount; i++) {
            Training__c training = new Training__c(TrainingLocation__c = tLocList[Math.mod(i,tLocList.size())].id,
                                                   Trainer__c = tTrainerList[Math.mod(i,tTrainerList.size())].id,
                                                   StartDate__c = tsDateList[Math.mod(i,tsDateList.size())],
                                                   EndDate__c = tsDateList[Math.mod(i,tsDateList.size())] + 10,
                                                   TrainingTrack__c = tTrackList[Math.mod(i,tTrackList.size())].id);            
            result.add(training);
        }
        return result;
    }
    
    
    // Create dummy Users and return them in a List.
    public static List<User> createUserData(Integer amount) {
    
        List<User> result = new List<User>();
        ID profID = [SELECT Id FROM Profile WHERE Name = 'Trainer' LIMIT 1].id;
        ID roleID = [SELECT id,name FROM UserRole WHERE name = 'Trainer' LIMIT 1].id;

        for(Integer i = 0; i < amount; i++){
            User uData = new User(
                ProfileId = profID,
                LastName = 'last ' + String.valueOf(i),
                Email = 'puser' + String.valueOf(i) + '@amamama.com',
                Username = 'puser' + String.valueOf(i) + System.currentTimeMillis() + '@amamama.com',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Available__c = 'Available',
                UserRoleId = roleID); 
            
            result.add(uData);
        }
        
    
        return result;
    }
    
    // Create dummy Training_Location__c's and return them in a List.
    public static List<Training_Location__c> createLocationData(Integer amount){
    
        List<Training_Location__c> result = new List<Training_Location__c>();
        
        for(Integer i = 0; i < amount; i++) {
            Training_Location__c tLoc = new Training_Location__c(OfficeName__c = 'OfficeName' + String.valueOf(i),
                                                                 Access__c = 'Open Access');
            result.add(tLoc);
        }
        
        return result;
    }
    
    // @TODO populate dates with something
    // Create dummy Date objects and return them in a List.
    public static List<Date> createStartDateData(Integer amount){
    
        Date today = Date.today();
        List<Date> result = new List<Date>();

        for(Integer i = 0; i < amount; i++) {
            Date sDate = (Date.today().addMonths(2*i).toStartofWeek().addDays(2));
            result.add(sDate);
        }
      
        return result;
    }
    
    // Create dummy Training_Track__c's and return them in a List.
    public static List<Training_Track__c> createTrainingTrackData(Integer amount){
        
        List<Training_Track__c> result = new List<Training_Track__c>();

        for(Integer i = 0 ; i < amount; i++) {
            Training_Track__c track = new Training_Track__c(ShortName__c = 'Track'+String.valueOf(i));
            result.add(track);
        }
        
        return result;
    }

    public static List<Skill__c> createSkillData(Integer amount, 
                                                 List<User> trainers, 
                                                 List<Training_Track__c> tracks){

        List<Skill__c> result = new List<Skill__c>();

        for (integer i = 0; i < amount; i++) {
            Skill__c s = new Skill__c(Trainer__c = trainers.get(Math.mod(i,trainers.size())).id,
                                      Training_Track__c = tracks.get(Math.mod(i,tracks.size())).id);
            result.add(s);
        }

        return result;

    }
    
}