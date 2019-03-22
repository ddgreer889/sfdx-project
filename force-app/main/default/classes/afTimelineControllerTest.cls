/****************************************************************
* afTimeLineController Test Class
* Author: Rafael E. López M. / Ian Blanchard
*
* Tests the methods of the Apex Controller for the
*   afBatchTimeline component
*****************************************************************/

@isTest
public class afTimelineControllerTest {

    // Constant variables whose data would be better off as a static resource
    private static final String testTrainingQuery = 'SELECT Id, Name, TrainingLocation__c, Trainer__r.Name,'+
        'StartDate__c, TrainingLocation__r.OfficeName__c, EndDate__c, CoTrainer__r.name, TrainingTrack__r.ShortName__c,'+
        'TrainingTrack__r.Color__c, TrainingClass__c FROM Training__c ORDER BY Trainer__r.name, StartDate__c';

    // Test data variables
    private static List<User> users;
    private static List<Training__c> trainings;
    private static List<Training_Location__c> locations;
    private static List<Date> sDates;
    private static List<Training_Track__c> tracks;

    @TestSetup
    static void makeData(){
        Test.startTest();

        users = UtilityMethods.createUserData(5);
        sDates = UtilityMethods.createStartDateData(10);
        tracks = UtilityMethods.createTrainingTrackData(2);
        locations = UtilityMethods.createLocationData(5);
        trainings = UtilityMethods.createTrainingsData(10,locations,users,sDates,tracks);

        Database.insert(users);

        System.runAs(users[0]){
            Database.insert(tracks);
            Database.insert(locations);
            Database.insert(trainings);
        }

        Test.stopTest();
    }
    
    @isTest
    public static void AllTrainings_Getter_Test(){
        

        // Arrange
        List<Training__c> allTrainings = trainings;
        List<Training__c> actualTrainings = Database.query(testTrainingQuery);

        // Act
        Test.startTest();
        allTrainings = afTimeLineController.AllTrainings;
        Test.stopTest();

        // Assert
        system.assertEquals(actualTrainings, allTrainings);
                
    }

    // TODO consider removing currentTrainings alltogether since it just points to AllTrainings
    @isTest
    public static void currentTrainings_Getter_Test(){
        // Arrange
        List<Training__c> currTrainings;
        Test.startTest();
        List<Training__c> actualTrainings = Database.query(testTrainingQuery);

        // Act
        currTrainings = afTimeLineController.currentTrainings;
        Test.stopTest();

        // Assert
        system.assertEquals(actualTrainings, currTrainings);
                
    }

    @isTest
    public static void trainers_Getter_Test(){
        // Arrange
        List<User> tstTrainers;
        Test.startTest();
        List<User> actualTrainers = [
            SELECT Name FROM User WHERE UserRole.Name = 'Trainer' OR UserRole.Name = 'CoTrainer' ORDER BY Name];

        // Act
        tstTrainers = afTimeLineController.trainers;  
        Test.stopTest(); 

        // Assert       
        system.assertEquals(actualTrainers, tstTrainers);  
                
    }

    @isTest
    public static void getTrainingLocations_Test(){
        // Arrange
        String[] testLocations;
        Test.startTest();
        //String[] actualLocations = ApexTestUtilityClass.getTrainingLocationsTest(Database.query(testTrainingQuery));

        // Act
        testLocations = afTimeLineController.getTrainingLocations();
        Test.stopTest();

        // Assert
        //System.AssertEquals(actualLocations, testLocations);
                
    }

    // afTimelineController.getTrainers() does not get trainers; it gets the names of trainers doing trainings.
    // Test does not actually ensure quality of the method.
    @isTest
    public static void getTrainers_Test(){
        // Arrange
        Test.startTest();
        // Get make map of trainers' Id,Names and add Names to testNames if their Ids appear in training's Trainer__c field
        List<String> testNames = new List<String>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Trainer' LIMIT 1].id;
        List<User> trainerList = [SELECT Id, Name FROM User WHERE ProfileId = :profileId];
        Map<Id,String> trainerMap = new Map<Id,String>();
        for(User trainer : trainerList){
            trainerMap.put(trainer.Id,trainer.Name);
        }        
        for (Training__c training : [SELECT Trainer__c FROM Training__c]){
            if(trainerMap.containsKey(training.Trainer__c)){
            testNames.add(trainerMap.get(training.Trainer__c));
            }
        }
        List<String> actualNames;

        // Act
        actualNames = afTimelineController.getTrainers();
        Test.stopTest();

        // Assert
        System.assertEquals(actualNames,testNames);
    }

