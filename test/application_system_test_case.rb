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
  driven_by :selenium, using: :chrome, screen_size: [1440, 900] do |options|
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)
    options.add_preference("profile.password_manager_leak_detection", false)
    options.add_argument("--disable-features=PasswordLeakDetection,PasswordManagerOnboarding")
  end

  # StimulusReflex wires up [data-reflex] elements from a debounced (20ms) MutationObserver.
  # Clicking a freshly inserted element (e.g. a search result) before that happens skips the
  # reflex, so wait until the element carries the stimulus-reflex action.
  # A morph from an earlier reflex also strips and re-adds that action, so let the observer settle
  # and look the element up again before clicking.
  def click_reflex(selector, **options)
    wired = "#{selector}[data-action*='stimulus-reflex#__perform']"
    find(wired, match: :first, **options)
    sleep 0.1
    find(wired, match: :first, **options).click
  end
end
