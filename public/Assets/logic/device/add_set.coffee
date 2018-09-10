'use strict'

define ['text!/Pages/device/add_set.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.device_add_set = pageMain;
    vm = avalon.define({
        $id: 'device_add_set'
        title: '添加影片集'
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

        s_platform: null
        link: ''
        addSet: () ->
            if null == vm.s_platform
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('必须选择一个平台', 'error')
            if '' == vm.link
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('必须填写格式正确的影片集链接', 'error')
            api.getApi('/task/add_set', {'platform': vm.s_platform, 'link': vm.link, 'deviceId': vm.deviceId}, (result)->
                if SUCCESS == result.code
                    #成功
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'success', {'redirectUrl': '#!/task:home'})
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )


        init: (url) ->
            avalon.log('device add_set page load complete')
            vm.url = url
            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.deviceId = if vm.url.deviceId then vm.url.deviceId else _clientInfo['uid']
            vm.s_platform = null
            vm.link = ''
            vm.getPlaySetting()

    })

    return vm