require 'spec_helper'

describe 'Import all leaders' do
  before :all do
    KnowWho::StateImporter.new.import('spec/fixtures/states.csv')
  end

  let(:import_months) { Dir['spec/fixtures/leaders/*'].sort }
  let(:import_100_months) { Dir['spec/fixtures/leaders_100/*'].sort }

  def files_for_month(month_dir)
    Dir["#{month_dir}/*.*"]
  end

  it 'imports all leaders from scratch' do
    list_of_files = files_for_month(import_months.first)
    KnowWho::LeaderImporter.new.import_files(list_of_files)

    Leader.count.should == 9330
  end

  it 'imports leaders (truncated to 100) from scratch' do
    import_100_months.each do |month|
      list_of_files = files_for_month(month)
      KnowWho::LeaderImporter.new.import_files(list_of_files)
    end

    Leader.where({member_status: 'former'}).count.should == 847
    Leader.where({member_status: 'current'}).count.should == 200
  end

  it 'has 101 lines in each truncated file' do
    Dir['spec/fixtures/leaders_100/**/*.*'].each do |file|
      `wc -l #{file}`.split.first.should == '101'
    end
  end
end
