# frozen_string_literal: true

module ProsemirrorService
  class Renderer
    def self.render_html(json, event)
      @renderer ||= create_renderer
      $PROSEMIRROR_RENDERER_EVENT = event

      @renderer.render JSON.parse(json)
    end

    def self.create_renderer
      renderer = ProsemirrorToHtml::Renderer.new
      renderer.add_node ProsemirrorService::MissionStatementNode

      renderer
    end

  end
end
