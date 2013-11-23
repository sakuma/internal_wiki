require 'faker'

FactoryGirl.define do

  factory :user do |u|
    u.name Faker::Name.name
    u.sequence(:email) {|n| "some#{n}@sample.com"}
    u.password "password"
    u.password_confirmation {|user| user.password }
    u.activation_state 'active'

    trait(:admin) { admin true }
    trait(:limited) { limited true }
    trait(:activation_state) { activation_state 'active'}
  end
end
