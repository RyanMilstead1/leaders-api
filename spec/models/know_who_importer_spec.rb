require 'spec_helper'

describe KnowWhoImporter do
  let :know_who_data do
    { pid: "1234567", statecode: "TX" }
  end

  before do
    State.delete_all
    Leader.delete_all
  end

  it "sets state on initilization" do
    FactoryGirl.create(:state, code: "TX")
    import = KnowWhoImporter.new(know_who_data)
    import.state.code.should == "TX"
  end

  context "#leader_exists?" do
    it "returns true if leader exists" do
      texas = FactoryGirl.create(:state, code: "TX")
      FactoryGirl.create(:leader, person_id: "123", state: texas)
      import = KnowWhoImporter.new({ pid: "123", statecode: texas.code})
      import.leader_exists?.should == true 
    end

    it "returns false if leader does not exist" do
      texas = FactoryGirl.create(:state, code: "TX")
      FactoryGirl.create(:leader, person_id: "123", state: texas)
      import = KnowWhoImporter.new({ pid: "456", statecode: texas.code})
      import.leader_exists?.should == false
    end
  end

  context "#create_or_update(know_who_data)" do
    before do
      State.delete_all
      Leader.delete_all
    end

    it "returns leader" do
      state = FactoryGirl.create(:state, code: "TX")
      leader = KnowWhoImporter.create_or_update(know_who_data)
      leader.should be_an_instance_of(Leader)
    end

    it "creates new leader if not yet created" do
      state = FactoryGirl.create(:state, code: "TX")
      leader1 = FactoryGirl.create(:leader, state: state, person_id: "00001")
      leader2 = KnowWhoImporter.create_or_update(know_who_data)
      leader2.id.should_not == leader1.id
    end

    it "finds existing leader if created" do
      state = FactoryGirl.create(:state, code: "TX")
      leader1 = FactoryGirl.create(:leader, person_id: "1234567", state: state)
      leader2 = KnowWhoImporter.create_or_update({ pid: "1234567", statecode: "TX"})
      leader2.id.should == leader1.id
    end

    it "attaches new leader to state" do
      state = FactoryGirl.create(:state, code: "TX")
      leader = KnowWhoImporter.create_or_update(know_who_data)
      leader.state.code.should == "TX"
    end

    it "updates attributes of existing leader" do
      state = FactoryGirl.create(:state, code: "TX")
      leader = FactoryGirl.create(:leader, state: state, person_id: "1234567", marital_status: "single")
      KnowWhoImporter.create_or_update({ pid: "1234567", statecode: "TX", marital: "married"})
      leader.reload.marital_status.should == "married"
    end
    
    it "does not throw error if leader has same state" do
      state = FactoryGirl.create(:state, code: "TX")
      leader = FactoryGirl.create(:leader, person_id: "1234567", state: state)
      lambda do
        KnowWhoImporter.create_or_update({ pid: "1234567", statecode: "TX"})
      end.should_not raise_error
    end
    
    it "throws error if leader has new state" do
      state = FactoryGirl.create(:state, code: "TX")
      FactoryGirl.create(:state, code: "CA")
      leader = FactoryGirl.create(:leader, state: state, person_id: "1234567")
      lambda do
        KnowWhoImporter.create_or_update({ pid: "1234567", statecode: "CA"})
      end.should raise_error(RuntimeError, "Know Who data tried to change leader state")
    end

    it "throws error if state not found" do
      state = FactoryGirl.create(:state, code: "TX")
      leader = FactoryGirl.create(:leader, state: state, person_id: "1234567")
      lambda do
        KnowWhoImporter.create_or_update({ pid: "1234567", statecode: "CA"})
      end.should raise_error(RuntimeError, "Know Who data state not found")
    end
  end
end
