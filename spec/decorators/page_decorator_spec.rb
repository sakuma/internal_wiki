# coding: utf-8
require 'spec_helper'

describe PageDecorator do
  let(:page) { Page.new.extend PageDecorator }
  subject { page }
  it { should be_a Page }
end
