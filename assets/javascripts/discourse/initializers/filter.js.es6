import { withPluginApi } from "discourse/lib/plugin-api";
import { h } from "virtual-dom";


function initialize(api) {
}

export default {
  name: "filter",
  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");
    if (!siteSettings.assign_enabled) {
      return;
    }

    withPluginApi("0.8.32", api => initialize(api, container));
  }
};
