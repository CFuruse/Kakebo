class AddScanfileToKakebos < ActiveRecord::Migration
  def change
    add_column :kakebos, :scanfile, :binary
  end
end
