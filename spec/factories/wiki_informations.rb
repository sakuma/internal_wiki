require 'faker'

FactoryGirl.define do
  factory :wiki, class: 'WikiInformation' do |w|
    w.association :creator, factory: :user
    w.sequence(:name) {|n| "wiki-name-#{n}"}
    w.is_private false

    factory :public_wiki do
      is_private false
    end
    factory :private_wiki do
      is_private true
    end
  end
end
