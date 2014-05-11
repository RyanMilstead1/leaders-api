require 'csv'
require 'know_who'

namespace :know_who do
  task :download_latest_data do
    `mkdir -p know_who/raw`
    `cd know_who/raw && wget #{ENV['KNOW_WHO_FTP_URL']}/*`
  end

  task :import_states => :environment do
    KnowWho::StateImporter.new.import('spec/fixtures/states.csv')
  end

  task :import_month => :environment do
    month_dir = ENV['KNOW_WHO_MONTH']
    file_list = Dir["#{month_dir}/*.*"]
    KnowWho::LeaderImporter.new.import_files(file_list)
  end

  task :show_import_months => :environment do
    puts Dir['spec/fixtures/leaders/*'].sort
  end
end
