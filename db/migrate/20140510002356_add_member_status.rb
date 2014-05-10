class AddMemberStatus < ActiveRecord::Migration
  def up
    add_column :leaders, :member_status, :string
  end

  def down
    remove_column :leaders, :member_status
  end
end
