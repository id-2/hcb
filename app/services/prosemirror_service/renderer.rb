# frozen_string_literal: true

module ProsemirrorService
  class Renderer
    CONTEXT_KEY = :prosemirror_service_render_context
    CUSTOM_NODES = {
      donationGoal: ProsemirrorService::DonationGoalNode,
      hcbCode: ProsemirrorService::HcbCodeNode,
      donationSummary: ProsemirrorService::DonationSummaryNode
    }

    class << self
      def with_context(new_context, &)
        old_context = context
        Fiber[CONTEXT_KEY] = new_context

        yield
      ensure
        Fiber[CONTEXT_KEY] = old_context
      end

      def context
        Fiber[CONTEXT_KEY]
      end

      def render_html(json, event, is_email: false, single_node: false)
        @renderer ||= create_renderer

        content = ""
        with_context({ event:, is_email: }) do
          content = @renderer.render json
        end

        if single_node
          parsed = Nokogiri::HTML.parse(content)

          # We want to get rid of the parent div of the node
          # Nokogiri adds basic HTML structure, so the structure is document -> html -> body -> div -> content
          parsed.children.children.children.children.to_s
        else
          <<-HTML.chomp
            <div class="pm-content">
              #{content}
            </div>
          HTML
        end
      end

      def render_custom_node(node, event)
        if CUSTOM_NODES.keys.include? node["type"].to_sym
          if node["attrs"].nil?
            node["attrs"] = {}
          end

          node["attrs"]["html"] = render_html({ content: [node] }, event, single_node: true)
        elsif node["content"].present? && node["content"].size > 0
          node["content"] = node["content"].map do |child|
            render_custom_node child
          end
        end

        node
      end

      def create_renderer
        renderer = ProsemirrorToHtml::Renderer.new

        CUSTOM_NODES.each_value do |node|
          renderer.add_node node
        end

        renderer
      end

    end

  end
end
