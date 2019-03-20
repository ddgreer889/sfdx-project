//test afTrainingBatchesApexControllerTest
//sergey sambros
// 27/27 lines covered 
//  TODO: Add comments and assertions. 

@isTest
public class afTrainingBatchesApexControllerTest {
	
    @testSetup public static void testDataSetup(){
        //Setup test data: Locations, Training Tracks, Trainings, User
        //UtilityMethods is last method in this class
        UtilityMethods UtilityMethods = new UtilityMethods();
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
        //test that the soql queriesin the controller are as expected
        system.assertEquals(AllTrainings, afTrainingBatchesApexController.AllTrainings);
        system.assertEquals(AllTrainings, afTrainingBatchesApexController.currentTrainings);
        //test getter
        system.assertEquals(AllTrainings, afTrainingBatchesApexController.getTrainingBatches());
        
        //select 2 batches to test
        List<Training__c> testTrainings = [SELECT Id FROM Training__c LIMIT 2];
        String[] batchIds = new string[]{};
        for(integer i = 0; i < testTrainings.size(); i++){
            batchIds.add(testTrainings[i].id);
        }
        //delete 2 batches
        afTrainingBatchesApexController.deleteBatchesServer(batchIds);
         
        //confirm that 2 batches were deleted 
        system.assertEquals([SELECT Id, Name, TrainingLocation__r.OfficeName__c, TrainingTrack__r.ShortName__c,
                                           Status__c, TrainingClass__c, StartDate__c, EndDate__c, Trainer__r.Name, CoTrainer__r.Name
                                           FROM Training__c
                                           ORDER BY StartDate__c].size(), afTrainingBatchesApexController.AllTrainings.size()-2);
        //set a training start date to enter condition loop for null start date
       	//reset property
        afTrainingBatchesApexController.AllTrainings = null;
        List<Training__c> newTrainingsList = [SELECT Id, Name, TrainingLocation__r.OfficeName__c, TrainingTrack__r.ShortName__c,
                                           Status__c, TrainingClass__c, StartDate__c, EndDate__c, Trainer__r.Name, CoTrainer__r.Name
                                           FROM Training__c];
        newTrainingsList[0].StartDate__c = null;
        //record EndDate to later assert
        Date nullTest = newTrainingsList[0].EndDate__c;
        system.assertEquals(newTrainingsList.size(), afTrainingBatchesApexController.AllTrainings.size()); 
        afTrainingBatchesApexController.updateBatchesServer(newTrainingsList);
        system.assertEquals(newTrainingsList.size(), afTrainingBatchesApexController.AllTrainings.size());
        //negative case, start date = null, assert that the end date is a day before when it began
        system.assertEquals(nullTest.addDays(-1),newTrainingsList[0].EndDate__c);
    }
    public class UtilityMethods {
    // Create dummy Training__c's and return them in a List.
        public List<Training__c> createTrainingsData(
            Integer amount,
            List<Training_Location__c> tLocList,
            List<User> tTrainerList,
            List<Date> tsDateList,
            List<Training_Track__c> tTrackList){
        
            List<Training__c> result = new List<Training__c>();
            for(integer i = 0; i < amount; i++){
                Training__c training = new Training__c(
                    TrainingLocation__c = tLocList[Math.mod(i,tLocList.size())].id,
                    Trainer__c = tTrainerList[Math.mod(i,tTrainerList.size())].id,
                    StartDate__c = tsDateList[Math.mod(i,tsDateList.size())],
                    EndDate__c = tsDateList[Math.mod(i,tsDateList.size())] + 10,
                    TrainingTrack__c = tTrackList[Math.mod(i,tTrackList.size())].id
                );            
                result.add(training);
            }
            return result;
        }
        
        // Create dummy Users and return them in a List.
        public List<User> createUserData(Integer amount){
        
            List<User> result = new List<User>();
            for(Integer i = 0; i < amount; i++){
                User uData = new User(
                    // @TODO replace query with generated 
                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'Trainer' LIMIT 1].id,
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
                    UserRoleId = [SELECT id,name FROM UserRole WHERE name = 'Trainer' LIMIT 1].id); 
                
                result.add(uData);
            }
            
        
            return result;
            // return null;
        }
        
        // Create dummy Training_Location__c's and return them in a List.
        public List<Training_Location__c> createLocationData(Integer amount){
        
            List<Training_Location__c> result = new List<Training_Location__c>();
            for(Integer i = 0; i < amount; i++){
                Training_Location__c tLoc = new Training_Location__c(
                    OfficeName__c = 'OfficeName' + String.valueOf(i),
                    Access__c = 'Open Access');
                result.add(tLoc);
                }
            
            return result;
        }
        
       
        // Create dummy Date objects and return them in a List.
        public List<Date> createStartDateData(Integer amount){
        
            Date today = Date.today();
            List<Date> result = new List<Date>();
            for(Integer i = 0; i < amount; i++){
                Date sDate = (Date.today().addMonths(2*i).toStartofWeek().addDays(2));
                result.add(sDate);
                }
          
            return result;
        }
        
        // Create dummy Training_Track__c's and return them in a List.
        public List<Training_Track__c> createTrainingTrackData(Integer amount){
            
            List<Training_Track__c> result = new List<Training_Track__c>();
            for(Integer i = 0 ; i < amount; i++){
                Training_Track__c track = new Training_Track__c(
                    ShortName__c = 'Track'+String.valueOf(i));
                result.add(track);
                }
            
            return result;
            }
    
        
        
	  }
   

}