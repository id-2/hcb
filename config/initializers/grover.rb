Grover.configure do |config|
  config.use_pdf_middleware  = true
  config.use_png_middleware  = false
  config.use_jpeg_middleware = false

  config.root_url = Rails.application.routes.default_url_options[:host]

  config.options = {
    executable_path: '/usr/bin/chromium',
    launch_args: ["--font-render-hinting=medium", "--no-sandbox"],
    format: 'Letter',
  }
end