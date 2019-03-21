public class afAvailListContainerApexController {
    @AuraEnabled
    public static List<Training_Room__c> getRooms(List<Training_Room__c> allRooms){
        
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
    public static List<User> getAllTrainers(List<user> Trainers){
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
    public static List<Training_Room__c> RoomsMatchLocation (String location, List<Training_Room__c> trl)
    {
        system.debug(location);
        List<Training_Room__c> newRooms = new List<Training_Room__c>();
        if((location == '') || location == null)
        {
            return trl;
        }
        else{          
            for(Integer i = 0; i<trl.size(); i++)
            {
                if(location == trl[i].TrainingLocation__c)
                {
                    newRooms.add(trl[i]);
                }
            }
        }        
        return newRooms;        
    }
    @AuraEnabled
    public static List<User> TrainerHasSkill(String track, List<User> trainers, List<Skill__c> skills){       
        for(User t:trainers){
            t.hasSkill__c = false;  
        } 
        if(track!=null){ 
            for(Skill__c s:skills){
                if(s.Training_Track__c == track){                    
                    for(User u:trainers){
                        if(u.Id == s.Trainer__c){
                            u.hasSkill__c = true;
                        }
                    }
                }   
            } 
        }
        return trainers;
    } 
}