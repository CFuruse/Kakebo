class User < ActiveRecord::Base
#  before_save { self.email = email.downcase }
  before_create :create_remeber_token
  validates :name,  presence: true, length: { maximum: 50 }
#  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
#  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
#                    uniqueness: true
  has_secure_password
  validates :password, length: { minimum: 6 }

  def User.new_remeber_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remeber_token
      self.remeber_token = User.encrypt(User.new_remeber_token)
    end

end
