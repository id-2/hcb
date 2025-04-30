# frozen_string_literal: true

module AdminHelper
  def tooltip(direction = nil, partial = nil, &block)
    content_tag(:span, class: "task__tooltip #{"task__tooltip--#{direction}" if direction}") do
      partial || block.call
    end
  end

  def tooltipped_text(text, direction = nil, partial = nil, &block)
    content_tag(:span) do
      content_tag(:span, text) + tooltip(direction, partial, &block)
    end
  end

  def render_event(event)
    render(partial: "admin/tasks/cards/event", locals: { event: })
  end

  def render_user(user)
    render(partial: "admin/tasks/cards/user", locals: { user: })
  end

  def render_recipient(recipient)
    render(partial: "admin/tasks/cards/recipient", locals: { recipient: })
  end

end
