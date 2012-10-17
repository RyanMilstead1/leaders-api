require 'csv'

namespace :know_who do
  task :download_latest_data do
    `mkdir -p know_who/raw`
    `cd know_who/raw && wget ftp://ftp_capitolcomm:ktr84sbe@205.134.170.180/* `
    #`cd know_who/raw && unzip \*.zip`
  end

  task :import => :environment do
    Rake::Task["know_who:setup_files"].execute
    Rake::Task["know_who:import_states"].execute
    Rake::Task["know_who:import_leaders"].execute
    #Rake::Task["know_who:import_bio_records"].execute
  end

  task :delete_states => :environment do
    puts "removing old state data"
    count = State.delete_all
    puts "removed #{count} state records"
  end

  task :delete_leaders => :environment do
    puts "removing old leader data"
    count = Leader.delete_all
    puts "removed #{count} leader records"
  end

  task :import_states => :environment do
    puts "importing new state records"
    states = CSV.table("know_who/states.csv")
    states.each do |state|
      s = State.new
      s.code = state[:statepostcode]
      s.name = state[:statename]
      if %w( ME NH VT MA RI CT NY PA NJ ).include? s.code
        s.region = "NE"
      elsif %w( WI MI IL IN OH MO ND SD NE KS MN IA ).include? s.code
        s.region = "MW"
      elsif %w( DE MD DC VA WV NC SC GA FL KY TN MS AL OK TX AR LA ).include? s.code
        s.region = "S"
      elsif %w( ID MT WY NV UT CO OR AZ NM AK WA CA HI ).include? s.code
        s.region = "W"
      end
      if State.us_codes.include?(s.code)
        s.is_state = true
        puts "Added state #{state[:statepostcode]} - #{state[:statename]}"
      else
        s.is_state = false
        puts "Added non-state #{state[:statepostcode]} - #{state[:statename]}"
      end
      s.save!
    end
  end

  task :import_leaders => :environment do
    Rake::Task["know_who:import_federal_leaders"].execute
    Rake::Task["know_who:import_state_leaders"].execute
  end

  task :import_federal_leaders => :environment do
    puts "importing federal leaders records"
    CSV.foreach("know_who/federal_members.csv", headers: true, header_converters: :symbol) do |member|
      leader = KnowWhoImporter.create_or_update(member)
      puts "Imported #{leader.prefix_name}"
    end
  end

  task :import_state_leaders => :environment do
    puts "importing state leader records"
    CSV.foreach("know_who/state_members.csv", headers: true, header_converters: :symbol) do |member|
      leader = KnowWhoImporter.create_or_update(member)
      puts "Imported #{leader.prefix_name}"
    end
  end


  task :import_bios => :environment do
    begin
      CSV.foreach("know_who/Biographies.utf8.csv", headers: true, header_converters: :symbol) do |bio|
        #member = Member.first(conditions: { person_id: bio[:pid] })
        #member.update_attributes(
        #  biography: bio[:document],
        #  biography_updated_on: bio[:biodate],
        #)
        print "."
        #puts "Updated bio for #{member.name}"
        #sleep 3
        @bio = bio
      end
    rescue
      puts "Error on bio for #{@bio[:pid]}"
    end 
  end

  task :setup_files => :environment do
    Rake::Task["know_who:delete_files"].execute
    Rake::Task["know_who:copy_files"].execute
    Rake::Task["know_who:iconv_files"].execute
    #Rake::Task["know_who:dos2unix_files"].execute
  end

  task :delete_files => :environment do
    puts "deleting files"
    `rm know_who/states.csv`
    `rm know_who/state_members.csv`
    `rm know_who/federal_members.csv`
  end

  task :copy_files => :environment do
    puts "copying files"
    `cp know_who/raw/State/States.csv know_who/states.csv`
    `cp know_who/raw/State/Members.csv know_who/state_members.csv`
    `cp know_who/raw/Federal/Members.csv know_who/federal_members.csv`
  end

  task :iconv_files => :environment do
    puts "converting to UTF8"
    ['states.csv', 'state_members.csv', 'federal_members.csv'].each do |file|
      `mv know_who/#{file} know_who/_#{file}`
      `iconv --verbose -c --to-code UTF8//TRANSLIT --output know_who/#{file} know_who/_#{file}`
      `rm know_who/_#{file}`
    end
  end

  task :dos2unix_files => :environment do
    puts "converting from dos to unix"
    `dos2unix know_who/*.csv`
  end

end
