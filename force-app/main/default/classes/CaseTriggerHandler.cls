public class CaseTriggerHandler {
    private static final String CASE_STATUS_CLOSED = 'Closed';

    public static void updateCaseCounts(Set<Id> accountIds) {
        Map<Id, Integer> openCaseCountMap = new Map<Id, Integer>();
        Map<Id, Integer> closedCaseCountMap = new Map<Id, Integer>();

        for (AggregateResult result : [
            SELECT
                AccountId,
                Status,
                COUNT(Id) cnt
            FROM Case
            WHERE AccountId IN :accountIds
            GROUP BY AccountId, Status
        ]) {
            Id accountId = (Id)result.get('AccountId');
            String status = (String)result.get('Status');
            Integer count = (Integer)result.get('cnt');

            if (status == CASE_STATUS_CLOSED) {
                closedCaseCountMap.put(accountId, count);
            } else {
                Integer currentOpenCount = openCaseCountMap.containsKey(accountId) ? openCaseCountMap.get(accountId) : 0;
                openCaseCountMap.put(accountId, currentOpenCount + count);
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        List<Account> existingAccounts = [
            SELECT
                Id,
                Number_of_Closed_Cases__c,
                Number_of_Open_Cases__c
            FROM Account
            WHERE Id IN :accountIds
        ];

        for (Account acc : existingAccounts) {
            Integer openCount = openCaseCountMap.containsKey(acc.Id) ? openCaseCountMap.get(acc.Id) : 0;
            Integer closeCount = closedCaseCountMap.containsKey(acc.Id) ? closedCaseCountMap.get(acc.Id) : 0;

            if (acc.Number_of_Closed_Cases__c != closeCount || acc.Number_of_Open_Cases__c != openCount) {
                acc.Number_of_Open_Cases__c = openCount;
                acc.Number_of_Closed_Cases__c = closeCount;
                accountsToUpdate.add(acc);
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}