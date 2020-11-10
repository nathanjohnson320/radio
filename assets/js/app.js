// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.css';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import 'phoenix_html';
import { Socket } from 'phoenix';
import NProgress from 'nprogress';
import Castjs from './cast.js';
import { LiveSocket } from 'phoenix_live_view';

let hooks = {
  AudioVolume: {
    changeVolume(e) {
      this.player.volume = e.target.value;
    },
    mounted() {
      this.changeVolume = this.changeVolume.bind(this);

      this.player = document.querySelector('#player');
      this.el.addEventListener('input', this.changeVolume);
      this.el.value = this.player.volume;
    },
    destroyed() {
      this.el.removeEventListener('input', this.changeVolume);
    }
  },
  AudioPlayPause: {
    mute() {
      this.playIcon.classList.remove('hidden');
      this.pauseIcon.classList.add('hidden');
      this.player.muted = true;
    },
    unmute() {
      this.pauseIcon.classList.remove('hidden');
      this.playIcon.classList.add('hidden');
      this.player.muted = false;
    },
    togglePlaying() {
      this.playing = !this.playing;

      if (!this.playing) {
        this.mute();
      } else {
        this.unmute();
      }
      this.pushEvent('toggle_playing', { playing: this.playing });
    },
    mounted() {
      this.togglePlaying = this.togglePlaying.bind(this);
      this.mute = this.mute.bind(this);
      this.unmute = this.unmute.bind(this);

      this.playing = this.el.dataset.playing === 'true';
      this.playIcon = document.querySelector('#play-icon');
      this.pauseIcon = document.querySelector('#pause-icon');
      this.loadingIcon = document.querySelector('#loading-icon');
      this.player = document.querySelector('#player');
      this.el.addEventListener('click', this.togglePlaying);

      this.player.onplaying = () => {
        this.loadingIcon.classList.add('hidden');
        this.unmute();
      };

      this.player.onloadstart = () => {
        this.loadingIcon.classList.add('block');
        this.loadingIcon.classList.remove('hidden');
        this.pauseIcon.classList.remove('block');
        this.pauseIcon.classList.add('hidden');
        this.playIcon.classList.remove('block');
        this.playIcon.classList.add('hidden');
      };
    },
    destroyed() {
      this.el.removeEventListener('click', this.togglePlaying);
    }
  },
  Cast: {
    mounted() {
      // Create new Castjs instance
      const cjs = new Castjs();

      cjs.on('error', (e) => {
        console.log(e);
      });

      if (!cjs.available) {
        this.el.disabled = true;
        this.el.classList.add('opacity-50');
        this.el.classList.add('cursor-not-allowed');
      }

      this.el.addEventListener('click', () => {
        if (cjs.available) {
          const url = document.getElementById('player').src;
          cjs.cast(url.replace('localhost', this.el.dataset.url));
        };
      });
    },
  }
};

let csrfToken = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks,
});

// Show progress bar on live navigation and form submits
window.addEventListener('phx:page-loading-start', (info) => NProgress.start());
window.addEventListener('phx:page-loading-stop', (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
