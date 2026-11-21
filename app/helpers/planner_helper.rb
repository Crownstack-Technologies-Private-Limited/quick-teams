# Presentation helpers for the planner pages.
module PlannerHelper
  SLOT_MINUTES = 20

  # 1 slot => "20 min", 3 slots => "1h", 4 slots => "1h 20m" (spaced: "1 h", "1 h 20 m" as shown on the cards)
  def slot_duration_label(slots, spaced: false)
    total = slots.to_i * SLOT_MINUTES
    return "#{total} min" if total < 60

    hours, minutes = total.divmod(60)
    gap = spaced ? " " : ""
    minutes.positive? ? "#{hours}#{gap}h #{minutes}#{gap}m" : "#{hours}#{gap}h"
  end
end
