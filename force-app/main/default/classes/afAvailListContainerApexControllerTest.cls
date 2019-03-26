/******************************************************************
* afAvailListContainerApexController Test Class                     
* Author: Ian Blanchard
* 
* Tests the methods of the Apex Controller for 
*   the afAvailListContainer component     
******************************************************************/

@isTest
public class afAvailListContainerApexControllerTest {

    private static List<User> trainers;
    private static List<Training_Track__c> tracks;
    private static List<Training_Location__c> locations;
    private static List<Skill__c> skills;
    private static List<Training__c> trainings;
    private static List<Date> sDates;
    
    @testSetup
    public static void doSetup(){

        Test.startTest();

        //Create 52 Trainer users
        trainers = UtilityMethods.createUserData(52);
        insert trainers;

        //Create starting dates and trainings tracks
        sDates = UtilityMethods.createStartDateData(13);
        tracks = UtilityMethods.createTrainingTrackData(3);
        
        //Create Training Locations for each valid picklist value
        locations = new List<Training_Location__c>();
        locations.add(new Training_Location__c(OfficeName__c = 'Fairfax'));
        locations.add(new Training_Location__c(OfficeName__c = 'Reston'));
        locations.add(new Training_Location__c(OfficeName__c = 'SPS'));
        locations.add(new Training_Location__c(OfficeName__c = 'UTA-ERB'));
        locations.add(new Training_Location__c(OfficeName__c = 'USF-NEC'));
        locations.add(new Training_Location__c(OfficeName__c = 'ASU'));
        locations.add(new Training_Location__c(OfficeName__c = 'WVU-CBE'));
        locations.add(new Training_Location__c(OfficeName__c = 'Queens'));
        locations.add(new Training_Location__c(OfficeName__c = 'USF-SOC'));
        locations.add(new Training_Location__c(OfficeName__c = 'Online'));
        locations.add(new Training_Location__c(OfficeName__c = 'USF-BSN'));
        locations.add(new Training_Location__c(OfficeName__c = 'UTA-PRS'));
        locations.add(new Training_Location__c(OfficeName__c = 'UTA-K'));


        //Insert Tracks and Locations
        System.runAs(trainers.get(0)){
            insert tracks;
            insert locations;
        }

        //Update trainers so four trainers are at each of the 13 locations
        for (Integer i = 0; i < 13; i++){
            trainers.get(i).CurrentLocation__c = locations.get(i).OfficeName__c;
            trainers.get(i + 13).CurrentLocation__c = locations.get(i).OfficeName__c;
            trainers.get(i + 26).CurrentLocation__c = locations.get(i).OfficeName__c;
            trainers.get(i + 39).CurrentLocation__c = locations.get(i).OfficeName__c;
        }
        update trainers;

        //Create 13 Skills
        skills = UtilityMethods.createSkillData(52,trainers,tracks);
        
        //Create 13 Trainings
        //There are 4 trainers at each location. 2 of the 4 at each location will have a Training
        trainings = new List<Training__c>();
        for (Integer i = 0; i < 13; i++){
            trainings.add(new Training__c(TrainingLocation__c = locations.get(i).id,
                                          Trainer__c = trainers.get(i).id,
                                          StartDate__c = sDates.get(i),
                                          EndDate__c = sDates.get(i).addDays(70).toStartOfWeek().addDays(5),
                                          TrainingTrack__c = tracks.get(Math.mod(i,tracks.size())).id));
        }

        //Insert Trainings and Skills
        System.runAs(trainers.get(0)){
            insert skills;
            insert trainings;
        }

        Test.stopTest();
    }

