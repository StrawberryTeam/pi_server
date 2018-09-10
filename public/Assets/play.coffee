'use strict'

require ['config'], (config) ->

    require ['domReady!', 'avalon', 'jquery', 'api', 'utils', 'select2', 'mmRouter', 'jquery.placeholder'], (domReady, avalon, $, api, utils) ->

        play = avalon.define({
            $id: 'play'
            title: ''
            module: 'loading'
            mod: null
            service: null

            query: null
            url: null
            # 本模块要求登录后使用
            needLogin: false
            # play 顶部主导航
            top_nav: '/Pages/play/top_nav.html'

            # 当前设备 uid
            uid: 0
            # 当前设备平台
            platform: 0

            # 是否显示导航条
            shownav: false
            more: () ->
                play.shownav = !play.shownav

            now_time: ''

            # 获取当前时间信息
            getNowTime: () ->
#                setInterval(() ->
#                    play.now_time = new Date().toLocaleTimeString()
#                , 1000)

            # 测试资源服务器可用性
            networkCheckKey: 'network_check'
            checkNetWork: () ->
                # 服务端无法连接 线下的客户端 还是无法检查
                return true
                networkCheckUid = sessionStorage.getItem(play.networkCheckKey)
                # 已经检查过该 uid  本次不在检查
                if parseInt(networkCheckUid) == parseInt(play.uid)
                    return true
                if 'home' == play.mod || 'view' == play.mod
                    api.getApi('/index/check_device', {uid: play.uid}, (result)->
                        if SUCCESS == result.code
                            # 选择设备在同一网域下
                        else
                            require ['logic/common/tips'], (tips) ->
                                tips.showTips('当前设备' + play.host_name + '与播放设备不在同一网域内, 请切换设备或刷新重试, 关闭页面不在提示', 'error', {
#                                    'okVal': '刷新页面',
#                                    'okCall': () ->
#                                        window.location.reload()
                                    'okVal': '切换设备 [0]',
                                    'okCall': () ->
                                        window.location.href = '/#!/play:select'
                                })
                    )
                    sessionStorage.setItem(play.networkCheckKey, play.uid);

            # 加载完成
            render: () ->

            setLoading: ()->
                play.module = 'loading'

            host: _playSetting.host
            host_name: _playSetting.name
            getHost: (uid) ->
                setting = sessionStorage.getItem('setting_' + uid)
                if setting
                    settingObj = JSON.parse(setting)
                    play.host = settingObj.host
                    play.host_name = settingObj.host_name
                else
                    api.getApi('/setting/getPlaySetting', {"uid": uid}, (result)->
                        avalon.log result
                        if SUCCESS == result.code
                            play.host = result.item.host
                            play.host_name = result.item.name
                            sessionStorage.setItem('setting_' + uid, JSON.stringify({host: play.host, host_name: play.host_name}))
    #                        setTimeout(() ->
    #                            # 测试网络
    #                            play.checkNetWork()
    #                        , 50)
                    )

            # 加载页面
            loadModulePage: () ->
                # 选择 uid
                play.uid = _clientInfo.uid #avalon.cookie.get('uid')
                play.platform = _clientInfo.platform
                if not play.uid
                    # 没有 uid 默认选择线上 服务
#                    window.location.href = '?uid=' + UID_ONLINE
#                    play.uid = UID_ONLINE
                    avalon.router.navigate('play:select')
#                else
#                    play.getHost(play.uid)
#                play.mod = mod
                # avalon.log(this.query)
                avaiableService = ['play']
                if play.service not in avaiableService
#                alert undefined  == play.service
#                if play.service == undefined
                    #default service
                    play.service = avaiableService[0]
#                    avalon.router.navigate(avaiableService[0])
#                    return false
#                avaiableMod = ['category', 'category_info', 'content', 'content_info', 'comment', 'user', 'group', 'competence']
                if play.mod == undefined
                    play.mod = 'home'
#                    avalon.router.navigate(play.service+ ':home')

                play.query = play.url.query if play.url.query

                # 加載 mod
#                play.module = '/Pages/' + play.service + '/' + play.mod + '.html'
#                avalon.log 'load page' + play.module
#                avalon.templateCache[play.service + ':' + play.mod] = play.module
                modName = play.service + '/' + play.mod
#                alert modName
                require ['logic/'+ modName], (module) ->
#                    document.title = module.title
                    play.module = play.service + '_' + play.mod
                    avalon.scan()
                    module.init(play.url)
#                    $('input, textarea').placeholder();

            setCurrentPage: () ->
                serviceMod = this.params.mod.trim().split(':')
                play.service = serviceMod[0]
                play.mod = serviceMod[1]
                play.url = this.query
                play.shownav = false
                #loading now
                play.setLoading()
                play.loadModulePage()

            # 按键动作
            # pc / app 最终映射方法
            keyDo: (key) ->
                console.log ("key " + key)
                switch key
#                when 'left' then
#                when 'right' then
# 0
                    when '0' then window.location.href = '/#!/play:select'
## 1
#                    when '1' then avalon.router.navigate('play:home')
## 2
#                    when '2' then avalon.router.navigate('play:playlist')
## 3
#                    when '3' then avalon.router.navigate('play:favorite')
## 4
#                    when '4' then avalon.router.navigate('play:history')
## 5
#                    when '5' then avalon.router.navigate('play:search')
                #                # 6
                #                when '6' then
                #                # 7
#                    when '7' then
                                # 8
                #                when '8' then
                # 9
                #                when '9' then avalon.router.navigate('setting:home')

            init: () ->
                avalon.router.get("/:mod", play.setCurrentPage)
                avalon.history.start({
                    basepath: '/'
                    #hashPrefix: "!",
                    interval: 20 #IE保存20步 history 至 iframe
                })
#                play.getNowTime()

        })

        # 按键监听 pc 键盘
        document.onkeydown = (e) ->
            isie = if document.all then true else false
            if isie
                key = window.event.keyCode
            else
                key = e.which;
            switch key
#                when 37 then play.keyDo('left')
#                when 39 then play.keyDo('right')
    # 0
                when 48 then play.keyDo('0')
    # 1
                when 49 then play.keyDo('1')
    # 2
                when 50 then play.keyDo('2')
    # 3
                when 51 then play.keyDo('3')
    # 4
                when 52 then play.keyDo('4')
    # 5
                when 53 then play.keyDo('5')
    # 6
                when 54 then play.keyDo('6')
    # 7
                when 55 then play.keyDo('7')
    # 8
                when 56 then play.keyDo('8')
    # 9
                when 57 then play.keyDo('9')

        play.init()
#        avalon.scan(document.body)

        return play


