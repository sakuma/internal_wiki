require 'spec_helper'

feature 'users controller' do

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

  scenario 'render setting page', js: true do
    find('.dropdown-toggle').click
    click_link I18n.t('terms.setting')
    expect(page).to have_content I18n.t('terms.setting')
    expect(find('#user_name').value).to eq user.name
    expect(find('#user_email').value).to eq user.email
  end

  scenario 'update account', js: true do
    visit user_setting_path
    fill_in 'user_name', with: 'changed user name'
    fill_in 'user_email', with: 'changed email'
    click_button I18n.t('actions.update')
    expect(page).to have_content I18n.t('terms.updated_user_info')
    expect(find('#user_name').value).to eq 'changed user name'
    expect(find('#user_email').value).to eq 'changed email'
  end
end
