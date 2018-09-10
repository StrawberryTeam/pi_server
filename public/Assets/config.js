//配置
define(function(){

    require.config({
        baseUrl: "/Assets/",
        paths: {
            //jquery基础
            'jquery': 'vendor/jquery/jquery-1.11.3.min',
            //'jquery-ui':'vendor/jquery-ui',
            'jquery.md5': 'vendor/jquery/jquery.md5',
            'jquery.floatDiv': 'vendor/jquery/jquery.floatDiv',
            'jquery.timeago': 'vendor/jquery/jquery.timeago',
            'jquery.custom': 'vendor/jquery-ui/js/jquery-ui-1.9.2.custom.min',
            'jquery.datepicker': 'vendor/jquery-ui/development-bundle/ui/i18n/jquery.ui.datepicker-zh-CN',
            'jquery.raty':'vendor/jquery/jquery.raty',
            'jquery.placeholder': 'vendor/jquery/jquery.placeholder.min',
            //avalon基础
            'avalon': 'vendor/avalon/avalon.shim-1.59',
            // 'avalon': 'vendor/avalon/avalon.modern.shim-1.55',
            'avalon_common': 'vendor/avalon/avalon.common',
            'avalon.cookie': 'vendor/avalon/avalon.cookie',
            'text': 'vendor/require/text',
            'domReady': 'vendor/require/domReady',
            'css': 'vendor/require/css',
            'css-builder': 'vendor/require/css-builder',
            'normalize': 'vendor/require/normalize',
            'plupload': 'vendor/plupload/plupload.full.min',
            'qiniu': 'vendor/qiniu/qiniu.min',
            'mmRouter': 'vendor/avalon/mmRouter',
            'mmHistory': 'vendor/avalon/mmHistory',
            'mmState': 'vendor/avalon/mmState',
            //bootstrap
            'bootstrap': 'vendor/bootstrap/bootstrap',
            //插件体系
            'intro': 'vendor/intro/intro',
            //小工具
            'cookie': 'base/js.cookie',
            'utils': 'base/utils',
            'api': 'base/api',
            'json2': 'base/json2',
			'Base64': 'base/base64',
            'copy_clip_board': 'base/copy_clip_board',
            'pinyin':'base/pinyin',
            'page': 'base/page',
            'videojs':'vendor/videojs/videojs',
            'twemoji':'vendor/twemoji/twemoji.min',
            //基础配置
            'config': 'config',
            //error txt
            'error': 'base/error',
            //all filters
            'filters': 'filters',
            'ueditor': 'vendor/ueditor/ueditor.all',
            'ueditor.config': 'vendor/ueditor/ueditor.config',
            'ZeroClipboard': 'vendor/ueditor/third-party/zeroclipboard/ZeroClipboard',
            'select2': 'vendor/select2/select2.full',
            'swipe': 'vendor/swipe/photoswipe.min',
            'echarts': 'vendor/echarts/echarts.common.min',
            'IScroll': 'vendor/iscroll/iscroll'
        },
        priority: ['text', 'css'],
        shim: {
            'jquery': {
                exports: 'jQuery'
            },
            'jquery.placeholder': {
                exports: 'jQuery'
            },
            'jquery.md5': {
                exports: 'jQuery'
            },
            'bootstrap': {
                exports: 'bootstrap',
                deps: ['jquery']
            },
            'json2': {
                exports: 'JSON'
            },
			'jquery.floatDiv': {
                deps: ['jquery'],
                exports: 'jQuery'
            },
            'jquery.raty': {
                deps: ['jquery'],
                exports: 'jQuery'
            },
			'jquery.timeago': {
                deps: ['jquery'],
                exports: 'jQuery'
			},
            'jquery.custom':{
                exports:'jQuery',
                deps:['jquery','css!'+ 'vendor/jquery-ui/css/south-street/jquery-ui-1.9.2.custom.min.css']
            },
            'jquery.datepicker':{
                exports:'jQuery',
                deps:['jquery.custom']
            },
            'avalon': {
                exports: 'avalon'
            },
            'page':{
                deps: ['jquery']
            },
            'plupload': {
                exports: 'plupload'
            },
            'qiniu':{
                exports:'Qiniu',
                deps:['json2']
            },
            'intro':{
                exports:'jQuery',
                deps:['css!'+ 'vendor/intro/introjs.min.css']
            },
            'videojs':{
                exports:'videojs',
                deps:['css!'+ 'vendor/videojs/video.css']
            },
            'ueditor':{
                exports:'ueditor',
                deps:['ueditor.config', 'ZeroClipboard']
            },
            'select2':{
                exports: 'select2',
                deps: ['jquery', 'css!' + 'vendor/select2/select2.min.css']
            },
            'swipe':{
                exports: 'swipe',
                deps: ['jquery', 'css!' + 'vendor/swipe/photoswipe.css']
            },
            'echarts':{
                exports: 'echarts'
            },
            'IScroll': {
                exports: 'IScroll'
            }
        },
        // urlArgs: 'v=' + (new Date()).getTime(),
        waitSeconds: 0
    });
    //公共初始化
    require(['avalon','jquery', 'avalon.cookie', 'error', 'filters', 'bootstrap'], function(avalon,$){
        if ('PRODUCTION' === APP_ENV) {
            avalon.config({
                debug: false
            });
        }else{
            avalon.config({
                debug: true
            });
        }
        // all loading with this cache page
        avalon.templateCache["loading"] = '<div class="row">' +
            '<div class="col-md-12">' +
            '<div class="spinner">' +
            '<div class="double-bounce1"></div>' +
            '<div class="double-bounce2"></div>' +
            '</div>' +
            '</div>' +
            '</div>';

        var root = avalon.define({
            $id: 'root',
            //提示窗口使用
            page: null,
            //tips 专用
            tips: null,
            //大 window dialog
            window: null,
            //ref url
            ref: null,
            //登录token
            token: null,
            // get ref with all url path
            getRef: function(url){
                if (root.ref){
                    returnUrl = root.ref
                }else{
                    if (url){
                        returnUrl = url;
                    }else{
                        returnUrl = _availableModules['straw'];
                    }
                }
                return decodeURIComponent(returnUrl);
               // return document.referrer
            },
            // 设置 ref
            setRef: function(url){
                root.ref = url ? encodeURIComponent(url) : getRealUrl();
                return true;
            },
            //初始化
            init: function(){
                // root.bluttonStatus();

                //移除加载中
                //$('#ajax_loading').hide();
                // setTimeout(function(){
                //     $('a').tooltip({
                //         animation: false,
                //         placement: 'bottom',
                //         trigger: 'hover'
                //     })
                // }, 500)
            }
        });

        root.init();

    });


});
