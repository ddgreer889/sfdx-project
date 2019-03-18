//Testing af PTO Tabs Apex Controller
//author: sergey sambros
@isTest
public class afPTOTabsApexControllerTest {
    
    @isTest
    static void PTOTabGetAllPTOs(){
       List<PTO__c> testPTO = [SELECT Id, Status__c, StartDate__c FROM PTO__c ORDER BY StartDate__c];
       List<PTO__c> actualPTO = afPTOTabsApexController.getAllPTOs(ApexTestUtilityClass.users.Id);
       System.assertEquals(testPTO,actualPTO);
    }
    
    @isTest
    public static void doTest() {

    }
}