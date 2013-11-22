require "spec_helper"

describe Page do

  describe 'valid?' do
    subject {Page.new(name: nil) }
    it { should be_invalid }
  end
end
