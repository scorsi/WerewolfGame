import "../css/app.css";

import "phoenix_html";

import "alpinejs";
import NProgress from "nprogress";
import {Socket} from "phoenix";
import {LiveSocket} from "phoenix_live_view";

let hooks = {
    AlpineComponentsHook: {
        actualizeAlpineComponent(el, force_rerender = false) {
            if (el.__x === undefined) {
                Alpine.initializeComponent(el);
            } else {
                const {$refs, $el, $nextTick, $watch, ...x_data} = el.__x.unobservedData;
                if (force_rerender || x_data !== el.getAttribute("x-data")) {
                    el.__x = undefined;
                    el.setAttribute("x-data", JSON.stringify(x_data));
                    Alpine.initializeComponent(el);
                }
            }
        },
        mounted() {
            this.actualizeAlpineComponent(this.el);
        },
        updated() {
            this.actualizeAlpineComponent(this.el);
        },
    }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: hooks, params: {_csrf_token: csrfToken}});

window.addEventListener("phx:page-loading-start", info => NProgress.start());
window.addEventListener("phx:page-loading-stop", info => NProgress.done());

liveSocket.connect();

window.liveSocket = liveSocket;

window.copyToClipboard = (el) => {
    el.select();
    el.setSelectionRange(0, 99999);
    document.execCommand("copy");
};
