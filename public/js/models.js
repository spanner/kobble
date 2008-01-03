var Model = new Class({
	initialize: function(object){
    var properties = {};
	},
  to_json: function(){
    this.tabbody.hide();
    this.tabhead.removeClass('fg');
  },
  as_li: function () {

  },
  as_thumb: function () {

  }
});

var Node = Model.extend({ });
var Source = Model.extend({ });
var Bundle = Model.extend({ });
var Tag = Model.extend({ });
var Flag = Model.extend({ });
var User = Model.extend({ });
var Post = Model.extend({ });
