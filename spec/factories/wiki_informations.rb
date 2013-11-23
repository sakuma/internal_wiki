require 'faker'

FactoryGirl.define do
  factory :wiki, class: 'WikiInformation' do |w|
    w.sequence(:name) {|n| "wiki-name-#{n}"}
    w.is_private false
    # w.after(:build) do |wiki|
    #   wiki.created_by create_new_user
    # end
  end
end
