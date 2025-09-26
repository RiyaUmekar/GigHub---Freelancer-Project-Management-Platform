@isTest
private class FreelancerStatusResetBatchTest {

    // Test the batch process
    @isTest
    static void testBatchResetsStatus() {
        // Create a freelancer currently marked as "On Project"
        Free__c f1 = new Free__c(
            Name = 'Freelancer 1',
            Hourly_Rate__c = 100,
            Status__c = 'On Project'
        );
        insert f1;

        // Create a completed project that ended yesterday
        Project__c p = new Project__c(
            Name = 'Ended Project',
            Assigned_Freelancer__c = f1.Id,
            Status__c = 'Completed',
            End_Date__c = System.today().addDays(-1),
            Estimated_Hours__c = 5
        );
        insert p;

        // Run the batch
        Test.startTest();
            Database.executeBatch(new FreelancerStatusResetBatch(), 100);
        Test.stopTest();

        // Verify freelancer status is reset to "Available"
        f1 = [SELECT Status__c FROM Free__c WHERE Id = :f1.Id];
        System.assertEquals('Available', f1.Status__c, 'Freelancer should be reset');
    }

    // Test the scheduler
    @isTest
    static void testSchedulerRunsBatch() {
        Test.startTest();
            // Schedule the job (in test, it runs when Test.stopTest is called)
            String cron = '0 0 2 * * ?'; // every day at 2 AM
            System.schedule('Test Reset Job', cron, new FreelancerStatusResetScheduler());
        Test.stopTest();

        // Verify that a scheduled job exists
        System.assertEquals(1,
            [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = 'Test Reset Job'],
            'Scheduler should have created a job');
    }
}