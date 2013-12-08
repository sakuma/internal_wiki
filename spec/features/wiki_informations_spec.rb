require 'spec_helper'

feature 'wiki controler' do

  context 'general user' do

    let!(:user) {create(:user, name: 'admin')}
    let!(:wiki) {create(:public_wiki)}

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
      expect(page).to have_content wiki.name
    end

    scenario 'detail wiki page', js: true do
      visit root_path
      click_link wiki.name
      expect(page).to have_content wiki.name
    end

    scenario 'edit wiki page', js: true do
      visit root_path

      expect(page).to have_content wiki.name
      page.find_link(wiki.name).trigger(:mouseover)
      my_link = find(:xpath, "/html/body/div/div/div/div/div[1]/table/tbody/tr/td/div[3]/h4/a[1]/i")
      my_link.click

      expect(page).to have_content '公開ポリシー'
      expect(page).to have_content 'Wiki名'
    end

    scenario 'update wiki info', js: true do

      expect(page).to have_content wiki.name

      page.find_link(wiki.name).trigger(:mouseover)
      my_link = find(:xpath, "/html/body/div/div/div/div/div[1]/table/tbody/tr/td/div[3]/h4/a[1]/i")
      my_link.click

      expect(page).to have_content '公開ポリシー'
      expect(page).to have_content 'Wiki名'

      fill_in 'wiki_information_name', with: 'changed-wiki-name'
      click_button I18n.t('actions.update')

      expect(page).to have_content I18n.t('terms.updated_wiki')
    end

    scenario 'update private wiki info', js: true do
      expect(page).to have_content wiki.name

      page.find_link(wiki.name).trigger(:mouseover)
      my_link = find(:xpath, "/html/body/div/div/div/div/div[1]/table/tbody/tr/td/div[3]/h4/a[1]/i")
      my_link.click

      expect(page).to have_content '公開ポリシー'
      expect(page).to have_content 'Wiki名'

      select(I18n.t('terms.limited_publicity'), :from => 'wiki_information_is_private')

      expect(page).to have_content I18n.t('terms.private_members')
    end

    scenario 'delete wiki', js: true do
      expect(page).to have_content wiki.name

      page.find_link(wiki.name).trigger(:mouseover)
      my_link = find(:xpath, '/html/body/div/div/div/div/div[1]/table/tbody/tr/td/div[3]/h4/a[2]/i')
      my_link.click
      page.driver.accept_js_confirms!

      expect(page).to_not have_content wiki.name
    end
  end

  context 'guest user' do

    let!(:user) {create(:guest, name: 'guest admin')}
    let!(:wiki) {create(:public_wiki)}

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
      expect(page).to have_content wiki.name
    end

    scenario "don't edit wiki page", js: true do
      visit root_path
      expect(page).to have_content wiki.name

      page.find_link(wiki.name).trigger(:mouseover)
      expect(page).to_not have_xpath "/html/body/div/div/div/div/div[1]/table/tbody/tr/td/div[3]/h4/a[1]/i"
    end

    scenario "don't delete wiki", js: true do
      visit root_path
      expect(page).to have_content wiki.name

      page.find_link(wiki.name).trigger(:mouseover)
      expect(page).to_not have_xpath '/html/body/div/div/div/div/div[1]/table/tbody/tr/td/div[3]/h4/a[2]/i'
    end

    scenario 'detail wiki page', js: true do
      visit root_path
      click_link wiki.name
      expect(page).to have_content wiki.name
    end
  end

end
