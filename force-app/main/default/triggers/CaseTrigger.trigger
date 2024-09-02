trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        Set<Id> accountIds = new Set<Id>();
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            for (Case caseItem : Trigger.new) {
                if (String.isNotBlank(caseItem.AccountId)) {
                    accountIds.add(caseItem.AccountId);
                }
            }
        }

        if (Trigger.isUpdate || Trigger.isDelete) {
            for (Case caseItem : Trigger.old) {
                if (String.isNotBlank(caseItem.AccountId)) {
                    accountIds.add(caseItem.AccountId);
                }
            }
        }

        if (!accountIds.isEmpty()) {
            CaseTriggerHandler.updateCaseCounts(accountIds);
        }
    }
}