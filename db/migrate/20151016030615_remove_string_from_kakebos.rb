class RemoveStringFromKakebos < ActiveRecord::Migration
  def change
    remove_column :kakebos, :string, :string
  end
end
