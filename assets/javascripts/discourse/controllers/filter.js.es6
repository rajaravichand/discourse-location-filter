import { default as computed } from 'ember-addons/ember-computed-decorators';
export default Ember.Controller.extend({

  init() {
    this._super();
    this.set('filters', []);
    this.fetchFilters();
  },
  is_filter: false,
  /**
  this currently grabs all filters and than only displays the filters for the current user
  using the equals helper in the filter.hbs file. this is inefficient. Could probably
  filter on the backend and not serve up all filters.

  it also shouldn't matter i guess. setting only should be changed once and only for mods.
  */
  fetchFilters() {
    this.store.findAll('filter')
      .then(result => {
        for (const filter of result.content) {
          this.filters.pushObject(filter);
        }
      })
      .catch(console.error);
  },
  @computed()
  get_filtable() {
    this.is_filter = this.get('model.admin') || this.get('model.moderator');
    return this.is_filter;
  },

  actions: {
    createFilter(content) {
      if (!content) {
        return;
      }

      const filterRecord = this.store.createRecord('filter', {
          // set the id to the current data as an int so they are all unique
          id: Date.now(),
          content: content,
          // model.id is the current user ID
           user_id: this.get("model.id")
      });

      filterRecord.save()
        .then(result => {
          this.filters.pushObject(result.target);
        })
        .catch(console.error);
    },

    deleteFilter(filter) {
      this.store.destroyRecord('filter', filter)
        .then(() => {
          this.filters.removeObject(filter);
        })
        .catch(console.error);
    }
  }

});
