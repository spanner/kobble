var Uploader = new Class ({
  initialize: function(container) {
    this.container = container;
    this.upload_list = container.getElement('div.file_list');
    this.queue = container.getElement('div.upload_queue');
    this.form = container.getElement('form');
    this.tagbox = this.form.getElement('input.tagbox');
    this.occasion = this.form.getElement('select.standard');
    this.collection_select = this.form.getElement('select');
    this.uploads = {};
    
    this.settings = {
      flash_url : "/flash/swfupload.swf",
      upload_url: this.form.get('action'),
      file_size_limit : "200 MB",
      file_types : "*.*",
      file_types_description : "All Files",
      file_upload_limit : 100,
      file_queue_limit : 0,
      debug: false,
      
      button_width: "500",
      button_height: "44",
      button_placeholder_id: 'swf_placeholder',
      // button_image_url: "/images/buttons/uploader.png",
      button_text: '<span class="biggish">* add files to queue</span>',
      button_text_style: ".biggish { font-size: 36px; font-weight: lighter; font-family: Arial, sans-serif; line-height: 1; letter-spacing: -0.05em; color: #5da454; cursor: pointer;}",
      button_cursor: SWFUpload.CURSOR.HAND,
  		
      // The event handler functions
      file_dialog_complete_handler : this.fileDialogComplete.bind(this),
      file_queued_handler : this.fileQueued.bind(this),
      upload_start_handler : this.uploadStart.bind(this),
      queue_complete_handler : this.queueComplete.bind(this),
      upload_progress_handler : this.uploadProgress.bind(this),
      upload_success_handler : this.uploadSuccess.bind(this),
      upload_error_handler: this.uploadError.bind(this),
      
      // SWFObject settings
      minimum_flash_version : "9.0.28",
      swfupload_pre_load_handler : this.swfUploadPreLoad.bind(this),
      swfupload_load_failed_handler : this.swfUploadLoadFailed.bind(this)
    };
    this.swfu = new SWFUpload(this.settings);
  },
  fileDialogComplete : function (selected, queued, total) {
    if (this.collection_select) this.swfu.addPostParam('collection_id', this.collection_select.value);
    this.swfu.startUpload();
  },
  fileQueued : function (file) {
    try {
      this.uploads[file.id] = new Upload(file, this);
    } catch (ex) {
      this.swfu.debug(ex);
    }
  },
  uploadStart : function (file) {
    if (!this.uploads[file.id]) this.uploads[file.id] = new Upload(file, this);
    this.swfu.addFileParam(file.id, 'FileID', this.uploads[file.id].identifier);
    this.swfu.addFileParam(file.id, 'tag_list', this.tagbox.value);
    this.swfu.addFileParam(file.id, 'occasion_id', this.occasion.value);
    this.uploads[file.id].setUploading();
  },
  uploadProgress : function (file, bytesLoaded, bytesTotal) {
    var percent = Math.ceil((bytesLoaded / bytesTotal) * 100);
    var speed = SWFUpload.speed.formatBPS(file.averageSpeed);
    var remaining = SWFUpload.speed.formatTime(file.timeRemaining);
    this.uploads[file.id].setProgress(percent, speed, remaining);
  },
  uploadSuccess : function (file) {
    this.uploads[file.id].setComplete();
  },
  queueError : function (file, errorCode, message) {
    if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
      alert("You have attempted to queue too many files.\n" + (message === 0 ? "You have reached the upload limit." : "You may select " + (message > 1 ? "up to " + message + " files." : "one file.")));
      return;
    }

    var progress = this.uploads[file.id];
    progress.setError();
    progress.toggleCancel(false);

    switch (errorCode) {
    case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
      progress.setStatus("File is too big.");
      this.debug("Error Code: File too big, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
      break;
    case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
      progress.setStatus("Cannot upload Zero Byte files.");
      this.debug("Error Code: Zero byte file, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
      break;
    case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
      progress.setStatus("Invalid File Type.");
      this.debug("Error Code: Invalid File Type, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
      break;
    default:
      if (file !== null) {
        progress.setStatus("Unhandled Error");
      }
      this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
      break;
    }
  },
  uploadError : function (file, errorCode, message) {
    var progress = this.uploads[file.id];
    progress.setError();
    progress.toggleCancel(false);

    switch (errorCode) {
    case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
      progress.setStatus("Upload Error: " + message);
      this.debug("Error Code: HTTP Error, File name: " + file.name + ", Message: " + message);
      break;
    case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
      progress.setStatus("Upload Failed.");
      this.debug("Error Code: Upload Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
      break;
    case SWFUpload.UPLOAD_ERROR.IO_ERROR:
      progress.setStatus("Server (IO) Error");
      this.debug("Error Code: IO Error, File name: " + file.name + ", Message: " + message);
      break;
    case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
      progress.setStatus("Security Error");
      this.debug("Error Code: Security Error, File name: " + file.name + ", Message: " + message);
      break;
    case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
      progress.setStatus("Upload limit exceeded.");
      this.debug("Error Code: Upload Limit Exceeded, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
      break;
    case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED:
      progress.setStatus("Failed Validation.  Upload skipped.");
      this.debug("Error Code: File Validation Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
      break;
    case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
      progress.cancel();
      break;
    case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
      progress.setStatus("Stopped");
      break;
    default:
      progress.setStatus("Unknown Error: " + errorCode);
      this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
      break;
    }
  },
  queueComplete : function () {

  },
  swfUploadPreLoad : function () { },
  swfUploadLoadFailed : function () { },
  
  debug: function (argument) {
    this.swfu.debug(argument);
  }
});

var Upload = new Class ({
  initialize: function(file, uploader) {
    this.file_id = file.id;
    this.file_name = file.name;
    this.identifier = k.uuid();
    this.uploader = uploader;
    this.queue = uploader.queue;
    this.wrapper = new Element('div', {'class' : "progressWrapper", 'id' : this.file_id});
    this.progress = new Element('div', {'class' : "progressContainer"});
    this.bar = new Element('div', {'class' : "progressBar"});
    this.canceller = new Element('a', {'href' : '#', 'class' : "progressCancel", 'style' : 'visibility: hidden;'}).set('text',"x");
    this.file_label = new Element('div', {'class' : "progressName"}).set('text', file.name);
    this.message = new Element('div', {'class' : "progressBarStatus"});
    this.waiter = new Element('img', {'src': '/images/furniture/signals/wait_16_on_pink.gif', "class": 'waiter'});

    this.canceller.inject(this.progress);
    this.waiter.inject(this.file_label, 'top');
    this.message.inject(this.file_label);
    this.file_label.inject(this.progress);
    this.bar.inject(this.progress);
    this.progress.inject(this.wrapper);
    this.wrapper.inject(this.queue);

    this.canceller.addEvent('click', this.cancel.bindWithEvent(this));
    this.height = this.wrapper.getHeight();
    this.setStatus("Queueing...");
    this.toggleCancel(true);
  },
  setStatus: function (status) {
    this.message.set('html', status);
  },
  setColor: function (tocolor) {
    ['green', 'blue', 'red', 'white'].each(function (color) {
      if (color == tocolor) this.progress.addClass(color);
      else this.progress.removeClass(color);
    }.bind(this));
  },
  setWidth: function (width) {
    if (width) {
      if (width < 5) width = 5;
      this.bar.setStyle('width', width + "%");
    } else {
      this.bar.setStyle('width', "");
    }
  },
	setProgress: function (percent, speed, remaining) {
    if (percent > 99) {
    	this.setWidth(100);
      this.setProcessing();
    } else {
    	this.setWidth(percent);
      this.setStatus("Uploading at " + speed + ": " + remaining + " remaining.");
    }
	},
  setWorking: function () {
    this.waiter.show();
  },
  setNotWorking: function () {
    this.waiter.hide();
  },
  setFinishedWorking: function () {
    this.waiter.show();
    this.waiter.set('src', '/images/furniture/buttons/tick/white.png');
  },
  setUploading: function () {
    this.setStatus("Uploading");
    this.setWorking();
  },
  setProcessing: function () {
    this.setStatus("Processing: please wait ");
    this.setWorking();
  },
  setComplete: function (percentage) {
    this.setStatus("Uploaded");
    this.setWidth(100);
    this.setFinishedWorking();
    this.form_holder = new Element('div', {'class' : "fileform"});
    this.form_holder.inject(this.progress);
    this.form_holder.set('load', {onComplete: this.grabDescriptionForm.bind(this)});
    this.form_holder.load('/describer?upload=' + this.identifier);
  },
  setError: function (percentage) {
    this.setColor("red");
    this.setWidth(0);
  },
  setCancelled: function (percentage) {
    this.setColor('white');
    this.setWidth(0);
  },
  
  toggleCancel: function (show, swfUploadInstance) {
    this.canceller.setStyle('visibility', show ? "visible" : "hidden");
  },
  cancel: function (e, but_stay) {
    this.uploader.swfu.cancelUpload(this.file_id);
    this.setCancelled();
  },
  grabDescriptionForm: function () {
    this.description_form = this.form_holder.getElement('form');
    this.description_form.getElements('input.tagbox').each(function (el) { new Suggester(el); });
    this.description_form.addEvent('submit', this.sendDescriptionForm.bind(this));
  },
  sendDescriptionForm: function (e) {
    event = k.block(e);
    var button = this.description_form.getElement('input.submit');
    var spinner = new Element('img', {src: '/images/furniture/signals/wait_32_on_pink.gif', 'class': 'waiter'});
    spinner.replaces(button);
    this.progress.set('load', {method : 'post', url : this.description_form.action, onComplete : this.finished.bind(this)});
    this.progress.get('load').post(this.description_form);
  },
  finished: function () {
    this.wrapper.addClass('progressFinished');
  }
});

kobble_starters.push(function (scope) {
  if (!scope) scope = document;
  scope.getElementsIncludingSelf('div.uploader').each( function (el) { new Uploader(el); });
});

