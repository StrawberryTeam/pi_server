define(['avalon', 'text!./dialog.html'], function(avalon, dialog) {
    avalon.templateCache.dialog = dialog;

    var vm = avalon.define({
        $id: "baseDialog",
        //是否显示
        toggle: false,
        //标题
        title: '提示消息',
        //消息
        message: '',
        //确定回调函数
        okCall:'',
        //取消回调函数
        cancelCall:'',
        //关闭回调函数
        closeCall:'',
        //显示取消按钮
        showCancel:true,
        //ok
        okVal:'确定',
        okClass: 'btn-danger',
        //redirect url
        redirectUrl: '',
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
            vm.okCall='';
            vm.cancelCall='';
            vm.closeCall='';
            vm.showCancel=true;
            vm.uploading = 0;
            vm.okVal = '确定';
            vm.okClass = 'btn-danger';
            $('#baseDialog').modal('hide');
        },

        //info
        alert: function(msg){
            vm.toggle = true;
            vm.message = msg;
            vm.showCancel = false;
            setTimeout(function() {
                $('#baseDialog').modal({
                    backdrop: true,
                    show: true
                });
            }, 100);
        },
        //选择
        confirm: function(msg){
            vm.toggle = true;
            vm.message = msg;
            setTimeout(function() {
                $('#baseDialog').modal({
                    backdrop: true,
                    show: true
                });
            }, 100);
        },

        //根据类型弹出窗口
        showMsg: function(msg, kind, opt){
            avalon.mix(vm, opt);
            switch (kind){
                //OK
                case 'alert':
                    vm.alert(msg);
                    break;
                //确认弹窗
                case 'confirm':
                    vm.confirm(msg);
                    break;
                //OK
                default :
                    vm.alert(msg);
                    break;
            }
        },
        //初始化
        init: function(){
        }
    });

    //根 ms-controller
    var root = avalon.vmodels.root;
    root.page = "dialog";
    return vm;
});
