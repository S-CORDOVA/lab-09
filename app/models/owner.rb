class Owner < ApplicationRecord
  belongs_to :user, optional: true

  has_many :pets

  before_validation :normalize_email

  validates :first_name, :last_name, :phone, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def normalize_email
    self.email = email.strip.downcase if email
  end
end