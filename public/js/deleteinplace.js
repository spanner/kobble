var Deleter = new Class({
  
  initialize: function (a, e) {
    this.link = a;
    this.signal = $E('img', a);
    this.subject = $E('#' + a.id.replace('delete_',''));
    this.fader = new Fx.Styles(this.subject, {'duration': 400});
    this.req = null;
    this.waiting();
    if (this.confirm()) {
      this.delete();
    } else {
      this.notWaiting();
    }
  },

  request_url: function () {
    return this.link.getProperty('href');
  },
  
  title: function (argument) {
    return this.link.getProperty('title');
  },

  confirm: function () {
    // console.log('confirm');
    return confirm("are you sure you want to " + this.title() + '?');
  },
  
  delete: function () {
    del = this;
		this.req = new Ajax(this.request_url(), {
			method: 'post',
		  onRequest: function () {del.waiting();},
		  onComplete: function () {del.finished();},
		  onFailure: function () {del.failed();}
		}).request();
  }, 
  
  waiting: function () {
    if (this.link.hasClass('removeitem')) {
      this.link.addClass('waiting');
    } else {
      $E('img', this.link).setProperty('src', '/images/furniture/signals/wait_16_grey.gif');
    }
  },
  
  notWaiting: function () {
    if (this.link.hasClass('removeitem')) {
      this.link.removeClass('waiting');
    } else {
      $E('img', this.link).setProperty('src', '/images/furniture/buttons/cross.png');
    }
  },
  
  finished: function (argument) {
    // console.log('finished!');
    this.fader.start({
      'opacity': 0,
      'height': 0
    }).chain(function () { this.element.remove() })
  },
  
  failed: function (argument) {
    this.notWaiting();
    alert('deletion failed');
  }
  
});
