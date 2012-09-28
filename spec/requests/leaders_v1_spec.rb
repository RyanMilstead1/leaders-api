require 'spec_helper'

describe 'Leader api v1' do
  before do
    indiana = FactoryGirl.create(:state, name: "Indiana", code: "IN")
    bob = FactoryGirl.create(:us_senator, state: indiana, nick_name: "Bob", last_name: "Smith")
  end

  it 'displays json data for individual leader' do
    visit '/v1/states/in/leaders/us-sen-bob-smith'
    page.should have_content('"slug":"us-sen-bob-smith"')
  end
end
