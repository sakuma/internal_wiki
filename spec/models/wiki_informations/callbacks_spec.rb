require 'spec_helper'

describe WikiInformation, 'callbacks' do

  context 'before_save' do

    describe 'set_visivilities' do
      context 'on create' do
        let!(:user){create(:user)}
        let!(:private_wiki){create(:private_wiki, creator: user)}
        let!(:public_wiki){create(:public_wiki, creator: user)}
        subject{WikiInformation.accessible_by(user)}
        it 'set visibilities of private_wiki' do
          expect(subject).to include(private_wiki)
        end
        it 'do nothing of public_wiki' do
          expect(subject).to include(public_wiki)
          expect(public_wiki.visibilities).to be_empty
        end
      end
      context 'on update' do
        let!(:user){create(:user)}
        let!(:private_wiki) {create(:private_wiki)}
        let!(:public_wiki) {create(:public_wiki)}

        it 'set visibilities of private_wiki' do
          to_private_wiki = public_wiki.tap{|w| w.hide_by!(user)}
          expect(WikiInformation.accessible_by(user)).to include(to_private_wiki)
        end
        it 'do nothing of public_wiki' do
          to_public_wiki = private_wiki.tap{|w| w.publish_by!(user) }.reload
          expect(WikiInformation.accessible_by(user)).to include(to_public_wiki)
          expect(to_public_wiki.visibilities).to be_empty
        end
      end
    end
  end

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
      let!(:private_wiki) {create(:private_wiki)}

      context 'guest user' do
        it "still visible joined wiki" do
          private_wiki.visible_users << [joined_guest_user, joined_member]
          expect(WikiInformation.accessible_by(joined_guest_user)).to include(private_wiki)

          private_wiki.publish_by!(joined_member)

          expect(WikiInformation.accessible_by(joined_guest_user)).to include(private_wiki)
        end

        it 'unjoinded wiki is unvisible' do
          expect(WikiInformation.accessible_by(joined_guest_user)).to_not include(private_wiki)

          private_wiki.publish_by!(joined_member)

          expect(WikiInformation.accessible_by(joined_guest_user)).to_not include(private_wiki)
        end
      end

      context 'admin and general user' do
        it "still visible joined wiki" do
          private_wiki.visible_users << [joined_member]
          expect(WikiInformation.accessible_by(joined_member)).to include(private_wiki)
          expect(WikiInformation.accessible_by(blind_admin_user)).to_not include(private_wiki)

          private_wiki.publish_by!(joined_member)

          expect(WikiInformation.accessible_by(joined_member)).to include(private_wiki)
          expect(WikiInformation.accessible_by(blind_admin_user)).to include(private_wiki)
        end

        it 'unjoinded wiki is unvisible' do
          expect(WikiInformation.accessible_by(joined_member)).to_not include(private_wiki)
          expect(WikiInformation.accessible_by(blind_admin_user)).to_not include(private_wiki)

          private_wiki.publish_by!(private_wiki.creator)

          expect(WikiInformation.accessible_by(joined_member)).to include(private_wiki)
          expect(WikiInformation.accessible_by(blind_admin_user)).to include(private_wiki)
        end
      end
    end
  end

end
