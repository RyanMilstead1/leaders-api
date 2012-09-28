class Leader < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :state
  extend FriendlyId                                                                                                             
  friendly_id :prefix_name, use: :slugged

  attr_protected :person_id

  scope :state,         where(legislator_type: "SL").order(:last_name)
  scope :state_house,   where(legislator_type: "SL", chamber: "H").order(:last_name)
  scope :state_senate,  where(legislator_type: "SL", chamber: "S").order(:last_name)
  scope :us,            where(legislator_type: "FL").order(:last_name)
  scope :us_house,      where(legislator_type: "FL", chamber: "H").order(:last_name)
  scope :us_senate,     where(legislator_type: "FL", chamber: "S").order(:last_name)

  def name
    "#{nick_name} #{last_name}"
  end

  def prefix_name
    if legislator_type == "FL"
     "US #{prefix} #{name}"
    else
     "#{prefix} #{name}"
    end
  end

  def photo_src
    return "http://placehold.it/109x148" if photo_path.blank? or photo_file.blank?
    path = photo_path.split("\\")
    #return "/assets/no_photo.gif" if path.blank? or photo_file.blank?
    "/#{path[1].downcase}/#{path[2]}/#{path[3]}/#{path[4]}/#{photo_file}"
  end

  def birthday
    if born_on
      born_on.strftime("#B %e")
    end
  end
end
