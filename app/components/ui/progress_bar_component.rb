# frozen_string_literal: true

module Ui
  # Labelled score bar: green from 80%, yellow from 50%, red below.
  #
  #   render Ui::ProgressBarComponent.new(title: "Communication", score: 7.5, scale: 10)
  class ProgressBarComponent < ViewComponent::Base
    def initialize(title:, score:, scale:)
      @title = title
      @score = score
      @scale = scale
    end

    def percentage = (@score / @scale) * 100

    def color
      if percentage >= 80 then "green"
      elsif percentage >= 50 then "yellow"
      else "red"
      end
    end
  end
end
