// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import FastClick from 'fastclick'
import router from './router/index'
import App from './App'
import Home from './components/login.vue'
import Game from './components/game.vue'
import VueResource from 'vue-resource'
//import { AjaxPlugin } from 'vux'
Vue.use(VueResource)
//Vue.use(AjaxPlugin)


FastClick.attach(document.body)

/* eslint-disable no-new */
new Vue({
  router,
  render: h => h(App)
}).$mount('#app-box')
