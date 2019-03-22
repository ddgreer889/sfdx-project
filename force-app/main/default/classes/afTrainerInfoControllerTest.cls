//Testing afTrainerInfoController
//author: sergey sambros
//
//16/18 lines covered, need to write asserts 

@isTest
public class afTrainerInfoControllerTest {

      @isTest
      public static void afTrainerInfoControllerTest1() {    
          
          afTrainerInfoController testC = new afTrainerInfoController();
          
      	  List<User> testU = UtilityMethods.createUserData(3);
          Attachment testA = new Attachment(OwnerId=testU[0].Id);
          //runAs(testU[0]){ContentDocument testD = new ContentDocument();}
          testC.getAttachment();
          testC.objAttachment = testA;
          testC.uploadFile();
          system.debug(testC.message);
          afTrainerInfoController.getFile(testU[0].Id);
          
      }
          
      
      /*User tempUser = [SELECT Id, CreatedById FROM User LIMIT 1];
      ContentDocument doc = [SELECT Id, Title FROM ContentDocument WHERE CreatedbyId = :tempUser.CreatedById ORDER BY CreatedDate DESC LIMIT 1];
      System.debug('doc: ' + doc);
      system.assertEquals(doc, afTrainerInfoController.getFile(tempUser.CreatedById));
      }
	*/
	  
          
    
    @isTest
    public static void doTest() {

    }
}
