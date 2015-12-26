class AddBikouToKakebos < ActiveRecord::Migration
  def change
    add_column :kakebos, :bikou, :string
  end
end
