require 'spec_helper'

describe WikiInformation, 'callbacks' do

  context 'before_create' do

    describe ':prepare_git_repository' do
      it 'exist git repogitory' do
        expect(File.exists?(create(:wiki).git_directory)).to be_true
      end
    end
  end

  context 'before_update' do

    describe 'rename_repository_directory' do
      it 'rename git directory when wiki_informations.name was rename' do
        @wiki = create(:wiki, name: 'old')
        @wiki.update_attribute(:name, 'new-name')
        @wiki.name.should == 'new-name'
        File.exists?(@wiki.git_directory).should be_true
      end
    end

    describe 'set_visivilities' do
      # TODO
    end
  end

  context 'after_create' do

    describe 'setup_home_page' do
      subject {create(:wiki)}
      it 'created welcome page' do
        subject.pages.size == 1
        subject.pages.first.url_name.should == 'welcome'
      end
    end
  end

  context "after_destory" do

    describe 'cleanup_git_repository' do
      it 'destory record with git directory' do
        wiki = create(:wiki)
        dirname = wiki.git_directory
        File.exists?(dirname).should be_true
        wiki.destroy!
        File.exists?(dirname).should be_false
      end
    end
  end

  context "after_update" do

    describe 'clear_private_memberships' do

      let!(:joined_member) {create(:user)}
      let!(:joined_guest_user) {create(:guest)}
      let!(:blind_admin_user) {create(:admin_user)}
      let!(:private_wiki) {create(:private_wiki, creator: joined_member)}

      context 'guest user' do
        it "still visible joined wiki" do
          private_wiki.visible_users << [joined_guest_user]
          expect(WikiInformation.accessible_by(joined_guest_user)).to include(private_wiki)

          private_wiki.publish!

          expect(WikiInformation.accessible_by(joined_guest_user)).to include(private_wiki)
        end

        it 'unjoinded wiki is unvisible' do
          private_wiki.update_attributes!(is_private: true)
          expect(WikiInformation.accessible_by(joined_guest_user)).to_not include(private_wiki)

          private_wiki.publish!

          expect(WikiInformation.accessible_by(joined_guest_user)).to_not include(private_wiki)
        end
      end

      context 'admin and general user' do
        it "still visible joined wiki" do
          private_wiki.visible_users << [joined_member]
          expect(WikiInformation.accessible_by(joined_member)).to include(private_wiki)
          expect(WikiInformation.accessible_by(blind_admin_user)).to_not include(private_wiki)

          private_wiki.publish!

          expect(WikiInformation.accessible_by(joined_member)).to include(private_wiki)
          expect(WikiInformation.accessible_by(blind_admin_user)).to include(private_wiki)
        end

        it 'unjoinded wiki is unvisible' do
          expect(WikiInformation.accessible_by(joined_member)).to_not include(private_wiki)
          expect(WikiInformation.accessible_by(blind_admin_user)).to_not include(private_wiki)

          private_wiki.publish!

          expect(WikiInformation.accessible_by(joined_member)).to include(private_wiki)
          expect(WikiInformation.accessible_by(blind_admin_user)).to include(private_wiki)
        end
      end
    end
  end

end
