class CreateStates < ActiveRecord::Migration
  def change
    Cms::ContentType.create!(:name => "State", :group_name => "Government")
    create_content_table :states, :prefix=>false do |t|
      t.string :name
      t.string :code
      t.string :region
      t.boolean :is_state, default: true

      t.timestamps
    end
  end
end
