class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :slug

      t.string :name
      t.string :code
      t.string :region
      t.boolean :is_state, default: true
      t.integer :pointer_zero, default: 0
      t.integer :pointer_one, default: 0
      t.integer :pointer_two, default: 1
      t.date :last_incremented_on, null: false, default: Date.today
      t.integer :daily_segment_id
      t.integer :weekly_segment_id

      t.timestamps
    end

    add_index :states, :slug, unique: true
  end
end
