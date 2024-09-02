@IsTest
private class CaseTriggerTest {
    @IsTest
    static void testCaseTrigger() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Case case1 = new Case(AccountId = testAccount.Id, Status = 'Open');
        Case case2 = new Case(AccountId = testAccount.Id, Status = 'New');
        Case case3 = new Case(AccountId = testAccount.Id, Status = 'Closed');
        insert new List<Case>{case1, case2, case3};

        testAccount = [SELECT Number_of_Open_Cases__c, Number_of_Closed_Cases__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(2, testAccount.Number_of_Open_Cases__c, 'Expected 2 open cases');
        System.assertEquals(1, testAccount.Number_of_Closed_Cases__c, 'Expected 1 closed case');

        case3.Status = 'New';
        update case3;

        testAccount = [SELECT Number_of_Open_Cases__c, Number_of_Closed_Cases__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(3, testAccount.Number_of_Open_Cases__c, 'Expected 3 open cases after status change');
        System.assertEquals(0, testAccount.Number_of_Closed_Cases__c, 'Expected 0 closed cases after status change');

        case2.Status = 'Closed';
        update case2;

        testAccount = [SELECT Number_of_Open_Cases__c, Number_of_Closed_Cases__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(2, testAccount.Number_of_Open_Cases__c, 'Expected 2 open cases after another status change');
        System.assertEquals(1, testAccount.Number_of_Closed_Cases__c, 'Expected 1 closed case after another status change');

        delete case1;
        testAccount = [SELECT Number_of_Open_Cases__c, Number_of_Closed_Cases__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(1, testAccount.Number_of_Open_Cases__c, 'Expected 1 open case after deletion');
        System.assertEquals(1, testAccount.Number_of_Closed_Cases__c, 'Expected 1 closed case after deletion');

        undelete case1;
        testAccount = [SELECT Number_of_Open_Cases__c, Number_of_Closed_Cases__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(2, testAccount.Number_of_Open_Cases__c, 'Expected 2 open cases after undelete');
        System.assertEquals(1, testAccount.Number_of_Closed_Cases__c, 'Expected 1 closed case after undelete');
    }
}