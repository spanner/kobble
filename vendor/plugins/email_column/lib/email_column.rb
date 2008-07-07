module EmailColumn
  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  def self.valid?(email, allow_blank=false)
    return allow_blank if not email or email.strip == ''
    begin
      TMail::Address.parse(email)
    rescue TMail::SyntaxError
      return true
    end
    email =~ /@.+\./
  end
  
  module ClassMethods
    def email_column(name, options={})
      options = {:validate_if => proc{true}}.update(options)
      validate do |record|
        record.errors.add name, "doesn't look like an email address" if options[:validate_if][record] and !EmailColumn.valid?(record.send(name), options[:allow_blank])
      end
      
      before_save do |record|
        record[name].downcase! if record[name]
      end
    end
  end
end
