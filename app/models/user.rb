class User < ApplicationRecord
  has_one :owner
  has_one :vet

  enum :role, [:owner, :vet, :admin]

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable

  validates :first_name, :last_name, presence: true
end