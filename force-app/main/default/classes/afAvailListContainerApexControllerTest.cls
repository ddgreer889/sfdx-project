/******************************************************************
* afAvailListContainerApexController Test Class                     
* Authors: Daniel Cadwell / Ian Blanchard
* 
* Tests the methods of the Apex Controller for 
*   the afAvailListContainer component            
******************************************************************/

@isTest
public class afAvailListContainerApexControllerTest {
    
    @TestSetup
    static void doSetup(){

        //Create 200 Trainer users
        List<User> trainers = UtilityMethods.createUserData(200);

        //Make 100 of the users not available due to Training
        for (integer i = 100; i < 200; i++)
            trainers.get(i).Available__c = 'Training';

        //Insert users
        insert trainers;

    }


    @isTest
    public static void doTest() {
        
        Training_Location__c tloc = UtilityMethods.createLocationData(1).get(0);
        insert tloc;
        
        List<Training_Room__c> allRooms = new List<Training_Room__c>();

        for (Integer i = 0; i <= 50; i++){
             Training_Room__c trAvail = new Training_Room__c(TrainingLocation__c = tloc.id,
                                                        AVAvailability__c = 'yes',
                                                        RoomCapacity__c = 35);

            Training_Room__c trReq = new Training_Room__c(TrainingLocation__c = tloc.id,
                                                        AVAvailability__c = 'Upon Request',
                                                        RoomCapacity__c = 40);

            Training_Room__c trUnAvail = new Training_Room__c(TrainingLocation__c = tloc.id,
                                                        AVAvailability__c = 'no',
                                                        RoomCapacity__c = 30);

            allRooms.add(trAvail);
            allRooms.add(trReq);
            allRooms.add(trUnAvail);
        }
        
        insert allRooms;
        
        /*List<Training_Room__c> rooms = [SELECT Id, name, TrainingLocation__c, TrainingLocationName__c, AVAvailability__c, RoomCapacity__c
                                               FROM Training_Room__c
                                               ORDER BY name];*/

        List<Training_Room__c> rooms = afAvailListContainerApexController.getRooms(allRooms);
        
        system.assert(rooms.size() > 0);
        
        List<User> allTrainers = [SELECT Id, Name, Available__c
                                   FROM User 
                                   WHERE UserRole.Name = 'Trainer'];

        List<User> trainers = afAvailListContainerApexController.getAllTrainers(allTrainers);

        system.assert(trainers.size() > 0);
    }
}