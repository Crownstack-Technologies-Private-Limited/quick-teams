require "test_helper"

# Chrome 159+ rejects the wildcard origin Capybara 3.40 passes to Storage.clearDataForOrigin when it resets
# the session between tests, so cookies (and the signed-in user) leaked into the next test. Fall back to
# clearing all cookies and the app origin's storage.
module ChromeResetWithoutWildcardOrigin
  def reset!
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => e
    raise unless e.message.include?("is not a valid URL")

    execute_cdp("Network.clearBrowserCookies")
    server = Capybara.current_session.server
    execute_cdp("Storage.clearDataForOrigin", origin: server.base_url, storageTypes: "cookies,local_storage") if server
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetWithoutWildcardOrigin)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Fixture users sign in with "password"; Chrome's password manager then shows its leaked-password
  # warning over the page, which swallowed every click of the next test. Turn that UI off.
  #
  # Headless by default (the suite runs in parallel); HEADED=1 opens a visible Chrome to watch a test.
  driven_by :selenium, using: (ENV["HEADED"].present? ? :chrome : :headless_chrome), screen_size: [1440, 900] do |options|
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)
    options.add_preference("profile.password_manager_leak_detection", false)
    options.add_argument("--disable-features=PasswordLeakDetection,PasswordManagerOnboarding")
    # Linux CI containers: Chrome cannot use the sandbox or the small /dev/shm there.
    if ENV["CI"].present?
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
    end
  end

  # Clicks a data-reflex element once no earlier reflex action is still in flight (reflex_actions.js
  # marks <html data-reflex-busy> while one runs).
  def click_reflex(selector, **options)
    assert_no_selector "html[data-reflex-busy]", visible: :all
    find(selector, match: :first, **options).click
  end
end
