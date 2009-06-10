var InlineLink = new Class({
  initialize: function (a) {
    this.link = a;
    this.link.onclick = this.send.bind(this);
  },
  method: function () {
    return 'GET';
  },
  send: function (e) {
    var event = k.block(e);
    this.link.blur();
    new Request.JSON({
      url: al.link.getProperty('href'),
      method: this.method(),
      onRequest: this.waiting.bind(this),
      onComplete: this.finished.bind(this),
      onFailure: this.failed.bind(this)
    }).send();
  },
  waiting: function () { this.link.addClass('waiting'); },
  notWaiting: function () { this.link.removeClass('waiting'); },
  finished: function (response) {
    this.notWaiting();
    k.announce(response.message);
  },
  failed: function (response) {
    this.notWaiting();
    k.complain(response.message);
  }
});

var Toggle = new Class({
  Extends: InlineLink,
  // method: function () {
  //   return this.ticked() ? 'DELETE' : 'POST';
  // },
  finished: function (response) {
    this.notWaiting();
    if (response.outcome == 'failure') {
      k.complain(response.message);
      
    } else if (response.outcome == 'active') {
      this.link.addClass('ticked');
      this.link.removeClass('crossed');
      k.announce(response.message);
      
    } else {
      this.link.removeClass('ticked');
      this.link.addClass('crossed');
      k.announce(response.message);
    }
  },
  ticked: function () {
    return this.link.hasClass('ticked');
  }
});
