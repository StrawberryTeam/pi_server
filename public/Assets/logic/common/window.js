define(['avalon', 'text!./window.html'], function(avalon, window) {
    avalon.templateCache.window = window;

    var vm = avalon.define({
        $id: "baseWindow",
        //消息正文
        content: '',
        module: null,
        // lg 大 sm 小
        size: 'lg',
        loadInit: function(){},
        //根据 url 加载内容
        showWindow: function(url, opt){
            vm.module = 'loading'
            avalon.mix(vm, opt)

            // 加载 url 内容
            vm.module = url

            vm.show()
        },
        // 隐藏
        hide: function(){
            vm.content = ''
            // vm.module = null
            // vm.loadInit = null
            vm.size = 'lg'
            $("#baseWindow").modal('hide');
        },
        // 显示
        show: function(){
            setTimeout(function() {
                $("#baseWindow").modal({
                    backdrop: true,
                    show: true
                });
            }, 100);
        },
        //初始化
        init: function(){
        }
    });

    //根 ms-controller
    var root = avalon.vmodels.root;
    root.window = "window";
    return vm;
});
