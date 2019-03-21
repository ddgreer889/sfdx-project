public class afAvailListContainerApexController {

public static List<Training_Room__c> allRooms = [SELECT Id, name, TrainingLocation__c, TrainingLocationName__c, AVAvailability__c, RoomCapacity__c
                                                    FROM Training_Room__c
                                                    ORDER BY name];

public static List<User> Trainers = [SELECT Id, Name, Available__c
                                        FROM User 
                                        WHERE UserRole.Name = 'Trainer'];
/*WHERE Available__c!=null*/ /*UserRoleId=trainer role Id*/

@AuraEnabled
public static List<Training_Room__c> getRooms(){
    List<Training_Room__c> yesFirst = new List<Training_Room__c>();
    List<Training_Room__c> Requests = new List<Training_Room__c>();
    List<Training_Room__c> NOs = new List<Training_Room__c>();
    
    //Loop through all of the rooms and separate them by their availablity status
    for(Training_Room__c room : allRooms){
        if(room.AVAvailability__c == 'Yes'){
            yesFirst.add(room);
        }else if(room.AVAvailability__c == 'Upon Request'){
            Requests.add(room);
        }else if(room.AVAvailability__c == 'No'){
            NOs.add(room);
        }
    }
    
    //Put all the rooms in one list: 'Yes's first, 'No's last
    yesFirst.addAll(Requests);
    yesFirst.addAll(NOs);
    
    return yesFirst;
}

@AuraEnabled
public static List<User> getAllTrainers(){
    //Must add a WHERE clause UserRoleId=Trainer Role Id
    List<User> availableList = new List<User>();
    List<User> unavailableList = new List<User>();
    for(User t: Trainers){
        if(t.Available__c=='Available'){
            availableList.add(t);
        }else{
            unavailableList.add(t);
        }
    }
    availableList.addAll(unavailableList);
    return availableList;
}
@AuraEnabled
public static List<Skill__c> getAllSkills(){
    return [SELECT Training_Track__c, Trainer__c From Skill__c];
}
@AuraEnabled
public static List<Training__c> getAllTrainings(){
    return [SELECT StartDate__c, EndDate__c, Trainer__c, CoTrainer__c, TrainingRoom__c FROM Training__c];
}

@AuraEnabled
public static List<Training__c> trains(List<User> train, List<Training__c> batch){
        for(User a: train){
            for(Training__c b: batch){
                if(train[a].Id == batch[b].Trainer__c || train[a].Id == batch[b].CoTrainer__c){
                    Date prevStart = new Date(batch[b].StartDate__c);
                    Date prevEnd = new Date(batch[b].EndDate__c);

                    if((prevStart <= batch[b].StartDate__c && batch[b].StartDate__c <= prevEnd) ||
                        (prevStart <= batch[b].EndDate__c && batch[b].EndDate__c <= prevEnd) ||
                        (prevStart >= batch[b].StartDate__c && batch[b].EndDate__c >= prevEnd)){
                            train[a].Available__c = 'Training';
                            break;
                    }else{
                        train[a].Available__c = 'Available';
                    }
                }
            }
        }

@AuraEnabled
public static List<Training_Room__c> rooms(List<User> trainR, List<Training__c> batchR, List<Training_Room__c> room){
    for(Training_Room__c r: room){
        for(Training__c t: trainR){
            if(room[r].Id == batchR[t].Training_Room__c){
                Date prevStart = new Date(batch[b].StartDate__c);
                Date prevEnd = new Date(batch[b].EndDate__c);
            }

            if((prevStart <= batch[b].StartDate__c && batch[b].StartDate__c <= prevEnd) ||
                (prevStart <= batch[b].EndDate__c && batch[b].EndDate__c <= prevEnd) ||
                (prevStart >= batch[b].StartDate__c && batch[b].EndDate__c >= prevEnd)){
                    room[r].AVAvailability__c = 'No';
                    break;
            }else{
                    room[r].AVAvailability__c = 'Yes';
            }
        }
    }
}
}

}