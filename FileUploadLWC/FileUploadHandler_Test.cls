@IsTest
public with sharing class FileUploadHandler_Test {
    @TestSetup
    static void makeData(){
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Test';
        ld.Email = 'test.test@email.com';
        ld.RecordTypeId = Utils.getRecordTypeIdFromDevName('Lead', 'Vertex');
        ld.Company = 'Vertex';
        ld.LeadSource = 'Sourced By BD';
        ld.Lead_Type__c = 'Advertiser';
        insert ld;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Vertex test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ld.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }
    @IsTest static void getFilesByRelatedRecordIdTest(){
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        FileUploadHandler.getFilesByRelatedRecordId(ld.Id);
    }
    @IsTest static void getFilesByDocumentIdsTest(){
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        FileUploadHandler.getFilesByDocumentIds(new List<Id>{document.Id});
    }
    @IsTest static void relateDocumentIdswithRecordsTest(){
        Lead ld = [SELECT Id,LastName,Company,RecordTypeId,Email FROM Lead LIMIT 1];
        lead ld2 = ld.clone(false, false, false, false);
        insert ld2;
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        FileUploadHandler.relateDocumentIdswithRecords(new Map<Id,List<Id>>{ld2.Id=>new List<Id>{document.Id}});
    }
    @IsTest static void deleteFileTest(){
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        FileUploadHandler.deleteFile(document.Id);
    }
}
