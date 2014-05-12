# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :leader_name do |n|
    "Joe Congressman#{n}"
  end

  sequence :slug do |n|
    "joe-congressman--#{n}"
  end

  sequence :person_id do |n|
    "1234567--#{n}"
  end

  factory :leader do
    state
    first_name "Joe" 
    last_name "Shmoe"
    nick_name { generate(:leader_name) }
    person_id { generate(:person_id) }
    photo_path 'Images\Photos\SL\IN\S'
    photo_file 'Landske_Dorothy_194409.jpg'
    member_status 'current'

    factory :senator do
      legislator_type "SL"
      chamber "S"
      title "Senator"
      prefix "Sen."
    end

    factory :representative do
      legislator_type "SL"
      chamber "H"
      title "Representative"
      prefix "Rep."
    end

    factory :us_senator do
      legislator_type "FL"
      chamber "S"
      title "US Senator"
      prefix "Sen."
    end

    factory :us_representative do
      legislator_type "FL"
      chamber "H"
      title "US Representative"
      prefix "Rep."
    end
  end
end
