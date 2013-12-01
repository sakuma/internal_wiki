require 'spec_helper'

describe Admin::UsersController do

  before do
    @admin_user = create(:admin_user)
    login_user(@admin_user)
  end

  describe "GET 'index'" do
    let!(:active_users) {create_list(:user, 3)}
    let!(:pending_user) {create(:user).tap{|u| u.update_column(:activation_state, 'pending')}}
    it "returns http success" do
      get :index
      expect(assigns(:active_users)).to match_array [@admin_user, active_users].flatten
      expect(assigns(:invalidity_users)).to include(pending_user)
      expect(response).to render_template :index
    end
  end

  describe "GET 'show'" do
    let!(:user){create(:user)}
    it "returns http success" do
      get :show, id: user.id
      expect(response).to render_template :show
      expect(assigns(:user)).to eq user
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get :new
      expect(response).to render_template :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "GET 'create'" do
    it "returns http success" do
      user_hash = attributes_for(:user)
      expect do
        post :create, user: user_hash
      end.to change(User, :count).by(1)
      created_user = User.find_by(email: user_hash[:email])
      expect(created_user).to be
      expect(response).to redirect_to admin_user_path(created_user)
    end
  end

  describe "GET 'edit'" do
    let!(:user) {create(:user)}
    it "returns http success" do
      get :edit, id: user.id
      expect(response).to render_template :edit
      expect(assigns(:user)).to eq user
    end
  end

  describe "GET 'update'" do
    let!(:user){create(:user, name: 'taro')}
    it "returns http success" do
      patch :update, id: user.id, user: {name: 'jiro'}
      expect(response).to redirect_to admin_user_path(user)
      expect(user.reload.name).to eq 'jiro'
    end
  end

  describe "GET 'destroy'" do
    let!(:user){create(:user)}
    it "successfully user destory " do
      expect do
        delete :destroy, id: user.id
      end.to change(User, :count).by(-1)
      expect(User.find_by(email: user.email)).to_not be
      expect(response).to redirect_to admin_users_path
    end
  end
end
