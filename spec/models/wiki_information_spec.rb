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

      context 'about format' do

        shared_examples_for 'wiki name is' do |name, validate|
          if validate == 'be valid'
            it { expect(build(:wiki, name: name, creator: nil)).to_not have(1).errors_on(:name) }
          else
            it { expect(build(:wiki, name: name, creator: nil)).to have(1).errors_on(:name) }
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

  context 'callbacks' do

    describe 'before_create :prepare_git_repository' do
      it 'exist git repogitory' do
        expect(File.exists?(create(:wiki).git_directory)).to be_true
      end
    end

    describe 'before_update :rename_repository_directory' do
      it 'rename git directory when wiki_informations.name was rename' do
        @wiki = create(:wiki, name: 'old')
        @wiki.update_attribute(:name, 'new-name')
        @wiki.name.should == 'new-name'
        File.exists?(@wiki.git_directory).should be_true
      end
    end

    describe 'after_create :setup_home_page' do
      subject {create(:wiki)}
      it 'created welcome page' do
        subject.pages.size == 1
        subject.pages.first.url_name.should == 'welcome'
      end
    end

    describe 'after_destory :cleanup_git_repository' do
      it 'destory record with git directory' do
        wiki = create(:wiki)
        dirname = wiki.git_directory
        File.exists?(dirname).should be_true
        wiki.destroy!
        File.exists?(dirname).should be_false
      end
    end

    describe 'after_update :clear_private_memberships' do
      before do
        @private_wiki = create(:wiki, is_private: true, created_by: create(:user).id)
      end

      it 'unnvisible private wiki' do
        blind_user = create(:user)
        WikiInformation.accessible_by(blind_user).should_not be_include(@private_wiki)
      end

      it 'change public' do
        user = create(:user)
        WikiInformation.accessible_by(user).should_not be_include(@private_wiki)
        @private_wiki.update_attributes!(is_private: false)
        WikiInformation.accessible_by(user).should be_include(@private_wiki)
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
        guest.visible_wikis << public_wiki
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
        private_wiki.visible_authority_users << admin_user
        private_wiki.collaborator_for_private_wiki?(admin_user).should be_true
      end
      it 'Not member general user is visible' do
        private_wiki.collaborator_for_private_wiki?(user).should be_false
      end
      it 'Joined general user is visible' do
        private_wiki.visible_authority_users << user
        private_wiki.collaborator_for_private_wiki?(user).should be_true
      end
      it 'Not member guest is unvisible' do
        private_wiki.collaborator_for_private_wiki?(guest).should be_false
      end
      it 'Joined guest user is visible' do
        guest.visible_wikis << private_wiki
        private_wiki.collaborator_for_private_wiki?(guest).should be_true
      end
    end
  end

end
