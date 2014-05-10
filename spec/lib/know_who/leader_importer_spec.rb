require 'spec_helper'

describe KnowWho::LeaderImporter do
  let(:know_who_data) { { pid: "1234567", statecode: "TX" } }
  let!(:texas) { FactoryGirl.create(:state, code: "TX") }
  let(:importer) { KnowWho::LeaderImporter.new }

  context "#begin_import" do
    it "set all leaders to pending" do
      3.times { FactoryGirl.create(:leader) }
      importer.begin_import

      Leader.where(member_status: 'pending').count.should == 3
    end
  end

  context "#finish_import" do
    it "sets all 'pending' leaders to 'former'" do
      leader1 = FactoryGirl.create(:leader, person_id: '1')
      leader2 = FactoryGirl.create(:leader, person_id: '2')
      leader3 = FactoryGirl.create(:leader, person_id: '3')
      importer.begin_import
      importer.import_leader(pid: '1', statecode: 'TX')
      importer.import_leader(pid: '2', statecode: 'TX')
      importer.import_leader(pid: '999', statecode: 'TX')
      importer.finish_import

      Leader.where({member_status: 'former'}).count.should == 1
    end
  end

  context "#import_leader(know_who_data)" do
    let(:leader) { importer.import_leader(know_who_data) }

    it "returns leader" do
      leader.should be_an_instance_of(Leader)
    end

    context "with a new leader" do
      it "creates new leader if not yet created" do
        leader1 = FactoryGirl.create(:leader, state: texas, person_id: "00001")
        leader2 = importer.import_leader(know_who_data)

        leader2.id.should_not == leader1.id
      end

      it "attaches new leader to state" do
        leader.state.code.should == "TX"
      end

      it "sets member_status to 'current'" do
        leader.member_status.should == "current"
      end
    end

    context "with an existing leader" do
      it "finds existing leader if created" do
        leader1 = FactoryGirl.create(
          :leader, person_id: "1234567", state: texas)
        leader2 = importer.import_leader(
          { pid: "1234567", statecode: "TX"})
        leader2.save!

        leader2.id.should == leader1.id
      end

      it "sets member_status to 'current'" do
        leader = FactoryGirl.create(
          :leader, person_id: "1234567", state: texas)
        leader = importer.import_leader(know_who_data)

        leader.member_status.should == "current"
      end
    end

    it "skips born_on of new leader if no month or day" do
      importer.import_leader(
        { pid: "1234567", statecode: "TX", birthyear: 1972})

      Leader.find_by_person_id("1234567").born_on.should == nil
    end

    it "does not throw error if leader has same state" do
      leader = FactoryGirl.create(:leader, person_id: "1234567", state: texas)
      lambda do
        importer.import_leader({ pid: "1234567", statecode: "TX"})
      end.should_not raise_error
    end
  end
end
