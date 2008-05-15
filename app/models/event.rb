class Event < ActiveRecord::Base

  belongs_to :account
  belongs_to :collection
  belongs_to :user
  belongs_to :affected, :polymorphic => true

  # just calling affected will return nil for deleted objects even though they're paranoid

  def victim
    affected_type._as_class.find_with_deleted(affected_id)
  end

end

