require 'spec_helper'

feature 'admin users controller' do

  let!(:admin_user) {create(:admin_user)}
  let!(:user) {create(:user)}
  let!(:guest) {create(:guest)}

  background do
    visit login_path
    click_link I18n.t('actions.switch_password_login')
    within("#original-login-area") do
      fill_in 'email_or_name', with: admin_user.email
      fill_in 'password', with: 'password'
    end
    click_button I18n.t('terms.login')
  end

  scenario 'render user manage page', js: true do
    find('.dropdown-toggle').click
    click_link I18n.t('terms.user_control')
    expect(page).to have_content I18n.t('terms.admin_user_index')
    expect(page).to have_content user.name
    expect(page).to have_content guest.name
  end

  context 'on index page' do
    scenario 'render edit user account', js: true do
      visit admin_users_path
      page.find_link(user.name).trigger(:mouseover)
      find('.edit_user_button').click
      expect(page).to have_content I18n.t('actions.editing_of', target: User.model_name.human)
      expect(find('#user_name').value).to eq user.name
    end

    scenario 'lock user account', js: true do
      visit admin_users_path
      page.find_link(user.name).trigger(:mouseover)
      find('.lock_user_button').click
      page.driver.accept_js_confirms!
      expect(page).to have_content I18n.t('terms.locked_user_info')
    end

    scenario "don't lock my account", js: true do
      visit admin_users_path
      page.find_link('myself').trigger(:mouseover)
      expect(page).to_not have_css('.lock_user_button')
    end

    context 'locked user' do
      scenario 'unlock user account', js: true do
        user.destroy # soft delete
        visit admin_users_path
        find('.unlock-user-button').click
        page.driver.accept_js_confirms!
        expect(page).to have_content I18n.t('terms.unlocked_user_info')
      end

      scenario 'delete user account', js: true do
        user.destroy # soft delete
        visit admin_users_path
        find('.destroy-user-button').click
        page.driver.accept_js_confirms!
        expect(page).to have_content I18n.t('terms.deleted_user_info')
      end
    end

    # TODO:
    # context 'inviting user' do
      # scenario 'invite user', js: true
    # end
  end

  scenario 'update user info', js: true do
    visit edit_admin_user_path(user)
    expect(page).to have_content I18n.t('actions.editing_of', target: User.model_name.human)
    expect(find('#user_name').value).to eq user.name

    fill_in 'user_name', with: "マグマ大使"
    click_button I18n.t('actions.update')
    expect(page).to have_content I18n.t('terms.updated_user_info')
    expect(page).to have_content "マグマ大使"
  end

  context 'on show page' do
    scenario 'render detail user info', js: true do
      visit admin_users_path
      click_link user.name
      expect(page).to have_content user.name
      expect(page).to have_content user.email
    end
    scenario 'render edit user page', js: true do
      visit admin_user_path(user)
      find('.edit_user_button').click
      expect(page).to have_content I18n.t('actions.editing_of', target: User.model_name.human)
      expect(find('#user_name').value).to eq user.name
    end

    scenario 'lock user account', js: true do
      visit admin_user_path(user)
      find('.lock_user_button').click
      page.driver.accept_js_confirms!
      expect(page).to have_content I18n.t('terms.locked_user_info')
    end

    scenario "don't lock or destory for my account by myself", js: true do
      visit admin_user_path(admin_user)
      expect(page).to have_content admin_user.name
      expect(page).to have_content admin_user.email
      expect(page).to_not have_css('.lock_user_button')
    end
    # TODO:
    # scenario 'visibile wiki', js: true
  end

  # context 'guest user' do
    # scenario 'update geest user account', js: true
  # end
end
