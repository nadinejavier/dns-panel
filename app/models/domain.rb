class Domain < ApplicationRecord
  belongs_to :user
  has_many :a_records
end
