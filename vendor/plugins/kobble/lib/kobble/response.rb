module Kobble
  class Response
    attr_accessor :consequence, :message, :outcome

    # consequence is the interface action to perform on the dragged item
    # should be one of: move, insert, delete. The default is 'insert' 
    # for eg duplicate representation of item on scratchpad

    def initialize(m=nil, c=nil, o=nil)
      @message = m
      @consequence = c
      @outcome = o
    end  

    def to_json 
      {
        :message => self.message.formatted,
        :consequence => self.consequence || 'insert',
        :outcome => self.outcome || 'success',
      }.to_json
    end
  end
end