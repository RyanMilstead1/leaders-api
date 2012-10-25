class Leader < ActiveRecord::Base
  acts_as_content_block
  # attr_accessible :title, :body
  belongs_to :state

  attr_protected :person_id

  scope :state,         where(legislator_type: "SL").order(:last_name)
  scope :state_house,   where(legislator_type: "SL", chamber: "H").order(:last_name)
  scope :state_senate,  where(legislator_type: "SL", chamber: "S").order(:last_name)
  scope :us,            where(legislator_type: "FL").order(:last_name)
  scope :us_house,      where(legislator_type: "FL", chamber: "H").order(:last_name)
  scope :us_senate,     where(legislator_type: "FL", chamber: "S").order(:last_name)

  before_create :generate_slug

  def state_code
    self.state.code.downcase
  end

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
    p = photo_path.split("\\")
    "#{PSP_BASE_URI}/#{p[1].downcase}/#{p[2]}/#{p[3]}/#{p[4]}/#{photo_file}"
  end

  def href
    "#{API_BASE_URI}/states/#{self.state.code.downcase}/leaders/#{slug}"
  end

  def birthday
    if born_on
      born_on.strftime("#B %e")
    end
  end

  def generate_slug
    tmp_slug = prefix_name.parameterize
    count = Leader.where("slug = ? or slug LIKE ?", tmp_slug, "#{tmp_slug}--%").count
    if count < 1
      self.slug = tmp_slug
    else
      self.slug = "#{tmp_slug}--#{count + 1}"
    end
  end
end
