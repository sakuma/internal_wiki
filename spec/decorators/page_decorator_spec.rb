# coding: utf-8
require 'spec_helper'

describe PageDecorator do
  let(:user) { create(:user) }
  let(:wiki) { create(:wiki, creator: user) }
  let(:page) { wiki.pages.first.extend PageDecorator }
  subject { page.last_editor_name}
  it {should eq user.name}
end
