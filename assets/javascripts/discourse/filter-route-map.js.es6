/**
 * Links the path `/filter` to a route named `filter`. Named like this, a
 * route with the same name needs to be created in the `routes` directory.
 */
export default function () {
  this.route('filter', { path: '/filters' });
}
