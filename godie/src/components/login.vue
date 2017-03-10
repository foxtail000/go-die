<template>
  <div>
    <div class="login">
      <img class="logo" src="../assets/vux_logo.png">
      <h1> 去死吧你 </h1>
    </div>
    <group class="login-group">
      <x-switch title="新用户" v-model="old"></x-switch>
      <x-input title="用户名"  v-model="name"></x-input>
      <x-input title="角色名"  v-if="old" v-model="cname"></x-input>
      <selector title="性别" placeholder="请选择性别" :options="list" v-model="sex" v-if="old"></selector>
    </group>
    <alert v-model="show" title="搞笑" @on-show="onShow" @on-hide="onHide">'能把要填的填了吗?'</alert>
    <x-button @click.native="start">进入游戏</x-button>
  </div>
</template>

<script>
  import { Group,XSwitch, XButton, XInput, Alert,Selector } from 'vux'
  export default {
    components: {
      Group,
      XSwitch,
      XButton,
      XInput,
      Alert,
      Selector
    },
    data () {
      return {
        list: [{key: '0', value: '男'}, {key: '1', value: '女'},{key:'3', value:'其他'}],
        name: '',
        cname: '',
        sex:'',
        old:true,
        show: false
      }
    },
    methods: {
      onHide () {
        console.log('on hide')
      },
      onShow () {
        console.log('on show')
      },
      start (){
        let params ={
          name:this.name,
          cname: this.cname,
          sex: this.sex,
          old: this.old
        }
        if(!this.name || (!this.cname && this.old) || (!this.sex && this.old)){
          this.show = true
          return
        }

        let url = "/game/"+this.name

        this.$http.post('/',params).then(function(res){
          this.$router.push({path:url})
        },function(err){
          console.log(err);
        })

      }
    }
  }
</script>

<style>
  .login {
    text-align: center;
  }
  .logo {
    width: 100px;
    height: 100px
  }
</style>
