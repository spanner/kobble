var interface = null;

window.addEvent('domready', function(){
  interface = new Interface();
  interface.activate();
	window.addEvent('scroll', function (e) { interface.moveFixed(e); });
	window.addEvent('resize', function (e) { interface.moveFixed(e); });
});

var Interface = new Class({
	initialize: function(){
    this.dragging = false;
    this.commenting = false;
    this.commentator = new Commentator;
    this.draggables = [];
    this.droppers = [];
    this.tabs = [];
    this.tabsets = {};
    this.fixedbottom = [];
    this.clickthreshold = 6;
    this.cloud = null;
    this.notifyfx = null;
	},
  announce: function (message) {
    if (message) $E('#notification').setText(message);
    this.flashfooter('#695D54');
  },
  complain: function (message) {
    if (message) $E('#notification').setText(message);
    this.flashfooter('#ff0000');
  },
  clearnotification: function () {
    $E('#notification').setText('');
  },
  flash: function (element, color) {
    var bgbackto = element.getStyle('background-color');
    var fgbackto = element.getStyle('color');
    new Fx.Styles(element, {duration:300, wait:false}).start({
  		'background-color': [color || '#cc6e1f', '#ffffff'],
  		'color': ['#ffffff',fgbackto]
    }).chain(function () {
      element.setStyle('background-color', bgbackto)
    });
  },
  flashfooter: function (colour) {
    var footer = $E('#mastfoot');
    var backto = footer.getStyle('background-color');
    if (!this.notifyfx) this.notifyfx = new Fx.Styles($E('#mastfoot'), {duration:2000, wait:false});
    this.notifyfx.start({ 'background-color': [colour,backto] });
  },
  moveFixed: function (e) {
    this.fixedbottom.each(function (element) { element.toBottom(); });
  },
  startDragging: function (element) {
    console.log('startDragging');
    this.commentator.hide();
    $ES('.hideondrag').each(function (element) { element.hide(); })
    $ES('.showondrag').each(function (element) { element.show(); })
    this.tabs.each(function (t) { t.makeReceptiveTo(element); })
    var catchers = [];
  	this.droppers.each(function(d){ if (d.makeReceptiveTo(element)) catchers.push(d.container); });
  	return catchers;        // returns list of elements ready to receive drop, suitable for initializing draggable
  },
  stopDragging: function () {
    console.log('stopDragging');
    this.dragging = false;
    this.tabs.each(function (t) { t.makeUnreceptive(); })
  	this.droppers.each(function (d) { d.makeUnreceptive() })
    $ES('.showondrag').each(function (element) { element.hide(); })
    $ES('.hideondrag').each(function (element) { element.show(); })
  },
  lookForDropper: function (element) {
    if (element) {
    	if (element.dropzone) {
    		return element.dropzone;
    	} else {
      	var p = element.getParent();
    	  if (p && p.getParent) {
    		  return this.lookForDropper( p );
    	  } else {
    		  return null;
    	  }
      }
    }
  },
  
  // useful abstractions used when initialising page and also when making newly created objects active
  
  addTabs: function (elements) {  
    var intf = this; elements.each(function (element) { intf.tabs.push(new Tab(element)); });
  },
  addScratchTabs: function (elements) {
    var intf = this; elements.each(function (element) { intf.tabs.push(new ScratchTab(element)); });
  },
  addDropzones: function (elements) {
    var intf = this; elements.each(function (element) { intf.droppers.push(new Dropzone(element)); });
  },
  addTrashDropzones: function (elements) {
    var intf = this; elements.each(function (element) { intf.droppers.push(new TrashDropzone(element)); });
  },
  makeDraggable: function (elements) {
    var intf = this; elements.each(function (element) { element.addEvent('mousedown', function(event) { intf.dragging = new Draggee(this, event); }); });
  },
  makeExpandable: function (elements) {
    var intf = this; 
    elements.each(function (element) { 
      element.addEvent('mouseenter', function (event) { interface.commentator.explain(element, event); });
      element.addEvent('mouseleave', function (e) { intf.commentator.startDown(); });
    });
  },
  makeFixed: function (elements) {
    var intf = this; elements.each(function (element) { intf.fixedbottom.push(element); });
  },
    
  // this is the main page initialisation routine: it gets called on domready
  
  activate: function (element) {
    var scope = element || $E('body');
	  this.addDropzones($ES('.catcher', scope));
	  this.addTrashDropzones($ES('.trashdrop', scope));
	  this.addTabs($ES('a.tab', scope));
	  this.addScratchTabs($ES('a.padtab', scope));
	  this.makeDraggable($ES('.draggable', scope));
	  this.makeExpandable($ES('.expandable', scope));
	  this.makeFixed($ES('div.fixedbottom', scope));

    $ES('a.autolink', scope).each( function (a) { new AutoLink(a); });
    $ES('a.toggle', scope).each( function (a) { new Toggle(a); });

    $ES('input.cloudcontrol', scope).each( function (element) {
      element.addEvent('click', function (e) {
        var band = element.idparts().id;
        element.checked ? $ES('a.cloud' + band).setStyle('display', 'inline') : $ES('a.cloud' + band).hide();
      })
    });
    // $ES('input.tagbox', scope).each(function (element, i) {
    //  new TagSuggestion(element, '/tags/matching', {
    //    postVar: 'stem',
    //    onRequest: function(el) { element.addClass('waiting'); },
    //    onComplete: function(el) { element.removeClass('waiting'); }
    //  });
    // });
    $ES('a.snipper', scope).each( function (element) {
      element.addEvent('click', function (e) {
        new Snipper(element, e);
      });
    });
  }
});

var Outcome = new Class({
	initialize: function(response){
    var parts = response.split('|');
    this.status = parts[0];
    this.message = parts[1];
    this.consequence = parts[2];
	}
})

var Commentator = new Class({
	initialize: function(){
		this.container = new Element('div', { 'class': 'commentator' }).injectInside(document.body);
		this.textholder = new Element('div', { 'class': 'commentatorbody' }).injectInside(this.container);
		this.footer = new Element('div', { 'class': 'commentatorfoot' }).injectInside(this.container);
		this.container.addEvent('mouseenter', function (e) { interface.commentator.cancelDown(e) });
		this.container.addEvent('mouseleave', function (e) { interface.commentator.startDown(e) });
		this.downTimer = null;
		this.explaining = null;
	},
	explain: function (element, event) {
    this.cancelDown();
    if (! interface.dragging) {
      var position = element.getCoordinates();
      var explanation = $E('div.expansion', element);
      if (explanation) {
        this.explaining = element;
        this.moveto(position.top + 8, position.left + parseInt(position.width / 2));
        this.display(explanation.clone());
        this.show();
      }
    }
	},
	display: function (elements) {
    this.textholder.empty();
    if (elements) elements.injectInside(this.textholder);
	},
	clear: function () {
    this.display();
	},
  moveto: function (top, left) {
    this.container.setStyles({'top': top-23, 'left': left});
  },
  
  // give the mouse time to move into another area that raised the same comment, or over to the commentary itself
  
  startDown: function (event) {
    this.downTimer = window.setTimeout(function () { interface.commentator.hide(); }, 300);
  },
  cancelDown: function (event) {
    if (this.downTimer) window.clearTimeout(this.downTimer);
  },
  show: function () {
    this.container.show();
  },
  hide: function () {
    this.container.hide();
  }
});

