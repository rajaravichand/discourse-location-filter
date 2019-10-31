require_dependency 'topic_query'
require 'json'

module LocationFilter
  include CurrentUser

  #not sure how else to do this.. just need to be sure :location exists
  def self.clean_custom_filters
    TopicQuery.add_custom_filter(:location) do |results, topic_query|
      results
    end
    TopicQuery.remove_custom_filter(:location)
  end

  def self.plugin_name
    'filters'.freeze
  end

  def self.plugin_key
    'filters'.freeze
  end

  def self.pstore_get
    PluginStore.get(LocationFilter.plugin_name, LocationFilter.plugin_key)
  end

  def self.north_america
    return [
      'us', # united states
      'ca' #canada
    ]
  end

  def self.south_america
    return [
      'mx', # Mexico
      'gt', # Guatemala
      'cu', # Cuba
      'do' # Dominican Republic
    ]
  end


  def self.add_country_to_sql(country)
    return " topics.id = tc.topic_id AND
             tc.name = 'location' AND
             tc.value LIKE '%countrycode\":\"#{country}\"%'"
  end

  def filter_on_user

    # need to keep track if any queue has already been added to sql
    # so that i know if an additional OR clause is needed at the start of next queue
    na_queue_added = false
    sa_queue_added = false

    #this would be retrieve from current user
    user_id = current_user.id.to_s

    # get all filters in a ruby hash. filter example below
    # {"1571409423332":{"id":"1571409423332","content":"south-america","user_id":"1"},
    #  "1571413335612":{"id":"1571413335612","content":"north-america","user_id":"1"}}
    user_filters = LocationFilter.pstore_get

    sql_string = "JOIN topic_custom_fields tc ON"

    user_filters.each do |key, value|
      filter_content = value['content']
      filter_user_id = value['user_id']

      # binding.pry

      # only apply for current user
      if user_id == filter_user_id
        if filter_content == 'north-america'

          # for each country in north america queue
          LocationFilter.north_america.each do |country|

            # need this check here for if sa filter is added before na filter in plugin store keys
            if country == LocationFilter.north_america.first
              if sa_queue_added
                sql_string += " OR"
              end
            end
            sql_string += LocationFilter.add_country_to_sql(country)
            if country != LocationFilter.north_america.last
              sql_string += " OR"
            end
            na_queue_added = true
          end
        end

        if filter_content == 'south-america'

          # for each country in south america queue
          LocationFilter.south_america.each do |country|

            if country == LocationFilter.south_america.first
              if na_queue_added
                sql_string += " OR"
              end
            end

            sql_string += LocationFilter.add_country_to_sql(country)
            if country != LocationFilter.south_america.last
              sql_string += " OR"
            end
            sa_queue_added = true
          end
        end
      end
    end

     # binding.pry
    # make sure the filter is not empty
    if  na_queue_added or sa_queue_added
      TopicQuery.add_custom_filter(:location) do |results, topic_query|
      # binding.pry
        results = results.joins(sql_string)
        results
      end
    end

  end
end # end module

class FilterController < ApplicationController
  include LocationFilter
  def index
    filter = FilterStore.get_filter()

    render json: { filters: filter.values }
  end

  # get just the filter for the user that is logged in
  def get_filter

  end

  def update
    filter_id = params[:filter_id]
    user_id = params[:filter][:user_id]
    content = params[:filter][:content]
    filter = {
      'id' => filter_id,
      'content' => content,
      'user_id' => user_id
    }

    FilterStore.add_filter(filter_id, filter)

    LocationFilter.clean_custom_filters
    filter_on_user
    render json: { filter: filter }
  end

  def destroy
    LocationFilter.clean_custom_filters
    FilterStore.remove_filter(params[:filter_id])

    render json: success_json
  end

end