    @isTest
    public static void trainerSortTest(){

        Test.startTest();

        //Create Parameters for the Controller's method
        Date startDate = Date.today().addDays(14).toStartOfWeek().addDays(1);
        Date endDate = startDate.addDays(70).toStartOfWeek().addDays(5);
        ID track = [SELECT id FROM Training_Track__c WHERE ShortName__c = 'Track0' LIMIT 1].id;
        String officeName = 'Fairfax';

        //Initialize List to hold results from the method
        List<User> results = new List<User>();

        /**********************
        * All Parameters Case
        **********************/

        //Call method with all parameters filled
        results = afAvailListContainerApexController.sortTrainersBySelectedCategories(startDate,endDate,track,officeName);

        //This sort version has all trainers with no trainings in the time frame provided. Then it sorts further by putting trainers
        //          at the provided location and with a skill in the provided track towards the top.
        //The order they should be sorted as follows: (Numbers are the number in the last name)
        //          39,12,15,18,21,24,27,3,30,33,36,42,45,48,51,6,9,13,26,14,16,17,18,2
        //          20,22,23,25,28,29,31,32,34,35,37,38,4,40,41,43,44,46,47,49,5,50,7,8,0,1
        System.assertEquals(results.size(),52);
        System.assertEquals(results.get(0).name, 'last 39');
        System.assertEquals(results.get(1).name, 'last 12');
        System.assertEquals(results.get(2).name, 'last 15');
        System.assertEquals(results.get(13).name, 'last 48');
        System.assertEquals(results.get(14).name, 'last 51');
        System.assertEquals(results.get(15).name, 'last 6');
        System.assertEquals(results.get(16).name, 'last 9');
        System.assertEquals(results.get(17).name, 'last 13');
        System.assertEquals(results.get(28).name, 'last 23');
        System.assertEquals(results.get(29).name, 'last 25');
        System.assertEquals(results.get(30).name, 'last 28');
        System.assertEquals(results.get(31).name, 'last 29');
        System.assertEquals(results.get(32).name, 'last 31');
        System.assertEquals(results.get(40).name, 'last 41');
        System.assertEquals(results.get(41).name, 'last 43');
        System.assertEquals(results.get(42).name, 'last 44');
        System.assertEquals(results.get(45).name, 'last 49');
        System.assertEquals(results.get(46).name, 'last 5');
        System.assertEquals(results.get(50).name, 'last 0');
        System.assertEquals(results.get(51).name, 'last 1');





        /**********************
        * No Dates Case
        **********************/

        //Call method without a start or end date
        results = afAvailListContainerApexController.sortTrainersBySelectedCategories(null,null,track,officeName);

        //This sort version has all trainers with no upcoming trainings first, then trainers with trainings
        //          at some time in the future. Then it sorts further by putting trainers at the provided location 
        //          and with a skill in the provided track towards the top.
        //The order they should be sorted as follows: (Numbers are the number in the last name)
        //          39,15,18,21,24,27,30,33,36,42,45,48,51,13,26,14,16,17,19,20,22,23,25,28,29,31,
        //          32,34,35,37,38,40,41,43,44,46,47,49,50,0,12,3,6,9,10,11,1,2,4,5,7,8
        System.assertEquals(results.size(),52);
        System.assertEquals(results.get(0).name, 'last 39');
        System.assertEquals(results.get(1).name, 'last 15');
        System.assertEquals(results.get(2).name, 'last 18');
        System.assertEquals(results.get(3).name, 'last 21');
        System.assertEquals(results.get(12).name, 'last 51');
        System.assertEquals(results.get(13).name, 'last 13');
        System.assertEquals(results.get(14).name, 'last 26');
        System.assertEquals(results.get(15).name, 'last 14');
        System.assertEquals(results.get(16).name, 'last 16');
        System.assertEquals(results.get(17).name, 'last 17');
        System.assertEquals(results.get(26).name, 'last 32');
        System.assertEquals(results.get(27).name, 'last 34');
        System.assertEquals(results.get(38).name, 'last 50');
        System.assertEquals(results.get(39).name, 'last 0');
        System.assertEquals(results.get(40).name, 'last 12');
        System.assertEquals(results.get(41).name, 'last 3');
        System.assertEquals(results.get(44).name, 'last 1');
        System.assertEquals(results.get(49).name, 'last 5');
        System.assertEquals(results.get(50).name, 'last 7');
        System.assertEquals(results.get(51).name, 'last 8');





        /**********************
        * No Track Case
        **********************/

        //Call method without a training track
        results = afAvailListContainerApexController.sortTrainersBySelectedCategories(startDate,endDate,null,officeName);

        //This sort version has all trainers with no trainings in the timeframe provided. Then it sorts trainers
        //          at the provided location towards the top.
        //The order they should be sorted as follows: (Numbers are the number in the last name)
        //          13,26,39,10,11,12,14,15,16,17,18,19,2,20,21,22,23,24,25,27,28,29,3,30,31,32
        //          33,34,35,36,37,38,4,40,41,42,43,44,45,46,47,48,49,5,50,51,6,7,8,9,0,1
        System.assertEquals(results.size(),52);
        System.assertEquals(results.get(0).name, 'last 13');
        System.assertEquals(results.get(1).name, 'last 26');
        System.assertEquals(results.get(2).name, 'last 39');
        System.assertEquals(results.get(3).name, 'last 10');
        System.assertEquals(results.get(4).name, 'last 11');
        System.assertEquals(results.get(24).name, 'last 31');
        System.assertEquals(results.get(25).name, 'last 32');
        System.assertEquals(results.get(26).name, 'last 33');
        System.assertEquals(results.get(27).name, 'last 34');
        System.assertEquals(results.get(45).name, 'last 51');
        System.assertEquals(results.get(46).name, 'last 6');
        System.assertEquals(results.get(47).name, 'last 7');
        System.assertEquals(results.get(50).name, 'last 0');
        System.assertEquals(results.get(51).name, 'last 1');





        /**********************
        * No Location Case
        **********************/

        //Call method without a location name
        results = afAvailListContainerApexController.sortTrainersBySelectedCategories(startDate,endDate,track,null);

        //This sort version has all trainers with no trainings in the timeframe provided. Then it sorts trainers
        //           with skill in the provided training track towards the top.
        //The order they should be sorted as follows: (Numbers are the number in the last name)
        //          12,15,18,21,24,27,3,30,33,36,39,42,45,48,51,6,9,10,11,13,14,16,17,19,2,20
        //          22,23,25,26,28,29,31,32,34,35,37,38,4,40,41,43,44,46,47,49,5,50,7,8,0,1        
        System.assertEquals(results.size(),52);
        System.assertEquals(results.get(0).name, 'last 12');
        System.assertEquals(results.get(1).name, 'last 15');
        System.assertEquals(results.get(2).name, 'last 18');
        System.assertEquals(results.get(3).name, 'last 21');
        System.assertEquals(results.get(14).name, 'last 51');
        System.assertEquals(results.get(15).name, 'last 6');
        System.assertEquals(results.get(16).name, 'last 9');
        System.assertEquals(results.get(17).name, 'last 10');
        System.assertEquals(results.get(18).name, 'last 11');
        System.assertEquals(results.get(25).name, 'last 20');
        System.assertEquals(results.get(26).name, 'last 22');
        System.assertEquals(results.get(48).name, 'last 7');
        System.assertEquals(results.get(49).name, 'last 8');
        System.assertEquals(results.get(50).name, 'last 0');
        System.assertEquals(results.get(51).name, 'last 1');





        /**********************
        * Only Track Case
        **********************/

        //Call method with only a training track
        results = afAvailListContainerApexController.sortTrainersBySelectedCategories(null,null,track,null);

        //This sort version has all trainers with no upcoming trainings first, then trainers with trainings
        //          at some time in the future. Then it sorts trainers with skill in the provided training track 
        //          towards the top.
        //The order they should be sorted as follows: (Numbers are the number in the last name)
        //          15,18,21,24,27,30,33,36,39,42,45,48,51,13,14,16,17,19,20,22,23,25,26,28,29,31,
        //          32,34,35,37,38,40,41,43,44,46,47,49,50,0,12,3,6,9,1,10,11,2,4,5,7,8
        System.assertEquals(results.size(),52);
        System.assertEquals(results.get(0).name, 'last 15');
        System.assertEquals(results.get(1).name, 'last 18');
        System.assertEquals(results.get(2).name, 'last 21');
        System.assertEquals(results.get(3).name, 'last 24');
        System.assertEquals(results.get(12).name, 'last 51');
        System.assertEquals(results.get(13).name, 'last 13');
        System.assertEquals(results.get(14).name, 'last 14');
        System.assertEquals(results.get(38).name, 'last 50');
        System.assertEquals(results.get(39).name, 'last 0');
        System.assertEquals(results.get(40).name, 'last 12');
        System.assertEquals(results.get(49).name, 'last 5');
        System.assertEquals(results.get(50).name, 'last 7');
        System.assertEquals(results.get(51).name, 'last 8');





        /**********************
        * Only Dates Case
        **********************/

        //Call method with only a start and end date
        results = afAvailListContainerApexController.sortTrainersBySelectedCategories(startDate,endDate,null,null);

        //This sort version has all trainers with no trainings in the timeframe provided first, then 
        //          trainers with trainings at some time in the future. No other sort criteria are used
        //The order they should be sorted as follows: (Numbers are the number in the last name)
        //          10,11,12,13,14,15,16,17,18,19,2,20,21,22,23,24,25,26,27,28,29,3,30,31,32,33
        //          34,35,36,37,38,39,4,40,41,42,43,44,45,46,47,48,49,5,50,51,6,7,8,9,0,1
        System.assertEquals(results.size(),52);
        System.assertEquals(results.get(0).name, 'last 10');
        System.assertEquals(results.get(1).name, 'last 11');
        System.assertEquals(results.get(2).name, 'last 12');
        System.assertEquals(results.get(3).name, 'last 13');
        System.assertEquals(results.get(25).name, 'last 33');
        System.assertEquals(results.get(26).name, 'last 34');
        System.assertEquals(results.get(27).name, 'last 35');
        System.assertEquals(results.get(46).name, 'last 6');
        System.assertEquals(results.get(47).name, 'last 7');
        System.assertEquals(results.get(48).name, 'last 8');
        System.assertEquals(results.get(49).name, 'last 9');
        System.assertEquals(results.get(50).name, 'last 0');
        System.assertEquals(results.get(51).name, 'last 1');





        /**********************
        * Only Location Case
        **********************/

        //Call method with only a location name
        results = afAvailListContainerApexController.sortTrainersBySelectedCategories(null,null,null,officeName);

        //This sort version has all trainers with no upcoming trainings first, then trainers with trainings
        //      at some time in the future. No other sort criteria are used
        //The order they should be sorted as follows: (Numbers are the number in the last name)
        //          13,26,39,14,15,16,17,18,19,20,21,22,23,24,25,27,28,29,30,31,32,33,34,35,36,37,
        //          38,40,41,42,43,44,45,46,47,48,49,50,51,0,1,10,11,12,2,3,4,5,6,7,8,9
        System.assertEquals(results.size(),52);
        System.assertEquals(results.get(0).name, 'last 13');
        System.assertEquals(results.get(1).name, 'last 26');
        System.assertEquals(results.get(2).name, 'last 39');
        System.assertEquals(results.get(3).name, 'last 14');
        System.assertEquals(results.get(4).name, 'last 15');
        System.assertEquals(results.get(38).name, 'last 51');
        System.assertEquals(results.get(39).name, 'last 0');
        System.assertEquals(results.get(40).name, 'last 1');
        System.assertEquals(results.get(41).name, 'last 10');
        System.assertEquals(results.get(50).name, 'last 8');
        System.assertEquals(results.get(51).name, 'last 9');





        /**********************
        * No Parameters Case
        **********************/

        //Call Method with null for all parameters
        results = afAvailListContainerApexController.sortTrainersBySelectedCategories(null,null,null,null);

        //This sort version has all trainers with no upcoming trainings first, then trainers with trainings
        //      at some time in the future. No other sort criteria are used
        //The order they should be sorted as follows: (Numbers are the number in the last name)
        //          13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38
        //          39,40,41,42,43,44,45,46,47,48,49,50,51,0,1,10,11,12,2,3,4,5,6,7,8,9
        System.assertEquals(results.size(),52);
        System.assertEquals(results.get(0).name, 'last 13');
        System.assertEquals(results.get(1).name, 'last 14');
        System.assertEquals(results.get(2).name, 'last 15');
        System.assertEquals(results.get(37).name, 'last 50');
        System.assertEquals(results.get(38).name, 'last 51');
        System.assertEquals(results.get(39).name, 'last 0');
        System.assertEquals(results.get(40).name, 'last 1');
        System.assertEquals(results.get(51).name, 'last 9');
    

        Test.stopTest();
    }
}