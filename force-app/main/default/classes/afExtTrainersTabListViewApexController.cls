/**
*Controller for external trainers list view. VERY similar to afTrainersTabListView but implemented for external trainers. Should be encapsulated tbh.
*By-Sharif and Jon
*
*/
public class afExtTrainersTabListViewApexController {

   @AuraEnabled
   public static List<External_Trainer__c> allTrainers() {
       return [SELECT Id, First_Name__c, Last_Name__c, Available__c, Training_Skills__c, Current_Location__c
               FROM External_Trainer__c
            ];
   }

   @AuraEnabled
   public static String getTrainerSkills(Id ExternalTrainerId) {
       String returnSkills;

       List<External_Trainer__c> ExternaltrainerSkills = [SELECT Id, Training_Skills__c
                                       FROM External_Trainer__c
                                       WHERE Id = :ExternalTrainerId];

       if(ExternaltrainerSkills.size() > 0) {
           for(Integer i = 0; i < ExternaltrainerSkills.size(); i++) {
               if(returnSkills == null) {
                   returnSkills = ExternaltrainerSkills[i].Training_Skills__c;
               } else {
                   returnSkills += (', ' + ExternaltrainerSkills[i].Training_Skills__c);
               }
           }
       }
       return returnSkills;
   }
}