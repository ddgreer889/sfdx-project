//Testing afTrainerInfoController
//author: sergey sambros
@isTest
public class afTrainerInfoControllerTest {
      @isTest
      public static void afTrainerInfoControllerTest1(){      
      User tempUser = [SELECT Id, CreatedById FROM User LIMIT 1];
      ContentDocument doc = [SELECT Id, Title FROM ContentDocument WHERE CreatedbyId = :tempUser.CreatedById ORDER BY CreatedDate DESC LIMIT 1];
      System.debug('doc: ' + doc);
      system.assertEquals(doc, afTrainerInfoController.getFile(tempUser.CreatedById));
      }
    
    @isTest
    public static void doTest() {

    }
}