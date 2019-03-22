/********************************************************************
* afNewBatchAndAvailApexController Test Class
* Author: Ian Blanchard
*
* Test Class for the Master Apex Controller. This Apex Controller
*   provides the queries for the three components on the Batch tab
*   so that the database can be queried as few times as possible.
*********************************************************************/


@isTest 
public class afNewBatchAndAvailApexControllerTest {

    private static List<User> trainers;
    private static List<Training_Room__c> rooms;
    private static List<Training_Location__c> locations;
    private static List<Training_Track__c> tracks;
    private static List<Skill__c> skills;
    private static List<Training__c> trainings;
    
    @TestSetup
    public static void doSetup(){

        trainers = UtilityMethods.createUserData(200);
        insert trainers;

        locations = UtilityMethods.createLocationData(200);

        System.runAs(trainers.get(0)) { 
            insert locations;
        }

        rooms = UtilityMethods.createRoomData(200,locations.get(0));
        tracks = UtilityMethods.createTrainingTrackData(200);

        System.runAs(trainers.get(0)) {
            insert tracks;
        }

        skills = UtilityMethods.createSkillData(200,trainers,tracks);
        trainings = UtilityMethods.createTrainingsData(200,locations,trainers,new List<Date>{Date.newInstance(2019,3,18)},tracks);


        System.runAs(trainers.get(0)){
            insert rooms;
            insert skills;
            insert trainings;
        }
        
    }

    @isTest
    public static void doTest() {
        List<User> trainerResults = afNewBatchAndAvailabilityApexController.masterTrainers();
        List<Training_Room__c> roomResults = afNewBatchAndAvailabilityApexController.masterRooms();
        List<Training_Location__c> locationResults = afNewBatchAndAvailabilityApexController.masterLocations();
        List<Skill__c> skillResults = afNewBatchAndAvailabilityApexController.masterSkills();
        List<Training__c> trainingResults = afNewBatchAndAvailabilityApexController.masterTrainings();

        System.assertEquals(trainers,trainerResults);
        System.assertEquals(rooms,roomResults);
        System.assertEquals(locations,locationResults);
        System.assertEquals(skills,skillResults);
        System.assertEquals(trainings,trainingResults);
    }

}
