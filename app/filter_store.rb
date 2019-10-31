class FilterStore
  class << self
    def get_filter
      PluginStore.get('filters', 'filters') || {}
    end

    def add_filter(filter_id, filter)
      filters = get_filter()
      filters[filter_id] = filter
      PluginStore.set('filters', 'filters', filters)

      filter
    end

    def remove_filter(filter_id)
      filters = get_filter()
      filters.delete(filter_id)
      PluginStore.set('filters', 'filters', filters)
    end
  end
end
