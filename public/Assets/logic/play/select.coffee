'use strict'

define ['text!/Pages/play/select.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.play_select = pageMain;
    select = avalon.define({
        $id: 'play_select'
        title: '选择设备'
        nuid: avalon.vmodels.play.uid
        url: null
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'
        list: []
        getList: () ->
            api.getApi('/setting/get_list', {}, (result)->
                if SUCCESS == result.code
                    select.list = result.list
                    setTimeout(()->
                        # 选中第一个
                        $("#FocusMovie0").focus()
                    , 200)
                else if ISEMPTY == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips('没有任何设备', 'error')
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 选择设备
        change: (uid) ->
#            date = new Date()
#            # 保存选择一年
#            time = date.getTime() + 60 * 60 * 24 * 365 * 1000
#            date.setTime(time)
#            avalon.cookie.set('uid', uid, {'expires': date})
#            window.location.href = '/'
#            avalon.router.navigate('/')
            window.location.href = '/?uid=' + uid


        init: (url) ->
            avalon.log('play select page load complete')
            # 清理 当前 uid
            avalon.cookie.remove('uid')
            select.url = url
            select.getList()

    })

    return select