require 'faker'

FactoryGirl.define do

  factory :user do |u|
    u.name {Faker::Name.name}
    u.sequence(:email) {|n| "some#{n}@sample.com"}
    u.password "password"
    u.password_confirmation {|user| user.password }
    after(:create) { |user| user.activate! }

    factory :admin_user do
      admin true
      limited false
    end
    factory :guest do
      admin false
      limited true
    end
    factory :pending_user do
      activation_state 'pending'
    end
    trait(:active) { activation_state 'active'}
  end
end