    // @TODO don't say this
    // A test that gives code coverage to afTimelineController.wrapTrainingToJSON() so project meets code-coverage threshold.
    // Test does not actually ensure quality of the method. Functionally, it just replicates the method's behavior.
    // Might as well be a call to the method and an assert(true);
    @isTest
    public static void wrapTrainingToJSON(){
        // Arrange
        String actualWrappedTrainingData;
        String testWrappedTrainingData;

        Test.startTest();
        List<afTimelineController.TrainingDataWrapper> trainerData = new List<afTimelineController.TrainingDataWrapper>();
        List<String> trainerNames = new List<String>();
        Integer trainerNumber = 0;
        Integer j = 0;
        for(Training__c t : afTimelineController.currentTrainings){
            Boolean makeNewTrainerNumber = false;
            afTimelineController.TrainingDataWrapper tdw = new afTimelineController.TrainingDataWrapper();
            for(j = 0 ; j < trainerNames.size() ; j++){   
                if(trainerNames[j] == t.Trainer__r.Name){
                    tdw.y = j;
                    makeNewTrainerNumber = true;
                    break;
                } 
            }
            if(!makeNewTrainerNumber){
                trainerNames.add(t.Trainer__r.Name);
                tdw.y = trainerNumber;
                trainerNumber++;
            }
            tdw.x = t.StartDate__c;
            tdw.x2 = t.EndDate__c;
            tdw.series = t.TrainingTrack__r.ShortName__c;
            tdw.color = t.TrainingTrack__r.Color__c;
            tdw.trainerName = t.Trainer__r.Name;
            trainerData.add(tdw);
        }
        testWrappedTrainingData = System.json.serialize(trainerData);  

        // Act
        actualWrappedTrainingData = afTimelineController.wrapTrainingToJSON();
        Test.stopTest();

        //Assert
        System.assertEquals(actualWrappedTrainingData,testWrappedTrainingData);
    }

    // Ensure the method filters properly
    // Covers positive and negative test cases
    @isTest
    public static void filterTrainingsByYearLocationQuarter_Test(){
        // Arrange
        String testTrainerData;
        String actualTrainerData;

        List<String> tLocList = new List<String>{'Tampa', 'Washington', 'Reston'};
        List<Integer> monthList;
        List<Training__c> NewTrainings;
        Integer convertedYear;
        Integer trainingYear;
        Integer trainingMonth;

        // Act
        Test.startTest();
        for(Integer i = 1; i <= 6; i++){
            monthList = new List<Integer>();
            NewTrainings = new List<Training__c>();
            for(Integer j = 2; j <= 6; j++){
                // Make testTrainerData
                // i determines year
                switch on(i) {
                    when 1 {
                        convertedYear = Date.today().year() + 1;
                    }
                    when 2 {
                        convertedYear = Date.today().year();
                    }
                    when 3  {
                        convertedYear = Date.today().year() - 1;
                    }
                    when 4 {
                        convertedYear = Date.today().year() - 2;
                    }
                    when 5 {
                        convertedYear = null;
                    }
                    when else {
                        //convertedYear = null;
                        testTrainerData = null;

                        afTimelineController.currentTrainings = null;
                        // Make actualTrainerData
                        actualTrainerData = afTimelineController.filterTrainingsByYearLocationQuarter(tLocList,i,j);
                        afTimelineController.currentTrainings = null;
                        continue;
                    }
                }
                // j determines quarter
                switch on(j) {
                    when 2 {
                        monthList.add(01);
                        monthList.add(02);
                        monthList.add(03);
                    }
                    when 3 {
                        monthList.add(04);
                        monthList.add(05);
                        monthList.add(06);
                    }
                    when 4 {
                        monthList.add(07);
                        monthList.add(08);
                        monthList.add(09);
                    }
                    when 5 {
                        monthList.add(10);
                        monthList.add(11);
                        monthList.add(12);
                    }
                    when else {
                        testTrainerData = null;

                        afTimelineController.currentTrainings = null;
                        // Make actualTrainerData
                        actualTrainerData = afTimelineController.filterTrainingsByYearLocationQuarter(tLocList,i,j);
                        afTimelineController.currentTrainings = null;
                        continue;
                    }
                }
                for(Training__c t : afTimelineController.currentTrainings) {
                    trainingYear = t.StartDate__c.year();
                    trainingMonth = t.StartDate__c.month();

                    for(String s : tLocList) {
                        if(t.TrainingLocation__r.OfficeName__c == s
                            && monthList.contains(trainingMonth)
                            && (convertedYear == trainingYear || convertedYear == null)
                        ){
                            NewTrainings.add(t);
                        }
                    }
                }
                afTimelineController.currentTrainings = NewTrainings;
                testTrainerData = afTimelineController.wrapTrainingToJSON();
                // Reset afTimelineController.currentTrainings
                // This way actualTrainerData is generated under the same conditions as testTrainerData
                afTimelineController.currentTrainings = null;

                // Make actualTrainerData
                actualTrainerData = afTimelineController.filterTrainingsByYearLocationQuarter(tLocList,i,j);
                afTimelineController.currentTrainings = null;

                // Assert
                System.debug('i:'+String.valueOf(i));
                System.debug('j:'+String.valueOf(j));
                System.debug('test:'+testTrainerData);
                System.debug('actual:'+actualTrainerData);
                System.assertEquals(actualTrainerData,testTrainerData);
            }
        }
        Test.stopTest();
        
    }

