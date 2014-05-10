require 'spec_helper'

describe Leader do
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
    it "throws error if leader has new state" do
      texas = FactoryGirl.create(:state, code: "TX")
      california = FactoryGirl.create(:state, code: "CA")
      leader = FactoryGirl.create(:leader, state: texas, person_id: "1234567")
      lambda do
        Leader.create_or_update({ pid: "1234567", statecode: "CA"})
      end.should raise_error(
        RuntimeError, "Know Who data tried to change leader state")
    end

    it "throws error if state not found" do
      texas = FactoryGirl.create(:state, code: "TX")
      leader = FactoryGirl.create(:leader, state: texas, person_id: "1234567")
      lambda do
        Leader.create_or_update({ pid: "1234567", statecode: "CA"})
      end.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
