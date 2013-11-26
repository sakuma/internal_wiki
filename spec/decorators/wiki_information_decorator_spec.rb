# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WikiInformationDecorator do


  describe '#private_policy' do

    context 'about private' do
      let(:wiki){create(:private_wiki).extend WikiInformationDecorator}
      subject {wiki.private_policy}
      it { should eq 'private' }
    end

    context 'about public' do
      let(:wiki){create(:public_wiki).extend WikiInformationDecorator}
      subject { wiki.private_policy}
      it { should eq 'public' }
    end
  end

  describe '#private_policy_label' do

    context 'about private' do
      let(:wiki){create(:private_wiki).extend WikiInformationDecorator}
      subject {wiki.private_policy_label}
      it { should eq 'warning' }
    end

    context 'about public' do
      let(:wiki){create(:public_wiki).extend WikiInformationDecorator}
      subject {wiki.private_policy_label}
      it { should eq 'success' }
    end
  end

  describe '#controllable_by?' do

    let(:wiki){create(:public_wiki).extend WikiInformationDecorator}

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
