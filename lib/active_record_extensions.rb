module ActiveRecordExtensions
  # allows nested creation data in input form with a 'new_' prefix for all associated objects
  # in model: allow_secondary_creation :speaker
  # in create or update make sure input hash includes a subhash new_speaker => {}
  # ie. you want form fields like "source[new_speaker][name]"
  # Inspired by http://weblog.jamisbuck.org/2007/1/11/moving-associated-creations-to-the-model

  ActiveRecord::Base::ClassMethods.class_eval do
    


  end
end

