# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WikiInformationDecorator do

  let(:wiki) { create(:wiki).extend WikiInformationDecorator }

  describe '#private_policy' do

    context 'about private' do
      subject do
        wiki.update(is_private: true)
        wiki.private_policy
      end
      it { should eq 'private' }
    end

    context 'about public' do
      subject do
        wiki.update(is_private: false)
        wiki.private_policy
      end
      it { should eq 'public' }
    end
  end

  describe '#private_policy_label' do

    context 'about private' do
      subject do
        wiki.update(is_private: true)
        wiki.private_policy_label
      end
      it { should eq 'warning' }
    end

    context 'about public' do
      subject do
        wiki.update(is_private: false)
        wiki.private_policy_label
      end
      it { should eq 'success' }
    end
  end

  describe '#controllable_by?' do

    context 'admin user' do

      let(:admin_user) {create(:user, admin: true)}
      subject {wiki.controllable_by?(admin_user)}
      it {should be_true}
    end

    context 'guest user' do

      let(:guest_user) {create(:user, limited: true)}
      subject {wiki.controllable_by?(guest_user)}
      it {should be_false}
    end

    # else logic is Wikiinformation#collaborator_for_private_wiki? logic
  end

end
