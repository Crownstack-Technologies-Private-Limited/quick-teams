require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1440, 900]

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
