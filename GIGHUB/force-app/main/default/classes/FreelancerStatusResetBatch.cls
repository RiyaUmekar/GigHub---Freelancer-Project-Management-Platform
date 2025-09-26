global class FreelancerStatusResetBatch implements Database.Batchable<SObject> {

    // Step 1: Start - find freelancers currently marked "On Project"
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM Free__c 
            WHERE Status__c = 'On Project'
        ]);
    }

    // Step 2: Execute - process each batch of freelancers
    global void execute(Database.BatchableContext bc, List<Free__c> scope) {
        Set<Id> freelancerIds = new Set<Id>();
        for (Free__c f : scope) {
            freelancerIds.add(f.Id);
        }

        // Find which freelancers still have active projects
        List<AggregateResult> activeProjects = [
            SELECT Assigned_Freelancer__c frId, COUNT(Id) cnt
            FROM Project__c
            WHERE Assigned_Freelancer__c IN :freelancerIds
              AND (Status__c != 'Completed' AND End_Date__c >= :System.today())
            GROUP BY Assigned_Freelancer__c
        ];

        Set<Id> activeFreelancers = new Set<Id>();
        for (AggregateResult ar : activeProjects) {
            activeFreelancers.add((Id) ar.get('frId'));
        }

        // Prepare updates
        List<Free__c> toUpdate = new List<Free__c>();
        for (Free__c f : scope) {
            if (!activeFreelancers.contains(f.Id)) {
                f.Status__c = 'Available';
                toUpdate.add(f);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    // Step 3: Finish - optional (e.g., send notification)
    global void finish(Database.BatchableContext bc) {
        System.debug('FreelancerStatusResetBatch completed');
    }
}