class Source < ActiveRecord::Base

  acts_as_spoke

  belongs_to :occasion
  has_many :nodes, :dependent => :destroy

  file_column :file
  before_save FileCallbacks.new  

  def self.nice_title
    "source"
  end

  def catch_this(object)
    case object.class.to_s
    when 'Tag'
      return object.catch_this(self)
    when 'Flag'
      return object.catch_this(self)
    else
      return CatchResponse.new("don't know what to do with a #{object.nice_title}", '', 'failure')
    end
  end

end
