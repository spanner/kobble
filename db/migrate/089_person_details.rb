class PersonDetails < ActiveRecord::Migration

  def self.up
    add_column :people, :email, :string
    add_column :people, :address, :text
    add_column :people, :postcode, :string
    add_column :people, :phone, :string
    add_column :people, :honorific, :string
    add_column :people, :workplace, :string
    add_column :people, :role, :string
  end

  def self.down
    remove_column :people, :email
    remove_column :people, :address
    remove_column :people, :postcode
    remove_column :people, :phone
    remove_column :people, :honorific
    remove_column :people, :workplace
    remove_column :people, :role
  end
end
