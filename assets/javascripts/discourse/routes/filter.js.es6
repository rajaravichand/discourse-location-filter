/**
 * Route for the path `/filter` as defined in `../filter-route-map.js.es6`.
 */
export default Discourse.Route.extend({
  renderTemplate() {
    // Renders the template `../templates/filters.hbs`
    this.render('filter');
  },
  //makes this accessable in the controller as model
  model(){
  return Discourse.User.current();
  }
});
