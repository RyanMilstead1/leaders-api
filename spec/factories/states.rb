# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :state do
    name "Texas"
    code "TX"

    factory :state_with_single_chamber do
      ignore do
        leaders_count 5
      end

      after(:create) do |state, evaluator|
        FactoryGirl.create_list(:senator, evaluator.leaders_count, state: state, legislator_type: "SL")
        FactoryGirl.create_list(:us_senator, evaluator.leaders_count, state: state)
        FactoryGirl.create_list(:us_representative, evaluator.leaders_count, state: state)
      end
    end

    factory :state_with_dual_chamber do
      ignore do
        leaders_count 5
      end

      after(:create) do |state, evaluator|
        FactoryGirl.create_list(:senator, evaluator.leaders_count, state: state, legislator_type: "SL")
        FactoryGirl.create_list(:representative, evaluator.leaders_count, state: state, legislator_type: "SL")
        FactoryGirl.create_list(:us_senator, evaluator.leaders_count, state: state)
        FactoryGirl.create_list(:us_representative, evaluator.leaders_count, state: state)
      end
    end

  end

end
