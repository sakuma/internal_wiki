require 'spec_helper'

describe 'login' do
  specify 'render login page' do
    visit login_path
    expect(page).to have_content I18n.t('terms.login')
    expect(page).to have_content I18n.t('actions.switch_password_login')
  end

  specify 'switch password login view', js: true do
    visit login_path
    expect(page).to have_content I18n.t('terms.login')
    click_link I18n.t('actions.switch_password_login')
    expect(page).to have_content I18n.t('actions.switch_google_login')
  end
end
