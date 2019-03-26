public class afExternalTrainerBatchesApexController {

    @AuraEnabled
    public static List<Training__c> AllExternalTrainings
    {
       get{
           if(AllExternalTrainings == null)
           {
               AllExternalTrainings = [SELECT Id, Name, TrainingTrack__r.ShortName__c,
                               Status__c, TrainingClass__c, StartDate__c, EndDate__c, External_Trainer__r.First_Name__c, External_Trainer__r.Last_Name__c
                               FROM Training__c
                               WHERE External_Trainer__r.First_Name__c != NULL
                               ORDER BY StartDate__c];
           }
			
           return AllExternalTrainings;
       }
       set;
    }

    @AuraEnabled
    public static List<Training__c> currentExternalTrainings
    {
       get{
           if(currentExternalTrainings == null)
           {
               currentExternalTrainings = AllExternalTrainings;
           }
           return currentExternalTrainings;
       }
       set;
    }
    @AuraEnabled
    public static List<Training__c> getExtTrainingBatches() {
       return AllExternalTrainings;
    }
    
    //Used by afExternalTrainerTabBatches to get batches by external trainer id to populate data tables
    @AuraEnabled
    public static List<Training__c> getExtTrainingBatchesById(Id externalTrainerId){
        List<Training__c> ExternalTrainings = 
            [SELECT Id, Name, TrainingClass__c, StartDate__c, EndDate__c, Status__c, TrainingTrack__r.ShortName__c, External_Trainer__r.Id
             FROM Training__c 
             WHERE (External_Trainer__r.Id = :externalTrainerId)
             ORDER BY StartDate__c];
            return ExternalTrainings;
    }

    @AuraEnabled
    public static void deleteExtBatchesServer(String[] batchIds)
    {
        List<Training__c> batchesToDelete = new List<Training__c>();
        
        for(integer s = 0; s < batchIds.size(); s++){
                batchesToDelete.add(new Training__c(Id = batchIds[s]));
            }
        
       
        delete batchesToDelete; 
    }

    @AuraEnabled
    public static void updateExtBatchesServer(List<Training__c> updatedBatches){
		System.debug('Batches to Update: ' + updatedBatches);
        
        for(integer s = 0; s < updatedBatches.size(); s++){
            if(updatedBatches[s].StartDate__c != null)
            {
                updatedBatches[s].StartDate__c = updatedBatches[s].StartDate__c.addDays(-1);
                System.debug('after subtract day: ' + updatedBatches[s]);
            }
            else if(updatedBatches[s].EndDate__c != null)
            {
                updatedBatches[s].EndDate__c = updatedBatches[s].EndDate__c.addDays(-1);
                System.debug('after subtract day: ' + updatedBatches[s]);
            }
        }
        
        update updatedBatches;
        
    }

}