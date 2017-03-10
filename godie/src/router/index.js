import Vue from 'vue'
import Router from 'vue-router'
import Home from 'components/login'
import Game from 'components/game'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Home',
      component: Home
    },
    {
      path:'/game/:user',
      name:'Game',
      component: Game
    }
  ]
})
