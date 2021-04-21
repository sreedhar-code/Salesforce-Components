import { LightningElement,api,track,wire } from 'lwc';
import getFilesByRelatedRecordId from '@salesforce/apex/FileUploadHandler.getFilesByRelatedRecordId';
import getFilesByDocumentIds from '@salesforce/apex/FileUploadHandler.getFilesByDocumentIds';
import deleteFile from '@salesforce/apex/FileUploadHandler.deleteFile';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
export default class FileUploadLwc extends NavigationMixin(LightningElement) {
	//Label of the component
	@api label = 'Files';
	//do you want show delete file option
	@api deleteOption = false;
	//do you want show upload file option
	@api uploadOption = false;
	// Id of the record with which you want to associate/get the files
	@api relatedRecordId;
	//type of files allowed to upload
	@api acceptedFormats = ['.pdf', '.png', '.jpg'];
    @track files=[];
	@track _tempData;
	documentIds = [];
	showSpinner=false;

	//this is meant when related record id is provided
	@wire(getFilesByRelatedRecordId,{realtedRecordId:'$relatedRecordId'})
    getFiles(result){
        this._tempData = result;
        if(result.data){
			this.files = result.data;
			this.notifyDocumentChange();
        }else if(result.error){
            console.error('Error in feteching files for the record '+this.recordId+ ': '+JSON.stringify(result.error));
        }
    }

    handleUploadFinished(event) {
		let filesList = event.detail.files;
		for(let file of filesList){
			this.documentIds.push(file.documentId);
		}
		if(this.relatedRecordId){
			refreshApex(this._tempData);
		}else{
			this.getFileList();
		}
    }

    deleteSelectedFile(event){
		this.showSpinner = true;
		let fileIdToDelete = event.target.accessKey;
        deleteFile({contentDocumentId:event.target.accessKey})
        .then(result=>{
			this.documentIds = this.documentIds.filter(item=>item!=fileIdToDelete);
			if(this.relatedRecordId){
				refreshApex(this._tempData);
			}else{
				this.getFileList();
			}
            this.showSpinner = false;
        })
        .catch(error=>{
            this.showSpinner = false;
        });
        console.log('delete file : '+event.target.accessKey);
    }

    previewFile(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: event.target.accessKey,
                selectedRecordId:event.target.accessKey
            }
          })
	}
	// this executed when no related record id provided
    getFileList(){
		this.showSpinner=true;
		if(this.documentIds.length==0){
			this.files=[];
			this.notifyDocumentChange();
			return;
		}
		getFilesByDocumentIds({documentIds:this.documentIds})
		.then(result=>{
			this.files = result;
			this.showSpinner=false;
			this.notifyDocumentChange();
		})
		.catch(error=>{
			this.showSpinner=false;
			console.error('Error in feteching files for the record '+this.recordId+ ': '+JSON.stringify(error));
		});
	}
	//call this method to get list of files inserted when no realted record id provided
	// @api getInsertedDocumentIds(){
	// 	return this.documentIds;
	// }
	notifyDocumentChange(){
		console.log(JSON.stringify(this.files));
		let docIds = [];
		let fileList =JSON.parse(JSON.stringify(this.files)); 
		fileList.forEach(file=>docIds.push(file.Id));
		let docChangeEvnt = new CustomEvent('documentschange',{detail:docIds.join(',')});
		this.dispatchEvent(docChangeEvnt);
	}
    get displaySpinner(){
        return this.showSpinner ||  (!this._tempData.data && !this._tempData.error && this.relatedRecordId);
    }
}