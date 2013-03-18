class SorceryCore < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name,             :null => false  # if you use another field as a username, for example email, you can safely remove this field.
      t.string  :email
      t.string  :crypted_password
      t.string  :salt
      t.boolean :admin,            :default => false

      t.timestamps
    end
  end
end
