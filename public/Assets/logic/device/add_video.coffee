'use strict'

define ['text!/Pages/device/add_video.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.device_add_video = pageMain;
    vm = avalon.define({
        $id: 'device_add_video'
        title: '添加影片'
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
        setId: ''
        link: ''
        addSet: () ->
            if null == vm.s_platform
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('必须选择一个平台', 'error')
            if '' == vm.link
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('必须填写格式正确的影片集链接', 'error')
            api.getApi('/task/add_video', {'setId': vm.setId, 'platform': vm.s_platform, 'link': vm.link, 'deviceId': vm.deviceId}, (result)->
                if SUCCESS == result.code
                    #成功
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'success', {'redirectUrl': '#!/task:home'})
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )


        init: (url) ->
            avalon.log('device add_video page load complete')
            vm.url = url
            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.deviceId = if vm.url.deviceId then vm.url.deviceId else _clientInfo['uid']
            if vm.url.setId
                vm.setId = vm.url.setId
            else
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('影片集未找到，请返回重新选择影片集', 'error')
            vm.s_platform = null
            vm.link = ''
            vm.getPlaySetting()

    })

    return vm