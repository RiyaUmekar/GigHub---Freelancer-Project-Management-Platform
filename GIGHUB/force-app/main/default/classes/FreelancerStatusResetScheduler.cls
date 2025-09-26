global class FreelancerStatusResetScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new FreelancerStatusResetBatch(), 200);
    }
}