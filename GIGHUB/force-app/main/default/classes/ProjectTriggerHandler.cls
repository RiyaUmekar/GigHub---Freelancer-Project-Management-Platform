public class ProjectTriggerHandler {

    public static void handleBeforeInsertUpdate(List<Project__c> newProjects, Map<Id, Project__c> oldMap) {
        if (newProjects == null || newProjects.isEmpty()) return;

        Set<Id> freelancerIds = new Set<Id>();

        // Collect Freelancer IDs
        for (Project__c proj : newProjects) {
            if (proj.Assigned_Freelancer__c != null && proj.Estimated_Hours__c != null) {
                freelancerIds.add(proj.Assigned_Freelancer__c);
            }
        }

        if (freelancerIds.isEmpty()) return;

        // Query Freelancer records (Free__c)
        Map<Id, Free__c> freeMap = new Map<Id, Free__c>(
            [SELECT Id, Hourly_Rate__c FROM Free__c WHERE Id IN :freelancerIds]
        );

        // Calculate Total Cost
        for (Project__c proj : newProjects) {
            if (proj.Assigned_Freelancer__c != null && proj.Estimated_Hours__c != null) {
                Free__c fr = freeMap.get(proj.Assigned_Freelancer__c);
                if (fr != null && fr.Hourly_Rate__c != null) {
                    proj.Total_Cost__c = proj.Estimated_Hours__c * fr.Hourly_Rate__c;
                } else {
                    proj.Total_Cost__c = null;
                }
            }
        }
    }
}