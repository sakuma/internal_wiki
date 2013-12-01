require 'spec_helper'

describe PagesController do

  let!(:wiki){create(:wiki)}
  before do
    @admin_user = create(:admin_user)
    login_user(@admin_user)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, wiki_name: wiki.name
      expect(response).to render_template :index
    end
  end

  describe "GET 'show'" do
    let!(:page){create(:page, wiki_information_id: wiki.id)}
    it "returns http success" do
      get :show, wiki_name: wiki.name, page_name: page.url_name
      expect(response).to render_template :show
      expect(assigns(:page)).to eq page
    end
  end

  describe "GET 'edit'" do
    let!(:page){create(:page, wiki_information_id: wiki.id)}
    it "returns http success" do
      get :edit, wiki_name: wiki.name, page_name: page.url_name
      expect(response).to render_template :edit
      expect(assigns(:page)).to eq page
    end
  end

  describe "GET 'update'" do
    let!(:page){create(:page, wiki_information_id: wiki.id, name: 'before page name')}
    it "returns http success" do
      patch :update, wiki_name: wiki.name, page_name: page.url_name, page: {page_name: page.url_name, name: 'after page name'}
      expect(response).to redirect_to page_path(wiki_name: wiki.name, page_name: page.url_name)
      expect(assigns(:page).name).to eq 'after page name'
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get :new, wiki_name: wiki.name
      expect(response).to render_template :new
      expect(assigns(:page)).to be_a_new(Page)
    end
  end

  describe "GET 'create'" do
    let!(:page_attr){attributes_for(:page, name: 'created page')}
    it "returns http success" do
      expect do
        post :create, wiki_name: wiki.name, page: page_attr
      end.to change(Page, :count).by(1)
      expect(response).to redirect_to page_path(wiki_name: wiki.name, page_name: page_attr[:url_name])
    end
  end

  describe "GET 'help'" do
    it "returns http success" do
      get :help, wiki_name: wiki.name
      expect(response).to render_template :help
    end
  end

  describe "GET 'destroy'" do
    let!(:wiki){create(:wiki)}
    let!(:welcome_page){wiki.pages.find_by(url_name: 'welcome')}
    let!(:page){create(:page, wiki_information_id: wiki.id, name: 'destroy name')}
    it "returns http success" do
      expect do
        delete :destroy, wiki_name: wiki.name, page_name: page.url_name
      end.to change(Page, :count).by(-1)
      expect(response).to redirect_to wiki_info_path(wiki_name: wiki.name)
    end

    it "don't destroy welcome page" do
      expect do
        delete :destroy, wiki_name: wiki.name, page_name: welcome_page.url_name
      end.to_not change(Page, :count).by(-1)
      expect(response).to redirect_to wiki_info_path(wiki_name: wiki.name)
    end
  end

  describe "GET 'preview'" do
    let!(:page){create(:page, wiki_information_id: wiki.id, name: 'destroy name')}
    it "returns http success" do
      get :preview, wiki_name: wiki.name, page_name: page.url_name
      response.should be_success
    end
  end

  # describe "GET 'list_view_index'" do
  #   it "returns http success" do
  #     get 'list_view_index'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'globe_view_index'" do
  #   it "returns http success" do
  #     get 'globe_view_index'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'attachment'" do
  #   it "returns http success" do
  #     get 'attachment'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'file_upload'" do
  #   it "returns http success" do
  #     get 'file_upload'
  #     response.should be_success
  #   end
  # end

  # describe "GET 'file_destroy'" do
  #   it "returns http success" do
  #     get 'file_destroy'
  #     response.should be_success
  #   end
  # end


end
