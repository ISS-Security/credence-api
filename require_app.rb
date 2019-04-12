# frozen_string_literal: true

# Requires all ruby files in specified app folders
# Params:
# - (opt) folders: Array of root folder names, or String of single folder name
# Usage:
#  require_app
#  require_app('config')
#  require_app(['config', 'models'])
def require_app(folders = %w[models controllers])
  list = Array(folders)
         .map { |folder| "app/#{folder}" }
         .join(',')
  Dir.glob("./{config,#{list}}/**/*.rb").each do |file|
    require file
  end
end
