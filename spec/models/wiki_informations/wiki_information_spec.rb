require 'spec_helper'

describe WikiInformation do

  describe 'valid?' do

    context "about 'name'" do
      it 'name presented is valid' do
        expect(build(:wiki)).to be_valid
      end

      it 'uniqueness' do
        wiki1 = create(:wiki)
        wiki2 = build(:wiki, name: wiki1.name)
        expect(wiki2).to be_invalid
      end

      context 'Do not use reserved names' do
        it { expect(build(:wiki, name: 'admin')).to have(1).errors_on(:name) }
        it { expect(build(:wiki, name: 'setting')).to have(1).errors_on(:name) }
        it { expect(build(:wiki, name: 'search')).to have(1).errors_on(:name) }
      end

      context 'about format' do

        shared_examples_for 'wiki name is' do |name, validate|
          if validate == 'be valid'
            it { expect(build(:wiki, name: name)).to_not have(1).errors_on(:name) }
          else
            it { expect(build(:wiki, name: name)).to have(1).errors_on(:name) }
          end
        end

        # Valid Words
        it_should_behave_like 'wiki name is', 'a', 'be valid'
        it_should_behave_like 'wiki name is', 'develop', 'be valid'
        it_should_behave_like 'wiki name is', 'tech-blog', 'be valid'
        it_should_behave_like 'wiki name is', 'heroku', 'be valid'
        it_should_behave_like 'wiki name is', 'EngineYard', 'be valid'
        it_should_behave_like 'wiki name is', 'hoge-', 'be valid'
        it_should_behave_like 'wiki name is', 'h-ge-', 'be valid'
        it_should_behave_like 'wiki name is', 'taro1', 'be valid'
        it_should_behave_like 'wiki name is', '8ball', 'be valid'
        it_should_behave_like 'wiki name is', '999999', 'be valid'
        it_should_behave_like 'wiki name is', 'a999999-', 'be valid'
        it_should_behave_like 'wiki name is', '333f-ga', 'be valid'
        it_should_behave_like 'wiki name is', '333f-ga', 'be valid'
        it_should_behave_like 'wiki name is', ('a' * 50), 'be valid'

        # Invalid Words
        it_should_behave_like 'wiki name is', 'sample@hoge.com', 'be invalid'
        it_should_behave_like 'wiki name is', 'wiki_name', 'be invalid'
        it_should_behave_like 'wiki name is', ' aaa', 'be invalid'
        it_should_behave_like 'wiki name is', 'aaa bbb', 'be invalid'
        it_should_behave_like 'wiki name is', 'aaa bbb ', 'be invalid'
        it_should_behave_like 'wiki name is', ' aaa bbb ', 'be invalid'
        it_should_behave_like 'wiki name is', '名前', 'be invalid'
        it_should_behave_like 'wiki name is', '山田 花子', 'be invalid'
        it_should_behave_like 'wiki name is', '-aaa', 'be invalid'
        it_should_behave_like 'wiki name is', '%huga%', 'be invalid'
        it_should_behave_like 'wiki name is', 'sure?', 'be invalid'
        it_should_behave_like 'wiki name is', '?r93829r2', 'be invalid'
        it_should_behave_like 'wiki name is', '#TODO', 'be invalid'
        it_should_behave_like 'wiki name is', '\a', 'be invalid'
        it_should_behave_like 'wiki name is', ('a' * 51), 'be invalid'
      end
    end
  end

  describe 'publish_by!' do
    context 'admin or general user' do
      let!(:user) {create(:user)}
      let!(:private_wiki) {create(:private_wiki)}
      subject do
        private_wiki.publish_by!(user)
        private_wiki.reload.public?
      end
      it {should be_true }
    end

    context 'guest user' do
      let!(:guest) {create(:guest)}
      let!(:private_wiki) {create(:private_wiki)}
      subject {lambda{private_wiki.publish_by!(guest)}}
      it {should raise_error(WikiInformation::PermissionError) }
    end
  end

  describe 'hide_by!' do
    context 'admin or general user' do
      let!(:user) {create(:user)}
      let!(:public_wiki) {create(:public_wiki)}
      subject do
        public_wiki.hide_by!(user)
        public_wiki.reload.private?
      end
      it {should be_true}
    end

    context 'guest user' do
      let!(:guest) {create(:guest)}
      let!(:private_wiki) {create(:private_wiki)}
      subject {lambda{private_wiki.publish_by!(guest)}}
      it {should raise_error(WikiInformation::PermissionError) }
    end
  end

  describe 'visivilities' do

    context 'guest user' do

      let(:guest_user){create(:user, admin: false, limited: true)}

      context 'public wiki' do
        let(:public_wiki) {create(:wiki, is_private: false)}
        it 'unvisible wiki' do
          public_wiki.visible_users.should_not be_include(guest_user)
        end
        it 'visible wiki' do
          public_wiki.visible_users << guest_user
          public_wiki.visible_users.should be_include(guest_user)
        end
      end

      context 'private wiki' do
        let(:private_wiki) {create(:wiki, is_private: true)}
        it 'unvisible wiki' do
          private_wiki.visible_users.should_not be_include(guest_user)
        end
        it 'visible wiki' do
          private_wiki.visible_users << guest_user
          private_wiki.visible_users.should be_include(guest_user)
        end
      end
    end

    context 'admin, general user' do
      let(:admin_user){create(:user, admin: true, limited: false)}
      let(:user){create(:user, admin: false, limited: false)}

      context 'public wiki' do
        let(:public_wiki) {create(:wiki, is_private: false)}
        it 'unvisible wiki' do
          public_wiki.visible_users.should_not be_include(admin_user)
          public_wiki.visible_users.should_not be_include(user)
        end
        it 'visible wiki' do
          public_wiki.visible_users << [admin_user, user]
          public_wiki.visible_users.should be_include(admin_user)
          public_wiki.visible_users.should be_include(user)
        end
      end

      context 'private wiki' do
        let(:private_wiki) {create(:wiki, is_private: true)}
        it 'unvisible wiki' do
          private_wiki.visible_users.should_not be_include(admin_user)
          private_wiki.visible_users.should_not be_include(user)
        end
        it 'visible wiki' do
          private_wiki.visible_users << [admin_user, user]
          private_wiki.visible_users.should be_include(admin_user)
          private_wiki.visible_users.should be_include(user)
        end
      end
    end
  end

  describe '#collaborator_for_private_wiki?' do

    context 'public wiki' do
      let(:public_wiki) {create(:wiki, is_private: false)}
      let(:admin_user) {create(:user, admin: true)}
      let(:user) {create(:user)}
      let(:guest) {create(:user, limited: true)}

      it 'admin user is visible' do
        public_wiki.collaborator_for_private_wiki?(admin_user).should be_true
      end
      it 'general user is visible' do
        public_wiki.collaborator_for_private_wiki?(user).should be_true
      end
      it 'not member user is unvisible' do
        public_wiki.collaborator_for_private_wiki?(guest).should be_false
      end
      it 'joined guest user is visible' do
        public_wiki.visible_users << guest
        public_wiki.collaborator_for_private_wiki?(guest).should be_true
      end
    end

    context 'private wiki' do
      let(:private_wiki) {create(:wiki, is_private: true)}
      let(:admin_user) {create(:user, admin: true)}
      let(:user) {create(:user, admin: false, limited: false)}
      let(:guest) {create(:user, limited: true)}

      it 'Not member the admin is unvisible' do
        private_wiki.collaborator_for_private_wiki?(admin_user).should be_false
      end
      it 'Joined member admin is visible' do
        private_wiki.visible_users << admin_user
        private_wiki.collaborator_for_private_wiki?(admin_user).should be_true
      end
      it 'Not member general user is visible' do
        private_wiki.collaborator_for_private_wiki?(user).should be_false
      end
      it 'Joined general user is visible' do
        private_wiki.visible_users << user
        private_wiki.collaborator_for_private_wiki?(user).should be_true
      end
      it 'Not member guest is unvisible' do
        private_wiki.collaborator_for_private_wiki?(guest).should be_false
      end
      it 'Joined guest user is visible' do
        private_wiki.visible_users << guest
        private_wiki.collaborator_for_private_wiki?(guest).should be_true
      end
    end
  end

  describe '.accesible_by' do
    context 'guest user' do
      let(:guest) {create(:guest)}
      context 'Joined wiki is visible' do
        let(:public_wiki) {create(:public_wiki)}
        let(:private_wiki) {create(:private_wiki)}
        it 'public wiki is visible' do
          public_wiki.visible_users << guest
          WikiInformation.accessible_by(guest).should be_include(public_wiki)
        end
        it 'private wiki is visible' do
          private_wiki.visible_users << guest
          WikiInformation.accessible_by(guest).should be_include(private_wiki)
        end
      end
      context "Don't Joined wiki is unvisible" do
        let(:public_wiki) {create(:public_wiki)}
        let(:private_wiki) {create(:private_wiki)}
        it 'public wiki is unvisible' do
          WikiInformation.accessible_by(guest).should_not be_include(public_wiki)
        end
        it 'private wiki is unvisible' do
          WikiInformation.accessible_by(guest).should_not be_include(private_wiki)
        end
      end
    end

    context 'admin, general user' do
      context 'public wiki' do
        let!(:public_wiki) {create(:public_wiki)}
        let!(:admin_user) {create(:admin_user)}
        let!(:user) {create(:user)}

        it 'public wiki is visible' do
          expect(WikiInformation.accessible_by(admin_user)).to include(public_wiki)
          expect(WikiInformation.accessible_by(user)).to include(public_wiki)
        end
      end
      context 'private wiki' do
        let(:private_wiki) {create(:private_wiki)}
        let(:admin_user) {create(:admin_user)}
        let(:user) {create(:user)}

        it "Don't Joined wiki is unvisible" do
          WikiInformation.accessible_by(admin_user).should_not be_include(private_wiki)
          WikiInformation.accessible_by(user).should_not be_include(private_wiki)
        end

        it 'Joined wiki is visible' do
          private_wiki.visible_users << [admin_user, user]
          WikiInformation.accessible_by(admin_user).should be_include(private_wiki)
          WikiInformation.accessible_by(user).should be_include(private_wiki)
        end
      end
    end
  end

end
