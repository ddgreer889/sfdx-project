//test afTrainingBatchesApexControllerTest
//sergey sambros
// 27/27 lines covered 
//  TODO: Add comments and assertions. 

@isTest
public class afTrainingBatchesApexControllerTest {
	
    @testSetup public static void testDataSetup(){
        //Setup test data: Locations, Training Tracks, Trainings, User
        List<Training_Location__c> testL = UtilityMethods.createLocationData(6);
        
        List<User> testU = UtilityMethods.createUserData(3);       
        List<Training_Track__c> testT = UtilityMethods.createTrainingTrackData(3);
        List<Training__c> testTr = UtilityMethods.createTrainingsData(9, testL, testU,                                          
                                           UtilityMethods.createStartDateData(9), testT);
        //below prevents mixed dml error by preventing 
        insert testU;
        System.runAs(testU[0]){
            insert testT;
            insert testL;
            insert testTr;            
        	}
        
		}
       
    @isTest
    public static void doTest(){   
        
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
        //set a training start date to enter condition loop
        newTrainingsList[0].StartDate__c = null;
        //record End date to later assert
        Date nullTest = newTrainingsList[0].EndDate__c;
        system.assertEquals(newTrainingsList.size(), afTrainingBatchesApexController.AllTrainings.size()); 
        afTrainingBatchesApexController.updateBatchesServer(newTrainingsList);
        //assert that the end date is a day before when it began
        system.assertEquals(nullTest.addDays(-1),newTrainingsList[0].EndDate__c);
        afTrainingBatchesApexController.getTrainingBatchesById(System.UserInfo.getProfileId());
        system.debug('ASSERT'+ newTrainingsList[0].StartDate__c);
    }


}