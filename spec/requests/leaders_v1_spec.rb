require 'spec_helper'

describe 'Leader api v1' do
  before do
    @indiana = FactoryGirl.create(:state, name: "Indiana", code: "IN")
    @bob = FactoryGirl.create(:us_senator, state: @indiana, nick_name: "Bob", last_name: "Smith")
    FactoryGirl.create(:us_representative, state: @indiana, nick_name: "Jill", last_name: "Jones")
    FactoryGirl.create(:senator, state: @indiana)
    FactoryGirl.create(:representative, state: @indiana)
    FactoryGirl.create(:representative, state: @indiana)
    FactoryGirl.create(:representative, state: @indiana, member_status: 'former')
  end

  it 'displays current members' do
    visit "/v1/states/in/leaders"

    page.should have_content('"member_status":"current"')
  end

  it 'does not display former members' do
    visit "/v1/states/in/leaders"

    page.should_not have_content('"member_status":"former"')
  end

  it 'displays json data for all leaders in state' do
    visit "/v1/states/in/leaders"
    page.should have_content('"name":"Bob Smith"')
    page.should have_content('"name":"Jill Jones"')
  end

  it 'displays json data for individual leader' do
    visit "/v1/leaders/#{@bob.slug}"
    page.should have_content('"name":"Bob Smith"')
    page.should_not have_content('"name":"Jill Jones"')
  end

  it 'displays us_senate' do
    visit "/v1/states/in/leaders/us_senate"
    page.should have_content('"title":"US Senator"')
  end

  it 'displays us_house' do
    visit "/v1/states/in/leaders/us_house"
    page.should have_content('"title":"US Representative"')
  end 

  it 'displays state_senate' do
    visit "/v1/states/in/leaders/state_senate"
    page.should have_content('"title":"Senator"')
  end

  it 'displays state_house' do
    visit "/v1/states/in/leaders/state_house"
    page.should have_content('"title":"Representative"')
  end

  it 'includes full url to photo' do
    visit "/v1/states/in/leaders"
    page.should have_content('"photo_src":"http://publicservantsprayer.org/')
  end 

  it 'includes state code' do
    visit "/v1/states/in/leaders"
    page.should have_content('"state_code":"in"')
  end

end
