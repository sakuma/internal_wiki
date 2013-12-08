require 'spec_helper'

feature 'login' do

  let!(:user) {create(:user)}

  scenario 'render login page' do
    visit login_path
    expect(page).to have_content I18n.t('terms.login')
    expect(page).to have_content I18n.t('actions.switch_password_login')
  end

  scenario 'switch password login view', js: true do
    visit login_path
    expect(page).to have_content I18n.t('terms.login')
    click_link I18n.t('actions.switch_password_login')
    expect(page).to have_content I18n.t('actions.switch_google_login')
  end

  scenario 'switch password login view', js: true do
    visit login_path
    expect(page).to have_content I18n.t('terms.login')
    click_link I18n.t('actions.switch_password_login')
    expect(page).to have_content I18n.t('actions.switch_google_login')
  end

  scenario 'successfully login', js: true do
    visit login_path
    click_link I18n.t('actions.switch_password_login')
    within("#original-login-area") do
      fill_in 'email_or_name', with: user.email
      fill_in 'password', with: 'password'
    end
    click_button I18n.t('terms.login')
    expect(page).to have_content I18n.t('terms.successfully_login')
  end

  scenario 'failed login', js: true do
    visit login_path
    click_link I18n.t('actions.switch_password_login')
    within("#original-login-area") do
      fill_in 'email_or_name', with: user.email
      fill_in 'password', with: 'wrongpassword'
    end
    click_button I18n.t('terms.login')
    expect(page).to have_content I18n.t('terms.invalid_email_or_name_or_password')
  end

  scenario 'successfully login after change password', js: true do
    visit login_path
    click_link I18n.t('actions.switch_password_login')
    within("#original-login-area") do
      fill_in 'email_or_name', with: user.email
      fill_in 'password', with: 'password'
    end
    click_button I18n.t('terms.login')
    visit user_setting_path
    fill_in 'user_password', with: 'changedpass'
    fill_in 'user_password_confirmation', with: 'changedpass'
    click_button I18n.t('actions.update')

    # 再ログイン
    find('.dropdown-toggle').click
    click_link I18n.t('terms.logout')
    visit login_path
    click_link I18n.t('actions.switch_password_login')
    within("#original-login-area") do
      fill_in 'email_or_name', with: user.email
      fill_in 'password', with: 'changedpass'
    end
    click_button I18n.t('terms.login')
    expect(page).to have_content I18n.t('terms.successfully_login')
  end
end
