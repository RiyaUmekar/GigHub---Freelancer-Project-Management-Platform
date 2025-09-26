@isTest
public class ProjectTriggerHandlerTest {

    @isTest
    static void testProjectCostCalculation() {
        Free__c freelancer = new Free__c(
            Name = 'Test Freelancer',
            Hourly_Rate__c = 100
        );
        insert freelancer;

        Project__c proj = new Project__c(
            Name = 'Test Project',
            Estimated_Hours__c = 10,
            Assigned_Freelancer__c = freelancer.Id
        );
        insert proj;

        Test.startTest();
        Project__c insertedProj = [
            SELECT Id, Total_Cost__c, Estimated_Hours__c, Assigned_Freelancer__c
            FROM Project__c
            WHERE Id = :proj.Id
        ];
        Test.stopTest();

        System.debug('>>> Total Cost After Insert: ' + insertedProj.Total_Cost__c);
        System.assertNotEquals(null, insertedProj.Total_Cost__c,
            'Total cost should not be null after trigger fires');
        System.assertEquals(1000, insertedProj.Total_Cost__c,
            'Total cost should equal 10 hours * 100 hourly rate');
    }
}