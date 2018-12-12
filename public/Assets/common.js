// var APP_ENV = APP_ENV || 'PRODUCTION'; //生产环境打开此项
// var APP_ENV = APP_ENV || 'TEST'; //测试环境打开此项
var APP_ENV = APP_ENV || 'DEVELOPMENT'; //开发环境打开此项

var require = require || {
    urlArgs: 'v=10002.11',
    waitSeconds: 0
};

// var _availableModules;
if ('PRODUCTION' == APP_ENV) {
}

if ('TEST' == APP_ENV) {
    require.urlArgs = 'v=' + (new Date()).getTime();
}

if ('DEVELOPMENT' == APP_ENV) {
    require.urlArgs = 'v=' + (new Date()).getTime();
}



// 常量
var SUCCESS = 0
var FAIL = 1
var ISEMPTY = 2

//平台
var PLATFORM_WEB = 0
var PLATFORM_ANDROIDTV = 1
var PLATFORM_IOSAPP = 2
//线上播放设备
var UID_ONLINE = 2

//不能正常显示图片的平台
var NOTSHOWIMG_PLATFORM = [1, 9]

//系统级错误
function sysErr(msg){
    if ('PRODUCTION' == APP_ENV) {
        alert('系统错误, 请刷新后重试');
    }else{
        alert(msg);
    }
    return false
}

// 获取当前 真实 url
function getRealUrl(){
    return encodeURIComponent('//' + window.location.host + window.location.pathname + window.location.hash);
}

