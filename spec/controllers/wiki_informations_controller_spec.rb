require 'spec_helper'

describe WikiInformationsController do
  shared_examples 'require login' do
    it {expect(response).to redirect_to login_path}
  end

  describe '#index' do
    let!(:wiki_1) {create(:wiki)}
    let!(:wiki_2) {create(:wiki)}

    context 'admin or user' do
      before { get :index }

      it_behaves_like 'require login'
      it 'render index' do
        login_user(create(:user))
        get :index
        expect(assigns(:wiki_informations)).to match_array([wiki_1, wiki_2])
        expect(response).to render_template :index
      end
    end

    context 'guest' do
      before {get :index}
      it_behaves_like 'require login'
      it 'render index' do
        user = create(:guest)
        user.visible_wikis << wiki_1
        login_user(user)
        get :index
        expect(assigns(:wiki_informations)).to match_array([wiki_1])
        expect(response).to render_template :index
      end
    end
  end

  describe 'add_authority_user' do
    let!(:private_wiki) {create(:private_wiki)}
    let!(:admin){create(:admin_user)}
    let!(:user){create(:user)}
    let!(:guest){create(:guest)}
    it 'success to redirect' do
      login_user(admin)
      post :add_authority_user, wiki_name: private_wiki.name, email: user.email
      expect(response).to redirect_to edit_wiki_info_path(wiki_name: private_wiki.name)
    end
    it 'success to redirect' do
      login_user(admin)
      expect {
        post :add_authority_user, wiki_name: private_wiki.name, email: user.email
      }.to change(Visibility, :count).by(1)
    end

    it 'guest user is reject' do
      login_user(guest)
      expect {
        post :add_authority_user, wiki_name: private_wiki.name, email: user.email
      }.to_not change(Visibility, :count).by(1)
    end
    it 'guest user is reject' do
      login_user(guest)
      post :add_authority_user, wiki_name: private_wiki.name, email: user.email
      expect(response).to redirect_to root_path
    end
    # TODO: xhr でのリクエスト
  end

  describe 'remove_authority_user' do
    let!(:private_wiki) {create(:private_wiki)}
    let!(:admin){create(:admin_user)}
    let!(:user){create(:user)}
    let!(:guest){create(:guest)}
    it 'success to redirect' do
      login_user(admin)
      delete :remove_authority_user, wiki_name: private_wiki.name, email: user.email
      expect(response).to redirect_to edit_wiki_info_path(wiki_name: private_wiki.name)
    end

    it 'success to redirect' do
      login_user(admin)
      private_wiki.visible_users << user
      expect {
        post :remove_authority_user, wiki_name: private_wiki.name, email: user.email
      }.to change(Visibility, :count).by(-1)
    end

    it 'guest user is reject' do
      login_user(guest)
      expect {
        post :remove_authority_user, wiki_name: private_wiki.name, email: user.email
      }.to_not change(Visibility, :count).by(-1)
    end
    it 'guest user is reject' do
      login_user(guest)
      post :remove_authority_user, wiki_name: private_wiki.name, email: user.email
      expect(response).to redirect_to root_path
    end
    # TODO: xhr でのリクエスト
  end
end
