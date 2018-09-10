'use strict'

define ['text!/Pages/device/create_set.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.device_create_set = pageMain;
    vm = avalon.define({
        $id: 'device_create_set'
        title: '创建影片集'
        mod: avalon.vmodels.dashboard.mod
        host: avalon.vmodels.dashboard.host
        uid: avalon.vmodels.dashboard.uid
        url: null
        isLoading: false
        deviceId: null
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'

        setting: {}
        # 获取本设备信息
        getPlaySetting:() ->
            api.getApi('/setting/getPlaySetting', {'uid': vm.deviceId}, (result)->
                if SUCCESS == result.code
                    vm.setting = result.item
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

#        #提交表单
#        submitForm: (e) ->
#            require ['logic/common/tips'], (tips) ->
#                tips.showTips(true, 'loading')
#            e.preventDefault()#阻止页面刷新
#            data = $(this).serialize();
#            action = $(this).attr('action');
#            api.getApi(action, {data: data, deviceId: vm.deviceId}, (result) ->
#                require ['logic/common/tips'], (tips) ->
#                    tips.showTips(false, 'loading')
#                #有错误
#                if result.code != SUCCESS
#                    require ['logic/common/tips'], (tips) ->
#                        tips.showTips(result.msg, 'error')
#                else
#                    #成功
#                    require ['logic/common/tips'], (tips) ->
#                        tips.showTips(result.msg, 'success', {'redirectUrl': vm.ref})
##  需要外部刷新
##                    vm.parentRefresh()
#            )

        init: (url) ->
            avalon.log('device create_set page load complete')
            vm.url = url
            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.deviceId = if vm.url.deviceId then vm.url.deviceId else _clientInfo['uid']
            vm.getPlaySetting()

    })

    return vm