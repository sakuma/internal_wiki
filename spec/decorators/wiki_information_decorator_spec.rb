# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WikiInformationDecorator do
  let(:wiki_information) { WikiInformation.new.extend WikiInformationDecorator }
  subject { wiki_information }
  it { should be_a WikiInformation }
end
