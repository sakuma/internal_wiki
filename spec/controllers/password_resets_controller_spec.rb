require 'spec_helper'

describe PasswordResetsController do

  describe "GET 'new'" do
    let!(:user) {create(:user)}
    it "returns http success" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "GET 'create'" do
    let!(:user) {create(:user)}
    it "returns http success" do
      post :create, email: user.email
      expect(response).to redirect_to root_path
    end
  end

  describe "GET 'edit'" do
    let!(:user) do
      u = create(:user)
      u.tap(&:deliver_reset_password_instructions!)
    end
    it "returns http success" do
      get :edit, id: user.reset_password_token
      expect(response).to render_template :edit
    end
  end

  describe "GET 'update'" do
    let!(:user) do
      u = create(:user)
      u.tap(&:deliver_reset_password_instructions!)
    end
    it "returns http success" do
      patch :update, id: user.reset_password_token, user: {password: 'hoge', password_confirmation: 'hoge'}
      expect(response).to redirect_to root_path
    end
  end

end
