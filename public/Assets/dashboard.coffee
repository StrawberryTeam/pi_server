'use strict'

require ['config'], (config) ->

    require ['domReady!', 'avalon', 'jquery', 'api', 'utils', 'select2', 'mmRouter', 'jquery.placeholder'], (domReady, avalon, $, api, utils) ->

        dashboard = avalon.define({
            $id: 'dashboard'

            module: 'loading'
            mod: null
            service: null

            query: null
            url: null
            # 本模块要求登录后使用
            needLogin: true
            #用戶信息
            userArr: {}
            #用户拥有的权限
            safeFun: {}
            isSafe: (action) ->
#                avalon.log dashboard.safeFun
                if action.toUpperCase() in dashboard.safeFun
                    return true
                else
                    return false

            # 后台 顶部主导航
            top_nav: '/Pages/common/top_nav.html'
            # 加载完成
            render: () ->

            setLoading: ()->
                dashboard.module = 'loading'

            host: _playSetting.host
            host_name: _playSetting.name
            getHost: (uid) ->
                setting = sessionStorage.getItem('setting_' + uid)
                if setting
                    settingObj = JSON.parse(setting)
                    dashboard.host = settingObj.host
                    dashboard.host_name = settingObj.host_name
                else
                    api.getApi('/setting/getPlaySetting', {"uid": uid}, (result)->
                        avalon.log result
                        if SUCCESS == result.code
                            dashboard.host = result.item.host
                            dashboard.host_name = result.item.name
                            sessionStorage.setItem('setting_' + uid, JSON.stringify({host: dashboard.host, host_name: dashboard.host_name}))
                    )


            uid: 0
            # 加载页面
            loadModulePage: () ->
                # 选择 uid
                dashboard.uid = avalon.cookie.get('uid')
                if not dashboard.uid
                    avalon.router.navigate('select:home')
#                else
#                    dashboard.getHost(dashboard.uid)
#                dashboard.mod = mod
                # avalon.log(this.query)
#                avaiableService = ['task', 'download', 'res']
                if not dashboard.service
#                alert undefined  == dashboard.service
#                if dashboard.service == undefined
                    #default service
                    avalon.router.navigate('res:list')
                    return false
#                avaiableMod = ['category', 'category_info', 'content', 'content_info', 'comment', 'user', 'group', 'competence']
                if dashboard.mod == undefined
                    avalon.router.navigate(dashboard.service+ ':home')

                dashboard.query = dashboard.url.query if dashboard.url.query

                # 加載 mod
#                dashboard.module = '/Pages/' + dashboard.service + '/' + dashboard.mod + '.html'
#                avalon.log 'load page' + dashboard.module
                modName = dashboard.service + '/' + dashboard.mod
#                alert modName
                require ['logic/'+ modName], (module) ->
                    document.title = module.title
                    dashboard.module = dashboard.service + '_' + dashboard.mod
                    avalon.scan()
                    module.init(dashboard.url)
#                    $('input, textarea').placeholder();

            setCurrentPage: () ->
                serviceMod = this.params.mod.trim().split(':')
                dashboard.service = serviceMod[0]
                dashboard.mod = serviceMod[1]
                dashboard.url = this.query
                #loading now
                dashboard.setLoading()
                dashboard.loadModulePage()

            init: () ->
                dashboard.schoolTitle = 'Dashboard'
                avalon.router.get("/:mod", dashboard.setCurrentPage)
                avalon.history.start({
                    basepath: '/'
                    #hashPrefix: "!",
                    interval: 20 #IE保存20步 history 至 iframe
                })

        })

        dashboard.init()
        avalon.scan(document.body)

        return dashboard


