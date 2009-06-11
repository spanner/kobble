module Kobble
  class Response
    attr_accessor :action, :message, :outcome, :object

    # consequence is the interface action to perform on the dragged item
    # should be one of: move, insert, delete. The default is 'insert' 
    # for eg duplicate representation of item on bench

    def initialize(options={})
      @message = options[:message]
      @action = options[:action] || 'insert'
      @outcome = options[:outcome] || 'success'
      @object = options[:object]
    end  

    def to_json 
      {
        :message => self.message.formatted,
        :action => self.action,
        :outcome => self.outcome,
        :object => self.object.simplified
      }.to_json
    end
  end
end