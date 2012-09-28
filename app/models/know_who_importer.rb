class KnowWhoImporter
  attr_accessor :state, :leader
  
  def self.create_or_update(know_who_data)
    import = KnowWhoImporter.new(know_who_data)

    if import.leader_exists?
      import.leader = Leader.find_by_person_id(know_who_data[:pid])
      if import.leader.state.code != import.state.code
        raise "Know Who data tried to change leader state"
      end
    else
      import.leader = import.state.leaders.create
      import.leader.update_attribute(:person_id, know_who_data[:pid])
    end
    import.update_attributes_from_know_who
    import.leader
  end

  def initialize(know_who_data)
    @know_who_data = know_who_data
    @state = State.find_by_code(data[:statecode])
    unless @state 
      puts "the following state could not be found:"
      puts data[:statecode]
      raise "Know Who data state not found"
    end
  end

  def data
    @know_who_data
  end

  def leader_exists?
    Leader.where(person_id: data[:pid]).exists?
  end

  # From the Know Who DB
  def legacy_fields
    ["UID","PID","LEGTYPE","CHAMBER","CHAMBERANK","STATECODE","STATE","DISTRICT","DISTRAIL","DISTYPE","PARTYRANK","PERCENTVOT","ELECTDATE","REELECTYR","ELECTCODE","FECLINK","PYRACUSC","CYRACUSC","PYRADASC","CYRADASC","PYRAFLSC","CYRAFLSC","PYRUSCOSC","CYRUSCOSC","SEATSTCODE","SEATSTAT","DISTRICTID","SEATID","PARTYCODE","FIRSTNAME","LASTNAME","MIDNAME","NICKNAME","PREFIX","GENSUFFIX","TITLE","PROFSUFFIX","GENDER","LEGALNAME","PRONUNCTON","BIRTHPLACE","BIRTHYEAR","BIRTHMONTH","BIRTHDATE","MARITAL","SPOUSE","RESIDENCE","FAMILY","RELIGCODE","RELIGION","ETHCODE","ETHNICS","REOFC1","REOFC1DATE","REOFC2","REOFC2DATE","RECOCCODE1","RECENTOCC1","RECOCCODE2","RECENTOCC2","SCHOOL1","DEGREE1","EDUDATE1","SCHOOL2","DEGREE2","EDUDATE2","SCHOOL3","DEGREE3","EDUDATE3","MILBRANCH1","MILRANK1","MILDATES1","MILBRANCH2","MILRANK2","MILDATES2","MAILNAME","MAILTITLE","MAILADDR1","MAILADDR2","MAILADDR3","MAILADDR4","MAILADDR5","EMAIL","WEBFORM","WEBSITE","WEBLOG","FACEBOOK","TWITTER","YOUTUBE","PHOTOPATH","PHOTOFILE"]
  end


  def update_attributes_from_know_who
    unless data[:birthyear].blank? or data[:birthmonth].blank? or data[:birthday].blank?
      birthday = Date.new(date[:birthyear].to_i, data[:birthmonth].to_i, data[:birthday].to_i)
    else
      birthday = nil
    end
    @leader.born_on = birthday
    @leader.legislator_type = data[:legtype]
    @leader.title = data[:title]
    @leader.prefix = data[:prefix]
    @leader.first_name = data[:firstname]
    @leader.last_name = data[:lastname]
    @leader.mid_name = data[:midname]
    @leader.nick_name = data[:nickname]
    @leader.legal_name = data[:legalname]
    @leader.party_code = data[:partycode]
    @leader.district = data[:district]
    @leader.district_id = data[:districtid]
    @leader.family = data[:family]
    @leader.religion = data[:religion]
    @leader.email = data[:email]
    @leader.website = data[:website]
    @leader.webform = data[:webform]
    @leader.weblog = data[:weblog]
    @leader.blog = data[:weblog]
    @leader.facebook = data[:facebook]
    @leader.twitter = data[:twitter]
    @leader.youtube = data[:youtube]
    @leader.photo_path = data[:photopath]
    @leader.photo_file = data[:photofile]
    @leader.chamber = data[:chamber]
    @leader.gender = data[:gender]
    @leader.party_code = data[:partycode]
    @leader.birth_place = data[:birthplace]
    @leader.spouse = data[:spouse]
    @leader.marital_status = data[:marital]
    @leader.residence = data[:residence]
    @leader.school_1_name = data[:school1]
    @leader.school_1_date = data[:edudate1]
    @leader.school_1_degree = data[:degree1]
    @leader.school_2_name = data[:school2]
    @leader.school_2_date = data[:edudate2]
    @leader.school_2_degree = data[:degree2]
    @leader.school_3_name = data[:school3]
    @leader.school_3_date = data[:edudate3]
    @leader.school_3_degree = data[:degree3]
    @leader.military_1_branch = data[:milbranch1]
    @leader.military_1_rank = data[:milrank1]
    @leader.military_1_dates = data[:mildates1]
    @leader.military_2_branch = data[:milbranch2]
    @leader.military_2_rank = data[:milrank2]
    @leader.military_2_dates = data[:mildates2]
    @leader.mail_name = data[:mailname]
    @leader.mail_title = data[:mailtitle]
    @leader.mail_address_1 = data[:mailaddr1]
    @leader.mail_address_2 = data[:mailaddr2]
    @leader.mail_address_3 = data[:mailaddr3]
    @leader.mail_address_4 = data[:mailaddr4]
    @leader.mail_address_5 = data[:mailaddr5]
    @leader.save!
  end
end
