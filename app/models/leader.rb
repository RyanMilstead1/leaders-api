class Leader < ActiveRecord::Base
  belongs_to :state

  attr_protected :person_id

  scope :state,         where(legislator_type: "SL").order(:last_name)
  scope :state_house,   where(legislator_type: "SL", chamber: "H").order(:last_name)
  scope :state_senate,  where(legislator_type: "SL", chamber: "S").order(:last_name)
  scope :us,            where(legislator_type: "FL").order(:last_name)
  scope :us_house,      where(legislator_type: "FL", chamber: "H").order(:last_name)
  scope :us_senate,     where(legislator_type: "FL", chamber: "S").order(:last_name)

  before_create :generate_slug

  def self.create_or_update(data)
    leader = Leader.find_or_create_by_person_id(data[:pid])
    update_attributes_from_know_who(leader, data)
    ensure_correct_state(leader, data)
    leader.tap { |l| l.save! }
  end

  def self.ensure_correct_state(leader, data)
    state = State.find_by_code!(data[:statecode])
    if leader.state
      unless leader.state.code == state.code
        raise "Know Who data tried to change leader state"
      end
    else
      leader.state = state
    end
  end

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

  private

  def self.update_attributes_from_know_who(leader, data)
    leader.born_on = birthday(data)
    leader.person_id = data[:pid]
    leader.legislator_type = data[:legtype]
    leader.title = data[:title]
    leader.prefix = data[:prefix]
    leader.first_name = data[:firstname]
    leader.last_name = data[:lastname]
    leader.mid_name = data[:midname]
    leader.nick_name = data[:nickname]
    leader.legal_name = data[:legalname]
    leader.party_code = data[:partycode]
    leader.district = data[:district]
    leader.district_id = data[:districtid]
    leader.family = data[:family]
    leader.religion = data[:religion]
    leader.email = data[:email]
    leader.website = data[:website]
    leader.webform = data[:webform]
    leader.weblog = data[:weblog]
    leader.blog = data[:weblog]
    leader.facebook = data[:facebook]
    leader.twitter = data[:twitter]
    leader.youtube = data[:youtube]
    leader.photo_path = data[:photopath]
    leader.photo_file = data[:photofile]
    leader.chamber = data[:chamber]
    leader.gender = data[:gender]
    leader.party_code = data[:partycode]
    leader.birth_place = data[:birthplace]
    leader.spouse = data[:spouse]
    leader.marital_status = data[:marital]
    leader.residence = data[:residence]
    leader.school_1_name = data[:school1]
    leader.school_1_date = data[:edudate1]
    leader.school_1_degree = data[:degree1]
    leader.school_2_name = data[:school2]
    leader.school_2_date = data[:edudate2]
    leader.school_2_degree = data[:degree2]
    leader.school_3_name = data[:school3]
    leader.school_3_date = data[:edudate3]
    leader.school_3_degree = data[:degree3]
    leader.military_1_branch = data[:milbranch1]
    leader.military_1_rank = data[:milrank1]
    leader.military_1_dates = data[:mildates1]
    leader.military_2_branch = data[:milbranch2]
    leader.military_2_rank = data[:milrank2]
    leader.military_2_dates = data[:mildates2]
    leader.mail_name = data[:mailname]
    leader.mail_title = data[:mailtitle]
    leader.mail_address_1 = data[:mailaddr1]
    leader.mail_address_2 = data[:mailaddr2]
    leader.mail_address_3 = data[:mailaddr3]
    leader.mail_address_4 = data[:mailaddr4]
    leader.mail_address_5 = data[:mailaddr5]
  end

  def self.birthday(data)
    unless data[:birthyear].blank? or 
           data[:birthmonth].blank? or 
           data[:birthdate].blank?
      Date.new(data[:birthyear].to_i, 
               data[:birthmonth].to_i, 
               data[:birthdate].to_i)
    else
      nil
    end
  end

end
