# frozen_string_literal: true

# name: discourse-location-filter
# about: adds /filters page for users to sign up for site wide filters on post location
# version: 1.0
# authors: Oliver Walker
# url: https://github.com/hms-networks/discourse-location-filters

enabled_site_setting :filters_enabled

register_asset 'stylesheets/filters.css'

load File.expand_path('../app/filter_store.rb', __FILE__)

after_initialize do
  load File.expand_path('../app/controllers/filter_controller.rb', __FILE__)

  Discourse::Application.routes.append do
    get '/filter' => 'filters#index'

    get '/filters' => 'filter#index'
    put '/filters/:filter_id' => 'filter#update'
    delete '/filters/:filter_id' => 'filter#destroy'
  end
 # LocationFilter.filter_on_user
end
