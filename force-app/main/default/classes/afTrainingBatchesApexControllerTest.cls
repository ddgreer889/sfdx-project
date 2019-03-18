//test afTrainingBatchesApexControllerTest
//sergey sambros

@isTest
public class afTrainingBatchesApexControllerTest {
    
     @isTest
    public static void doTest(){
        //Create the Trainer user that will be used in the test.
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Trainer' LIMIT 1].id,
            LastName = 'last ' + Math.round(Math.random()),
            Email = 'puser' + Math.round(Math.random()) + '@amamama.com',
            Username = 'puser' + Math.round(Math.random()) + '@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Available__c = 'Available',
            UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Trainer' LIMIT 1].id);
        
        //Insert the user record
        insert u;
        
        
        List <Training__c> AllTrainings = [SELECT Id, Name, TrainingLocation__r.OfficeName__c, TrainingTrack__r.ShortName__c,
                                           Status__c, TrainingClass__c, StartDate__c, EndDate__c, Trainer__r.Name, CoTrainer__r.Name
                                           FROM Training__c
                                           ORDER BY StartDate__c];
        
        system.assertEquals(AllTrainings, afTrainingBatchesApexController.AllTrainings);
        system.assertEquals(AllTrainings, afTrainingBatchesApexController.currentTrainings);
        system.assertEquals(AllTrainings, afTrainingBatchesApexController.getTrainingBatches());
        List<Training__c> testTrainings = [SELECT Id FROM Training__c LIMIT 2];
        String[] batchIds = new string[]{};
        for(integer i = 0; i < testTrainings.size(); i++){
            batchIds.add(testTrainings[i].id);
        }
        
        afTrainingBatchesApexController.deleteBatchesServer(batchIds);
        afTrainingBatchesApexController.AllTrainings = null;
        List<Training__c> newTrainingsList = [SELECT Id, Name, TrainingLocation__r.OfficeName__c, TrainingTrack__r.ShortName__c,
                                           Status__c, TrainingClass__c, StartDate__c, EndDate__c, Trainer__r.Name, CoTrainer__r.Name
                                           FROM Training__c];
        system.assertEquals(newTrainingsList.size(), afTrainingBatchesApexController.AllTrainings.size()); 
        afTrainingBatchesApexController.updateBatchesServer(newTrainingsList);
        
        afTrainingBatchesApexController.getTrainingBatchesById(System.UserInfo.getProfileId());
    }


}