# frozen_string_literal: true

# Server side of the `data-reflex` actions (formerly StimulusReflex, now plain HTTP + Turbo Streams).
#
# A view declares `data-reflex="click->ProjectStatus#change"` plus `data-*` attributes; the
# reflex_actions.js shim posts those attributes to ReflexActionsController, which runs
# ProjectStatusReflex#change. Inside an action:
#
#   element.dataset["project-id"]     # the element's data attributes (dashed or underscored keys)
#   current_user                      # the signed-in user (tenant set by AccountMiddleware)
#   morph "#project-status", render(partial: "project/status", locals: { project: project })
#
# `morph` becomes a morphing Turbo Stream: it replaces the target when the rendered HTML's root
# element has the target's id, otherwise it updates the target's contents (StimulusReflex's
# selector morph rules). An action that calls no `morph` re-renders the whole page with
# morphing, like a StimulusReflex page morph.
class ApplicationReflex
  include ActionView::RecordIdentifier

  # The `data-*` attributes sent by the browser. Keys are normalised so `dataset["project-id"]`,
  # `dataset[:project_id]` and `dataset["project_id"]` all work, as they did with StimulusReflex.
  class Dataset
    def initialize(attributes)
      @attributes = attributes.to_h.to_h { |key, value| [normalize(key), value.to_s] }
    end

    def [](key)
      @attributes[normalize(key)]
    end

    def to_h
      @attributes.dup
    end

    private

    def normalize(key)
      key.to_s.tr("_", "-")
    end
  end

  Element = Struct.new(:dataset)

  attr_reader :element, :streams

  delegate :current_user, to: :@controller

  def initialize(controller, dataset)
    @controller = controller
    @element = Element.new(Dataset.new(dataset))
    @streams = []
  end

  def morph(selector, html)
    target = selector.to_s.delete_prefix("#")
    html = html.to_s
    root = Nokogiri::HTML5.fragment(html).element_children.first
    action = root && root["id"] == target ? :replace : :update
    @streams << @controller.helpers.turbo_stream.public_send(action, target, html.html_safe, method: :morph)
  end

  def render(*args, **options)
    @controller.render_to_string(*args, formats: [:html], layout: false, **options)
  end
end
