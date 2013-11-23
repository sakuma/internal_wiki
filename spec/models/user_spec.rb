require 'spec_helper'

describe User do
  describe 'valid?' do
    subject {User.new(email: nil) }
    it { should be_invalid }
    it { subject.activation_state.should be_nil}
    it { subject.admin.should be_false}
    it { subject.limited.should be_false}
  end
end
