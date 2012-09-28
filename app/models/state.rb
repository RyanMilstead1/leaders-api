class State < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :leaders

  extend FriendlyId                                                                                                             
  friendly_id :code, use: :slugged
end
