class User < ApplicationRecord
  has_secure_password
  has_many :domains
  has_many :a_records
end
