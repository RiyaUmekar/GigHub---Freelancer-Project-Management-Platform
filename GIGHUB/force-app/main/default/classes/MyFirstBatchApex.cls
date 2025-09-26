public class MyFirstBatchApex implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Phone FROM Account WHERE CreatedDate = LAST_N_DAYS:30'
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> accList) {
        for (Account a : accList) {
            a.Name = a.Name + ' updated';
        }
        update accList;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('This batch apex has been run');
    }
}