class Vet < ApplicationRecord
  belongs_to :user, optional: true

  has_many :appointments

  before_validation :normalize_email

  validates :first_name, :last_name, :specialization, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :by_specialization, ->(specialization) { where(specialization: specialization) }

  def normalize_email
    self.email = email.strip.downcase if email
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end