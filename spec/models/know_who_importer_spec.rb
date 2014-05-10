require 'spec_helper'

describe KnowWhoImporter do
  let :know_who_data do
    { pid: "1234567", statecode: "TX" }
  end

  before do
    State.delete_all
    Leader.delete_all
  end

  let!(:texas) { FactoryGirl.create(:state, code: "TX") }

  let(:importer) { KnowWhoImporter.new }

  context "#begin_import" do
    it "set all leaders to pending" do
      10.times { FactoryGirl.create(:leader) }
      importer.begin_import

      Leader.where({member_status: 'pending'}).count.should == 10
    end
  end

  context "#finish_import" do
    xit "sets all 'pending' leaders to 'former'" do
      leader1 = FactoryGirl.create(:leader, person_id: '1')
      leader2 = FactoryGirl.create(:leader, person_id: '2')
      leader3 = FactoryGirl.create(:leader, person_id: '3')
      importer.begin_import
      importer.import_leader(pid: '1', statecode: 'TX')
      importer.import_leader(pid: '2', statecode: 'TX')
      importer.import_leader(pid: '999', statecode: 'TX')
      importer.finish_import

      puts Leader.all.map {|l| [l.person_id, l.member_status]}
      Leader.count.should == 4
      Leader.where({member_status: 'former'}).count.should == 1
    end
  end

  context "#create_or_update(know_who_data)" do
    it "returns leader" do
      leader = KnowWhoImporter.new.create_or_update(know_who_data)

      leader.should be_an_instance_of(Leader)
    end

    context "with a new leader" do
      it "creates new leader if not yet created" do
        leader1 = FactoryGirl.create(:leader, state: texas, person_id: "00001")
        leader2 = KnowWhoImporter.new.create_or_update(know_who_data)

        leader2.id.should_not == leader1.id
      end

      it "attaches new leader to state" do
        leader = KnowWhoImporter.new.create_or_update(know_who_data)

        leader.state.code.should == "TX"
      end

      it "sets member_status to 'current'" do
        leader = KnowWhoImporter.new.create_or_update(know_who_data)

        leader.member_status.should == "current"
      end
    end

    context "with an existing leader" do
      it "finds existing leader if created" do
        leader1 = FactoryGirl.create(
          :leader, person_id: "1234567", state: texas)
        leader2 = KnowWhoImporter.new.create_or_update(
          { pid: "1234567", statecode: "TX"})
        leader2.publish!

        leader2.id.should == leader1.id
      end

      it "sets member_status to 'current'" do
        leader = FactoryGirl.create(
          :leader, person_id: "1234567", state: texas)
        leader = KnowWhoImporter.new.create_or_update(know_who_data)

        leader.member_status.should == "current"
      end
    end

    it "sets attributes of new leader and publishes" do
      KnowWhoImporter.new.create_or_update(
        { pid: "1234567", statecode: "TX", marital: "single"})

      Leader.find_by_person_id("1234567").marital_status.should == "single"
    end

    it "sets born_on of new leader and publishes" do
      KnowWhoImporter.new.create_or_update({ pid: "1234567", statecode: "TX", birthyear: 1972, birthmonth: 9, birthdate: 15})
      Leader.find_by_person_id("1234567").born_on.should == Date.new(1972, 9, 15)
    end

    it "skips born_on of new leader if no month or day" do
      KnowWhoImporter.new.create_or_update({ pid: "1234567", statecode: "TX", birthyear: 1972})
      Leader.find_by_person_id("1234567").born_on.should == nil
    end

    it "updates attributes of existing leader but does not publish" do
      KnowWhoImporter.new.create_or_update({ pid: "1234567", statecode: "TX", marital: "single"})
      KnowWhoImporter.new.create_or_update({ pid: "1234567", statecode: "TX", marital: "married"})
      Leader.find_by_person_id("1234567").marital_status.should == "single"
    end

    xit "updates attributes of existing leader but does not publish" do
      KnowWhoImporter.new.create_or_update({ pid: "1234567", statecode: "TX", marital: "single"})
      KnowWhoImporter.new.create_or_update({ pid: "1234567", statecode: "TX", marital: "married"})
      Leader.find_by_person_id("1234567").publish!
      Leader.find_by_person_id("1234567").marital_status.should == "married"
    end

    it "does not throw error if leader has same state" do
      leader = FactoryGirl.create(:leader, person_id: "1234567", state: texas)
      lambda do
        KnowWhoImporter.new.create_or_update({ pid: "1234567", statecode: "TX"})
      end.should_not raise_error
    end
  end
end