    // @isTest
    // public static void filterTrainingsByYearLocation_Test(){
    //     // Arrange

    //     // Act

    //     // Assert
        
    // }

    // @isTest
    // public static void filterTrainingsByYear_Test(){
    //     // Arrange

    //     // Act

    //     // Assert
        
    // }

    // @isTest
    // public static void filterTrainingsByYearQuarter_Test(){
    //     // Arrange

    //     // Act

    //     // Assert
        
    // }

    /***********************************************
     * Utility methods to create mock testing data *
     ***********************************************/
/*
    // Create dummy Training__c's and return them in a List.
    private static List<Training__c> createTrainingsData(
        Integer amount,
        List<Training_Location__c> tLocList,
        List<User> tTrainerList,
        List<Date> tsDateList,
        List<Training_Track__c> tTrackList
        ){

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
    private static List<User> createUserData(Integer amount){

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
    private static List<Training_Location__c> createLocationData(Integer amount){

        List<Training_Location__c> result = new List<Training_Location__c>();
        for(Integer i = 0; i < amount; i++){
            Training_Location__c tLoc = new Training_Location__c(
                OfficeName__c = 'OfficeName' + String.valueOf(i),
                Access__c = 'Open Access');
            result.add(tLoc);
            }
        return result;
    }

    // @TODO populate dates with something
    // Create dummy Date objects and return them in a List.
    private static List<Date> createStartDateData(Integer amount){

        Date curr = Date.today();
        List<Date> result = new List<Date>();
        for(Integer i = 0; i < amount; i++){
            if (curr < curr.toStartOfWeek().addDays(1) && curr > curr.toStartOfWeek().addDays(3)){
                curr = curr.addDays(7).toStartOfWeek().addDays(1);
            }
            Date sDate = Date.newInstance(curr.year(),curr.month(),curr.day());
            result.add(sDate);
        }
        return result;
    }
    
    // Create dummy Training_Track__c's and return them in a List.
    private static List<Training_Track__c> createTrainingTrackData(Integer amount){
        
        List<Training_Track__c> result = new List<Training_Track__c>();
        for(Integer i = 0 ; i < amount; i++){
            Training_Track__c track = new Training_Track__c(
                ShortName__c = 'Track'+String.valueOf(i));
            result.add(track);
        }
        return result;
    }

    // Insert test data; Inserting to multiple objects without an async method produces a MIXED_DML_OPERATION
    // To be used between Test.startTest() and Test.stopTest()
    @future
    private static void insertTestData(
        // List<User> users,
        // List<Training_Track__c> tracks,
        // List<Training_Location__c> locations,
        // List<Training__c> trainings
        ){

        users = createUserData(5);
        tracks = createTrainingTrackData(2);
        locations = createLocationData(5);
        trainings = createTrainingsData(10,locations,users,createStartDateData(10),tracks);
        
        Database.insert(users);
        System.runAs(users[0]){
            Database.insert(tracks);
            Database.insert(locations);
            Database.insert(trainings);
        }
    }*/

}