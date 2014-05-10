class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :name
      t.string :code
      t.string :region
      t.boolean :is_state, default: true

      t.timestamps
    end
  end
end
