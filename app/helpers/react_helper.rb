# https://github.com/reactjs/react-rails/pull/166#issuecomment-86178980
# This allows a react component to render an erb block as children
module ReactHelper
  def react_component_with_children(name, args = {}, options = {}, &block)
    args[:__html] = capture(&block) if block.present?
    react_component(name, args, options, &block)
  end
end