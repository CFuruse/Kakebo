class CreateKakebos < ActiveRecord::Migration
  def change
    create_table :kakebos do |t|
      t.date :date
      t.string :komoku
      t.integer :shunyu
      t.integer :shishutsu
      t.string :kind
      t.string :scan
      t.string :string

      t.timestamps
    end
  end
end
