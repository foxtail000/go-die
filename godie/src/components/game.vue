<template>
  <div>
    <divider>角色: {{attribute.cname}}</divider>
    <card :header="{title:'人物属性'}">
      <div slot="content" class="card-demo-flex card-demo-content01">
        <div class="vux-1px-l vux-1px-r">
          <span>{{attribute.power}}</span>
          <br/>
          力量
        </div>
        <div class="vux-1px-r">
          <span>{{attribute.speed}}</span>
          <br/>
          速度
        </div>
        <div class="vux-1px-r">
          <span>{{attribute.IQ}}</span>
          <br/>
          智商
        </div>
        <div class="vux-1px-r">
          <span>{{attribute.money}}</span>
          <br/>
          黄金律
        </div>
        <div class="vux-1px-r">
          <span>{{attribute.face}}</span>
          <br/>
          颜值
        </div>
        <div>
          <span>{{attribute.lucky}}</span>
          <br/>
          幸运度
        </div>
      </div>
    </card>

    <card :header="{title:'场景'}">
      <img slot="header" :src="nodeinfo.image" v-show="nodeinfo.image!=''" style="width:100%;display:block;">
      <div slot="content" class="card-padding">
        <p style="font-size:14px;line-height:1.2;">{{nodeinfo.content}}</p>
      </div>
    </card>

    <group>
      <radio :options="selects" @on-change="change"></radio>
    </group>
    <alert v-model="show" title="敲黑板" @on-show="onShow" @on-hide="onHide">'要选答案啊?'</alert>
    <br>
    <x-button type="default" show-loading @click.native="reinit" v-if="over">重新开始</x-button>
    <x-button type="default" show-loading @click.native="go" v-if="!over">确认选择</x-button>
  </div>
</template>

<script>
  import { Group, XButton, Radio, Card, Divider,Alert} from 'vux'
  export default {
    components: {
      Group,
      XButton,
      Radio,
      Card,
      Divider,
      Alert
    },
    data () {
      return {
        show: false,
        selectid:'',
        over : false,
        attribute:{},
        selects:[],
        nodeinfo:{}
      }
    },
    mounted: function(){
      let url ="/game/"+this.$route.params.user;
      this.$http.get(url).then(function(res){
          let body=res.data.payload;
          this.attribute = body.chrinfo;
          this.selects = body.selects;
          this.nodeinfo = body.nodeinfo;
          if(body.selects.length === 0){
            this.over =true
          }else{
            this.over = false
          }
        },function(err) {
        console.log(err)
      })
  },
    methods: {
      change (value) {
        this.selectid = value
      },
      onHide () {
      },
      onShow () {
      },
      init () {
        let url ="/game/"+this.$route.params.user;
        this.$http.get(url).then(function(res){
          let body=res.data.payload
          this.attribute = body.chrinfo
          this.selects = body.selects
          this.nodeinfo = body.nodeinfo
          if(body.selects.length === 0){
            this.over =true
          }else{
            this.over = false
          }
        },function(err) {
          console.log(err)
        })
      },
      go (){
        if(!this.selectid){
          this.show = true
        }else{
          this.show = false
        }
       let params={
          node : this.selectid
        }
        let url = "/game/"+this.$route.params.user;
        this.$http.post(url,params).then(function(res){
          console.log(res.data.payload);
          this.init();
        },function(err){
          console.log(err)
        })
      },
      reinit (){
        let params={
          restart : '1'
        }
        let url = "/game/"+this.$route.params.user;
        this.$http.post(url,params).then(function(res){
          console.log(res.data.payload);
          this.init()
        },function(err){
          console.log(err)
        })
      }
    }
  }
</script>

<style scoped lang="less">
  @import '../../node_modules/vux/src/styles/1px.less';
  .card-demo-flex {
    display: flex;
  }
  .card-demo-content01 {
    padding: 10px 0;
  }
  .card-padding {
    padding: 15px;
  }
  .card-demo-flex > div {
    flex: 1;
    text-align: center;
    font-size: 12px;
  }
  .card-demo-flex span {
    color: #f74c31;
  }
</style>
