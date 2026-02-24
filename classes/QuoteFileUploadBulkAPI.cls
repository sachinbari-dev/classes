@RestResource(urlMapping='/QuoteFileUpload/')
global with sharing class QuoteFileUploadBulkAPI {


    global class QuoteFileGroup {
        public Id quoteId;
        public List<FileItem> files;
    }

    global class FileItem {
        public List<Id> linkedEntityIds; 
        public String title;
        public String fileName;
        public String format;
        public String base64Data;
        public String contentType;
    }

   
    global class FileResult {
        public Integer groupIndex;           
        public Integer fileIndex;           
        public Id quoteId;                   
        public String status;
        public String message;
        public Id contentDocumentId;
        public Id contentVersionId;
        public List<Id> linkedEntityIdsCreated = new List<Id>();
        public FileResult(Integer g, Integer f){ groupIndex = g; fileIndex = f; }
    }

    @HttpPost
    global static List<FileResult> uploadFilesForQuotes() {
        RestRequest req = RestContext.request;
        List<FileResult> results = new List<FileResult>();

        try {
            QuoteFileGroup[] groups = (QuoteFileGroup[]) JSON.deserialize(req.requestBody.toString(), QuoteFileGroup[].class);
            if (groups == null || groups.size() == 0) {
                FileResult r = new FileResult(-1,-1);
                r.status = 'ERROR';
                r.message = 'Request must be a non-empty JSON array of quote groups.';
                results.add(r);
                return results;
            }

            // Collect provided recordIds
            Set<Id> recordIds = new Set<Id>();
            for (QuoteFileGroup g : groups) if (g != null && g.quoteId != null) recordIds.add(g.quoteId);

            // Query only BVCQuote__c  which match these ids
            Map<Id, BVCQuote__c> validCustomerMap = new Map<Id, BVCQuote__c>();
            if (!recordIds.isEmpty()) {
                for (BVCQuote__c a : [SELECT Id FROM BVCQuote__c WHERE Id IN :recordIds]) {
                    validCustomerMap.put(a.Id, a);
                }
            }

          
            List<ContentVersion> cvsToInsert = new List<ContentVersion>();
            List<Integer> cvToGroupIndex = new List<Integer>();
            List<Integer> cvToFileIndex  = new List<Integer>();

           
            for (Integer gi = 0; gi < groups.size(); gi++) {
                QuoteFileGroup grp = groups[gi];

                // If group is null or has no files -> error for group
                if (grp == null || grp.files == null || grp.files.isEmpty()) {
                    FileResult fr = new FileResult(gi, -1);
                    fr.quoteId = (grp != null) ? grp.quoteId : null;
                    fr.status = 'ERROR';
                    fr.message = 'Group must contain quoteId and a non-empty files array.';
                    results.add(fr);
                    continue;
                }

                // Validate group.quoteId: must exist in Account
                if (grp.quoteId == null || !validCustomerMap.containsKey(grp.quoteId)) {
                    // DO NOT create any files for this group — return error and continue
                    FileResult fr = new FileResult(gi, -1);
                    fr.quoteId = grp.quoteId;
                    fr.status = 'ERROR';
                    fr.message = 'Invalid quoteId: does not belong to a BVCQuote record. No files created for this group.';
                    results.add(fr);
                    continue;
                }

                // For a valid group, process each file
                for (Integer fi = 0; fi < grp.files.size(); fi++) {
                    FileItem fiItem = grp.files[fi];
                    FileResult fr = new FileResult(gi, fi);
                    fr.quoteId = grp.quoteId;

                    if (String.isBlank(fiItem.fileName) || String.isBlank(fiItem.base64Data)) {
                        fr.status = 'ERROR';
                        fr.message = 'fileName and base64Data are required.';
                        results.add(fr);
                        continue;
                    }

                    try {
                        Blob fileBody = EncodingUtil.base64Decode(fiItem.base64Data);
                        ContentVersion cv = new ContentVersion();
                        cv.Title = String.isBlank(fiItem.title) ? fiItem.fileName : fiItem.title;
                        // ensure PathOnClient has file extension if format provided (format should be like '.pdf' or '.jpg')
                        cv.PathOnClient = fiItem.fileName + (String.isBlank(fiItem.format) ? '' : fiItem.format);
                        cv.VersionData = fileBody;
                        cvsToInsert.add(cv);

                        cvToGroupIndex.add(gi);
                        cvToFileIndex.add(fi);

                      
                        results.add(fr);
                    } catch (Exception e) {
                        fr.status = 'ERROR';
                        fr.message = 'Base64 decode failed: ' + e.getMessage();
                        results.add(fr);
                    }
                } // files loop
            } // groups loop

           
            if (!cvsToInsert.isEmpty()) insert cvsToInsert;

            // Build map of inserted ContentVersion (fresh query to get ContentDocumentId)
            Map<Id, ContentVersion> insertedCvMap = new Map<Id, ContentVersion>();
            Set<Id> insertedCvIds = new Set<Id>();
            for (ContentVersion cv : cvsToInsert) insertedCvIds.add(cv.Id);

            if (!insertedCvIds.isEmpty()) {
                for (ContentVersion cv : [SELECT Id, ContentDocumentId, PathOnClient FROM ContentVersion WHERE Id IN :insertedCvIds]) {
                    insertedCvMap.put(cv.Id, cv);
                }
            }

            // Create ContentDocumentLinks for each uploaded file, linking to linkedEntityIds if provided
            
            List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();

            for (Integer idx = 0; idx < cvsToInsert.size(); idx++) {
                ContentVersion insertedCv = cvsToInsert[idx];
                ContentVersion qCv = insertedCvMap.get(insertedCv.Id);
                Integer gi = cvToGroupIndex[idx];
                Integer fi = cvToFileIndex[idx];

                // find corresponding FileResult entry (created earlier)
                FileResult fr = null;
                for (FileResult rf : results) {
                    if (rf.groupIndex == gi && rf.fileIndex == fi) { fr = rf; break; }
                }
                if (fr == null) continue;

                if (qCv == null || qCv.ContentDocumentId == null) {
                    fr.status = 'ERROR';
                    fr.message = 'Could not obtain ContentDocumentId for uploaded file.';
                    continue;
                }

                fr.contentDocumentId = qCv.ContentDocumentId;
                fr.contentVersionId = insertedCv.Id;

                // determine target ids: use file's linkedEntityIds if present; otherwise link to the group's recordId
                
                QuoteFileGroup grp = groups[gi];
                FileItem fitem = grp.files[fi];
                List<Id> targetIds = new List<Id>();
                if (fitem.linkedEntityIds != null && !fitem.linkedEntityIds.isEmpty()) {
                    targetIds.addAll(fitem.linkedEntityIds);
                } else if (grp.quoteId != null) {
                    targetIds.add(grp.quoteId);
                }

                // create ContentDocumentLink entries for every target id
                
                for (Id linkedId : targetIds) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = qCv.ContentDocumentId;
                    cdl.LinkedEntityId = linkedId;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    cdlToInsert.add(cdl);
                }

                // mark pending link status; will finalize after insert
                fr.status = 'LINK_PENDING';
            }

            if (!cdlToInsert.isEmpty()) insert cdlToInsert;

            // populate linkedEntityIdsCreated on results by querying links
            
            Set<Id> docIds = new Set<Id>();
            for (FileResult fr : results) if (fr.contentDocumentId != null) docIds.add(fr.contentDocumentId);

            if (!docIds.isEmpty()) {
                for (ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :docIds]) {
                    for (FileResult fr : results) {
                        if (fr.contentDocumentId != null && fr.contentDocumentId == cdl.ContentDocumentId) {
                            fr.linkedEntityIdsCreated.add(cdl.LinkedEntityId);
                        }
                    }
                }

                // finalize statuses
                for (FileResult fr : results) {
                    if (fr.status == 'LINK_PENDING') {
                        fr.status = 'SUCCESS';
                        fr.message = 'File uploaded and linked successfully.';
                    }
                }
            }

        } catch (Exception ex) {
            // Fatal error for whole request
            
            FileResult fr = new FileResult(-1,-1);
            fr.status = 'ERROR';
            fr.message = 'Fatal error: ' + ex.getMessage();
            results.clear();
            results.add(fr);
        }

        return results;
    }
}