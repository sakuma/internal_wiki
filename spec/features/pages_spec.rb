require 'spec_helper'

feature 'pages controler' do

  let!(:wiki) {create(:public_wiki)}
  let!(:wiki_page) {create(:page, wiki_information: wiki, name: 'sample page name')}

  context 'general user' do
    let!(:user) {create(:user, name: 'admin')}

    background do
      visit login_path
      click_link I18n.t('actions.switch_password_login')
      within("#original-login-area") do
        fill_in 'email_or_name', with: user.email
        fill_in 'password', with: 'password'
      end
      click_button I18n.t('terms.login')
    end

    scenario 'render index page', js: true do
      click_link wiki.name
      click_link I18n.t('terms.index_page')
      expect(page).to have_content 'sample page name'
    end

    scenario 'render detail page', js: true do
      visit pages_path(wiki_name: wiki.name)
      click_link wiki_page.name
      expect(page).to have_content 'sample page name'
    end

    scenario 'edit page', js: true do
      visit page_path(wiki_name: wiki.name, page_name: wiki_page.url_name)
      find('#edit-page-icon').click
      expect(find('#edit-page-name').value).to eq wiki_page.name
      expect(find('#edit-page-url-name').value).to eq wiki_page.url_name
    end

    scenario 'update page', js: true do
      visit edit_page_path(wiki_name: wiki.name, page_name: wiki_page.url_name)
      expect(find('#edit-page-name').value).to eq wiki_page.name
      expect(find('#edit-page-url-name').value).to eq wiki_page.url_name
      fill_in 'edit-page-name', with: 'rename page'
      click_button I18n.t('actions.update')
      expect(page).to have_content 'rename page'
    end

    scenario 'new page', js: true do
      visit wiki_info_path(wiki_name: wiki.name)
      expect(page).to have_content wiki.name

      click_link I18n.t('terms.new_page')
      expect(find('#new-page-name').value).to be_empty
      expect(find('#new-page-url-name').value).to be_empty
    end

    scenario 'create page', js: true do
      visit new_page_path(wiki_name: wiki.name)
      fill_in 'new-page-url-name', with: 'new-page-name'
      fill_in 'new-page-name', with: 'new page name'
      click_button I18n.t('actions.regist')
      expect(page).to have_content 'new page name'
    end

    scenario 'delete wiki', js: true do
      visit page_path(wiki_name: wiki.name, page_name: wiki_page.url_name)
      expect(page).to have_content wiki_page.name
      find('#destory-page-icon').click
      expect(page).to_not have_content wiki_page.name
    end

    scenario "don't delete home page(welcome page)", js: true do
      click_link wiki.name
      expect(page).to have_content 'Welcome'
      expect(page).to_not have_css('#destory-page-icon')
    end
  end

  context 'guest user' do
    let!(:user) {create(:guest, name: 'guest')}

    background do
      wiki.visible_users << user
      visit login_path
      click_link I18n.t('actions.switch_password_login')
      within("#original-login-area") do
        fill_in 'email_or_name', with: user.email
        fill_in 'password', with: 'password'
      end
      click_button I18n.t('terms.login')
    end

    scenario 'render index page', js: true do
      click_link wiki.name
      click_link I18n.t('terms.index_page')
      expect(page).to have_content 'sample page name'
    end

    scenario 'render detail page', js: true do
      visit pages_path(wiki_name: wiki.name)
      click_link wiki_page.name
      expect(page).to have_content 'sample page name'
    end

    scenario 'edit page', js: true do
      visit page_path(wiki_name: wiki.name, page_name: wiki_page.url_name)
      find('#edit-page-icon').click
      expect(find('#edit-page-name').value).to eq wiki_page.name
      expect(find('#edit-page-url-name').value).to eq wiki_page.url_name
    end

    scenario 'update page', js: true do
      visit edit_page_path(wiki_name: wiki.name, page_name: wiki_page.url_name)
      expect(find('#edit-page-name').value).to eq wiki_page.name
      expect(find('#edit-page-url-name').value).to eq wiki_page.url_name
      fill_in 'edit-page-name', with: 'rename page'
      click_button I18n.t('actions.update')
      expect(page).to have_content 'rename page'
      expect(page).to have_content "Last edited by #{user.name}"
    end

    scenario 'new page', js: true do
      visit wiki_info_path(wiki_name: wiki.name)
      expect(page).to have_content wiki.name

      click_link I18n.t('terms.new_page')
      expect(find('#new-page-name').value).to be_empty
      expect(find('#new-page-url-name').value).to be_empty
    end

    scenario 'create page', js: true do
      visit new_page_path(wiki_name: wiki.name)
      fill_in 'new-page-url-name', with: 'new-page-name'
      fill_in 'new-page-name', with: 'new page name'
      click_button I18n.t('actions.regist')
      expect(page).to have_content 'new page name'
    end

    scenario 'delete wiki', js: true do
      visit page_path(wiki_name: wiki.name, page_name: wiki_page.url_name)
      expect(page).to have_content wiki_page.name
      expect(page).to_not have_css('#destory-page-icon')
    end
  end

  # TODO: 履歴 ページ 、ファイル添付
end
