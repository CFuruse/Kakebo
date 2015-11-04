class RemoveScanfileFromKakebos < ActiveRecord::Migration
  def change
    remove_column :kakebos, :scanfile, :binary
  end
end
