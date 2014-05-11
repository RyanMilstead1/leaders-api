require 'spec_helper'

describe Leader do
  let(:know_who_data) { { pid: "1234567", statecode: "TX" } }
  let!(:texas) { FactoryGirl.create(:state, code: "TX") }
  let(:leader) do
    FactoryGirl.build(:leader, legislator_type: "FL", 
                                first_name: "Dorothy", 
                                nick_name: "Sue", 
                                last_name: "Landske", 
                                prefix: "Sen."
                      )
  end

  context "#name" do
    it "returns nickname lastname" do
      leader.name.should == "Sue Landske"
    end
  end

  context "#prefix_name" do
    it "returns nickname lastname" do
      leader.legislator_type = "SL"
      leader.prefix_name.should == "Sen. Sue Landske"
    end

    it "includes 'US' in front of prefix for federal legislators" do
      leader.legislator_type = "FL"
      leader.prefix_name.should == "US Sen. Sue Landske"
    end
  end

  context "#generate_slug" do
    it "assigns slug from prefix_name" do
      leader.save!
      leader.slug.should == "us-sen-sue-landske"
    end

    it "does not allow duplicate slug" do
      3.times do
        FactoryGirl.create(:leader, legislator_type: "FL", 
                                    first_name: "Dorothy", 
                                    nick_name: "Sue", 
                                    last_name: "Landske", 
                                    prefix: "Sen.")
      end
      Leader.where(slug: "us-sen-sue-landske--3").count.should == 1
    end
  end

  context "#photo_src" do
    it "returns path to photo" do
      leader = Leader.new(photo_path: 'Images\\Photos\\SL\\IN\\S', 
                          photo_file: 'Landske_Dorothy_194409.jpg')
      leader.photo_src.should == 
        'http://publicservantsprayer.org/photos/SL/IN/S/Landske_Dorothy_194409.jpg'
    end
    
    it "returns path to blank photo if path is nil" do
      leader = Leader.new(photo_path: nil, photo_file: 'Landske_Dorothy_194409.jpg')
      leader.photo_src.should eq('http://placehold.it/109x148')
    end
  end

  context ".create_or_update" do
    context "with a new leader" do
      let(:know_who_data) { {
        pid: "1234567",
        statecode: "TX",
        prefix: 'Sen.',
        nickname: 'Sue',
        lastname: 'Landske',
        legtype: 'FL'
      } }
      let(:leader) { Leader.create_or_update(know_who_data) }

      it "creates new leader if not yet created" do
        existing_leader= FactoryGirl.create(:leader, state: texas, person_id: "00001")

        leader.id.should_not == existing_leader.id
      end

      it "attaches new leader to state" do
        leader.state.code.should == "TX"
      end

      it "creates slug from prefix name" do
        puts pre: leader.prefix_name
        leader.slug.should == "us-sen-sue-landske"
      end
    end

    context "with an existing leader" do
      it "finds existing leader if created" do
        leader1 = FactoryGirl.create(
          :leader, person_id: "1234567", state: texas)
        leader2 = Leader.create_or_update(
          { pid: "1234567", statecode: "TX"})
        leader2.save!

        leader2.id.should == leader1.id
      end
    end

    it "skips born_on of new leader if no month or day" do
      Leader.create_or_update(
        { pid: "1234567", statecode: "TX", birthyear: 1972})

      Leader.find_by_person_id("1234567").born_on.should == nil
    end

    it "does not throw error if leader has same state" do
      leader = FactoryGirl.create(:leader, person_id: "1234567", state: texas)
      lambda do
        Leader.create_or_update({ pid: "1234567", statecode: "TX"})
      end.should_not raise_error
    end
  end
end
