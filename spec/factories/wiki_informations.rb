require 'faker'

FactoryGirl.define do
  factory :wiki, class: 'WikiInformation' do |w|
    w.name Faker::Lorem.word
  end
end
