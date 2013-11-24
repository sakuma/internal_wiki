FactoryGirl.define do
  factory :page do |p|
    p.association :wiki_information, factory: :wiki
    p.sequence(:name) {|n| "page-name-#{n}"}
    p.sequence(:url_name) {|n| "page-url-name-#{n}"}
    p.body "page body content."
  end
end
