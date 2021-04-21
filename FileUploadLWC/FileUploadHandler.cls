public with sharing class FileUploadHandler {
    @AuraEnabled (cacheable=true) 
    public static List<ContentDocument> getFilesByRelatedRecordId(String realtedRecordId){
        if(!ContentDocument.sObjectType.getDescribe().isAccessible()){
            throw new AuraHandledException('Insufficient access to view files');
        } 
        Set<Id> recordIds = new Set<Id>{realtedRecordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                                             ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                            ];                         
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }    
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :documentIds];        
    } 
    
    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){
        if(!ContentDocument.sObjectType.getDescribe().isDeletable()){
            throw new AuraHandledException('Insufficient access to delete files');
        }  
        delete [SELECT Id from ContentDocument WHERE Id = :contentDocumentId];       
    }
    @AuraEnabled
    public static List<ContentDocument> getFilesByDocumentIds(List<Id> documentIds){
        if(!ContentDocument.sObjectType.getDescribe().isAccessible()){
            throw new AuraHandledException('Insufficient access to view files');
        } 
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :documentIds];        
    }
    @AuraEnabled
    public static void relateDocumentIdswithRecords(Map<Id,List<Id>> recordsDocmentIdsMap){
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
        try {
            for(Id recId : recordsDocmentIdsMap.keySet()){
                for(Id docId : recordsDocmentIdsMap.get(recId)){
                    ContentDocumentLink link = new ContentDocumentLink();
                    link.LinkedEntityId = recId;
                    link.ContentDocumentId = docId;
                    link.ShareType = 'I';
                    docLinks.add(link);
                }
            }
            insert docLinks;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
}
