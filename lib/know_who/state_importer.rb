require 'csv'

module KnowWho
  class StateImporter
    def import(csv_file)
      puts "importing new state records"
      states = CSV.table(csv_file)
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
  end
end
