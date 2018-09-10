define(['avalon', 'utils', 'text!./tips.html'], function(avalon, utils, tips) {
    avalon.templateCache.tips = tips;

    var vm = avalon.define({
        $id: "baseTips",
        //是否显示
        toggle: false,
        //标题
        title: '提示消息',
        //消息
        message: '',
        //tips class name
        tipsClass: '',
        btnClass: '',
        //确定回调函数
        okCall:'',
        //取消回调函数
        cancelCall:'',
        //关闭回调函数
        closeCall:'',
        //显示关闭按钮
        showClose: true,
        //ok
        okVal:'好的',
        //cancel
        cancelVal: '',
        //redirect url
        redirectUrl: '',
        //auto hide widthin sec
        autoHide: 0,
        //确定
        doOk: function(event){
            if(vm.okCall){
                vm.okCall.call(this, vm);
            }else{
                vm.doClose(event);
            }
        },
        //取消操作
        doCancel:function(event){            
            vm.cancelCall && vm.cancelCall.call(this, vm);
            vm.doClose(event);
        },
        //关闭
        doClose: function(event){
            vm.closeCall && vm.closeCall.call(this, vm);

            //event.preventDefault ? event.preventDefault() : (event.returnValue = false);
            event && event.preventDefault();
            vm.toggle = false;
            //关闭之后初始化
            vm.tipsClass = '';
            vm.btnClass = '';
            vm.okCall = '';
            vm.cancelCall = '';
            vm.closeCall = '';
            vm.showClose = true;
            vm.okVal = '好的';
            vm.cancelVal = '';
            vm.redirectUrl = '';
            vm.autoHide = 0;
        },
        //error
        error: function(msg){

            vm.toggle = true;
            vm.tipsClass = 'alert-danger';
            vm.btnClass = 'btn-danger';
            vm.title = '<span class="glyphicon glyphicon-warning-sign"></span>';
            vm.message = msg;
            //是否允许自动隐藏
            if (vm.autoHide){
                setTimeout(function() {
                    vm.doClose();
                }, vm.autoHide);
            }
        },

        loading: function(toggle){
            if (false == toggle){
                vm.doClose()
                return false;
            }
            vm.toggle = true;
            vm.tipsClass = 'alert-warning';
            vm.title = '';
            vm.message = '<div class="spinner2">' +
                '<div class="bounce1"></div>' +
                '<div class="bounce2"></div>' +
                '<div class="bounce3"></div>' +
                '</div>';
            vm.okVal = '';
            vm.showClose = false;
        },

        success: function(msg){
            vm.toggle = true;
            vm.tipsClass = 'alert-success';
            vm.btnClass = 'btn-success';
            vm.title = '<span class="glyphicon glyphicon-ok"></span>';
            vm.message = msg;

            //如果需要跳转 改变 okval 并执行
            if (vm.redirectUrl){
                vm.okVal = '立即跳转';
                //更新 okcall 按钮 click
                vm.okCall = function(){
                    utils.redirect(vm.redirectUrl);
                };
                setTimeout(function() {
                    utils.redirect(vm.redirectUrl);
                    vm.doClose();
                }, 1000);
            }else if (vm.autoHide){
                setTimeout(function() {
                    vm.doClose();
                }, vm.autoHide);
            }
        },


        //根据类型弹出窗口
        showTips: function(msg, kind, opt){
            vm.doClose()
            avalon.mix(vm, opt);
            switch (kind){
                case 'error':
                    vm.error(msg);
                    break;
                case 'success':
                    vm.success(msg);
                    break;
                case 'loading':
                    vm.loading(msg);
                    break;
            }
        },

        //初始化
        init: function(){
        }
    });

    ////根 ms-controller
    var root = avalon.vmodels.root;
    root.tips = "tips";
    return vm;
});
