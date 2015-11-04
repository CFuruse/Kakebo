class Kakebo < ActiveRecord::Base
  validates :date,       presence: true, length: { maximum: 50 }
  validates :komoku,     presence: true, length: { maximum: 50 }
  validates :shunyu,     presence: true, numericality: {
            only_integer: true, greater_than_or_equal_to: 0
          }
  validates :shishutsu,  presence: true, numericality: {
            only_integer: true, greater_than_or_equal_to: 0
          }
  validates :kind,       presence: true, length: { maximum: 20 }
  validates :scan,       presence: false, length: { maximum: 200 }
end
