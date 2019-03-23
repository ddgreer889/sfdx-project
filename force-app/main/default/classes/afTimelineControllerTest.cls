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
    private static List<User> trainers;
    private static List<Training__c> trainings;
    private static List<Training_Location__c> locations;
    private static List<Date> sDates;
    private static List<Training_Track__c> tracks;
    private static List<PTO__c> ptos;

    @TestSetup
    static void makeData(){
        Test.startTest();

        trainers = UtilityMethods.createUserData(100);
        insert trainers;

        sDates = UtilityMethods.createStartDateData(100);
        tracks = UtilityMethods.createTrainingTrackData(100);
        locations = UtilityMethods.createLocationData(100);
        System.runAs(trainers.get(0)){
            insert tracks;
            insert locations;
        }

        ptos = UtilityMethods.createPTOData(100,trainers.get(0));

        trainings = UtilityMethods.createTrainingsData(100,locations,trainers,sDates,tracks);

        System.runAs(trainers.get(0)){
            insert ptos;
            insert trainings;
        }


        Test.stopTest();
    }
    
    //Test the getTrainingLocations Method in the afTimelineController
    //Return List of Office Names (Strings) for all Training Locations
    @isTest
    public static void getTrainingLocationsTest(){
        
        List<String> officeNames = new List<String>();
        for (Training__c t : [SELECT id, TrainingLocation__r.OfficeName__c FROM Training__c ORDER BY Trainer__r.Name, StartDate__c]){
            officeNames.add(t.TrainingLocation__r.OfficeName__c);
        }

        Test.startTest();
        List<String> officeNameResults = afTimelineController.getTrainingLocations();
        Test.stopTest();

        System.assertEquals(officeNames,officeNameResults);
    }

    //Test the getTrainers Method in the afTimelineController
    // afTimelineController.getTrainers() does not get trainers; it gets the names of trainers doing trainings.
    @isTest
    public static void getTrainersTest(){

        Test.startTest();

        //Get the list of Trainers and Trainings
        List<User> trainers = [SELECT id, name FROM User WHERE UserRole.Name = 'Trainer' ORDER BY name];
        List<Training__c> trainings = [SELECT id, trainer__r.name FROM Training__c];

        //Create a list to store the names of all Trainers who have Trainings
        List<String> results = new List<String>();

        //Add all users who have trainings to the results list
        for (User u : trainers){
            for (Training__c t : trainings){
                if (u.name == t.Trainer__r.Name){
                    results.add(u.name);
                }
            }
        }

        //Call the controller method that finds all names of trainers who have trainings
        List<String> methodResults = afTimelineController.getTrainers();

        //Check that the two result lists have 100 trainer names in them, and that they are the same
        System.assertEquals(methodResults.size(),100);
        System.assertEquals(results.size(),100);
        System.assertEquals(methodResults,results);


        Test.stopTest();
    }


    //Test the wrapTrainingToJSON Method in the afTimelineController
    @isTest
    public static void wrapTrainingToJSONTest(){

        //Create a list containing the ShortNames of all Training Tracks (Strings, not sObjects)
        List<Training_Track__c> tracks = [SELECT id, ShortName__c FROM Training_Track__c];
        List<String> trackNames = new List<String>();
        for (Training_Track__c t : tracks){
            trackNames.add(t.ShortName__c);
        }

        
        /*****************************************
        * The PTOs are still pending approval.
        * This segment approves all of the PTOs.
        *****************************************/
        List<PTO__c> allPTOs = [SELECT id FROM PTO__c];
        List<ID> PTOids = new List<ID>();

        for (PTO__c p : allPTOs){
            PTOids.add(p.id);
        }

        Map</*ProcessInstance*/ Id, /*ProcessInstanceWorkItem*/ Id> m = new Map<Id, Id>();
        for (ProcessInstanceWorkItem p : [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkItem]) {
            m.put(p.ProcessInstanceId, p.Id);
        }

        List<Approval.ProcessWorkItemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
        for (ProcessInstance p : [SELECT Id, TargetObjectID FROM ProcessInstance WHERE TargetObjectID IN :PtoIds]) {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approved');
            req.setAction('Approve');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setWorkItemId(m.get(p.Id));
            reqs.add(req);
        }

        // Process all approvals at once to avoid DML limits
        Approval.process(reqs);
        /*******************
        * End PTO Approval
        *******************/

        //Call the Controller method, which returns a JSON as a String
        String jsonResults = afTimelineController.wrapTrainingToJSON();

        //Deserialize the JSON into a List of TrainingDataWrappers
        List<afTimelineController.TrainingDataWrapper> tdw = (List<afTimelineController.TrainingDataWrapper>) 
                                                              JSON.deserialize(jsonResults,
                                                                               List<afTimeLineController.TrainingDataWrapper>.class);
        
        //Run through all the TrainingDataWrappers in the deserialized JSON
        for (afTimelineController.TrainingDataWrapper t : tdw) {
            //Check that all values for every Wrapper instance in the list has been set
            System.assertNotEquals(t.y,null);
            System.assertNotEquals(t.x,null);
            System.assertNotEquals(t.x2,null);
            System.assertNotEquals(t.series,null);
            System.assertNotEquals(t.color,null);
            System.assertNotEquals(t.trainerName,null);

            //check that the values are valid
            System.assert(trackNames.contains(t.series) || t.series == 'PTO');
            System.assert(t.color.charAt(0) == 35 /* ASCII Code for # */ || t.color == 'Black');
            System.assert(t.x2 >= t.x); //End Date on or after Start Date
            System.assert(t.y >= 0); //Y-Axis value non-negative
        }
    }


    @isTest
    public static void filterTrainingsByYearLocationQuarterTest(){
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

    @isTest
    public static void filterTrainingsByYearLocationTest(){
        
    }

    @isTest
    public static void filterTrainingsByYearTest(){
        
    }

    @isTest
    public static void filterTrainingsByYearQuarterTest(){
        
    }

}