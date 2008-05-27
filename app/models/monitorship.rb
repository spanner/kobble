class Monitorship < ActiveRecord::Base
  STDERR.puts "!! loading #{self.to_s}"
  belongs_to :user
  belongs_to :topic
end
