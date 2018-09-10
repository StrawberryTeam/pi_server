'use strict'

define ['text!/Pages/device/list.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.device_list = pageMain;
    vm = avalon.define({
        $id: 'device_list'
        title: '设备资源列表'
        mod: avalon.vmodels.dashboard.mod
        host: avalon.vmodels.dashboard.host
        uid: avalon.vmodels.dashboard.uid
        url: null
        isLoading: false
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'


# 显示图片
        showImg: (el) ->
# 已下载到本地
            if el['imgs'] and el['imgs'][vm.uid]
                return vm.host + el['imgs'][vm.uid]
            # 平台1 爱奇艺 图片不能直接显示
            if el.platform in NOTSHOWIMG_PLATFORM
                return '/images/default.png'
            else
# 其他平台可以直接显示
                return el['img']

        deviceId: 0
        deviceList: []
        getDeviceList: () ->
            api.getApi('/setting/get_list', {}, (result)->
                if SUCCESS == result.code
                    vm.deviceList = result.list
                else if ISEMPTY == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips('没有任何设备', 'error')
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )
        # 当前page
        currentPage: 1,
        # 分页 html
        pageHtml: '',
        # 每页显示数量
        count: 24,
        # 关键词
        searchQuery: ''
        # 排序方法
        order: 'sorts.'
        # 排序规则
        direction: -1


        # 开始搜索
        search: () ->
            if '' != vm.searchQuery
                avalon.router.navigate('device:list?deviceId=' + vm.deviceId + '&query=' + vm.searchQuery)

        # 所有片子集
        list: []
        getResList: () ->
            vm.list = []
            vm.pageHtml = ''
            vm.isLoading = true
            api.getApi('/videoset/get_resList', {
                'page': vm.currentPage
                'count': vm.count
                'title_query': vm.searchQuery
                'order': vm.order + vm.deviceId #按名称排序 不同平台的 名称类似
                'direction': vm.direction
                'deviceId': vm.deviceId
                'type': 'dledAndDlOneAndCreate' #已在本设备中的影片 以及本设备创建的影片集
            }, (result)->
                vm.isLoading = false
                if SUCCESS == result.code
                    vm.list = result.list
                    totalPage = Math.ceil(result.total / parseInt(vm.count))
                    vm.pageHtml = page.getPage(vm.currentPage, totalPage, vm.url, 'device:list')
                else if ISEMPTY == result.code
                    vm.list = false
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 下载影片集
        dl: (id) ->
            api.getApi('/videoset/set_todownload', {"id": id}, (result)->
                if SUCCESS == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'success', {'autoHide': 2000})
                    vm.getCategory()
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 取消下载
        undl: (id) ->
            api.getApi('/videoset/set_toundownload', {"id": id}, (result)->
                if SUCCESS == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'success', {'autoHide': 2000})
                    vm.getCategory()
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 删除已下载文件
        remove: (id) ->
            alert '未完成'


        # 隐藏影片集
        hide: (id) ->
            vm.doChangeHide(id, 'hide')

        # 显示影片集
        show: (id) ->
            vm.doChangeHide(id, 'show')

        doChangeHide: (id, type) ->
            api.getApi('/videoset/change_hide', {
                'setId' : id
                'status': type
                'deviceId': vm.deviceId
            }, (result)->
                if SUCCESS == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips('状态更新成功', 'success', {'autoHide': 2000})
                    vm.getResList()
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 本设备是否需要隐藏本影片集
        isDeviceIdInHides: (el) ->
            if el.hides and String(vm.deviceId) in el.hides
                return true
            else
                return false
            
        # 更新排序
        changeSort: (id, sort) ->
            if isNaN(sort)
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('排序值必须为数字', 'error')
            else
                api.getApi('/videoset/change_sort', {
                    'setId' : id
                    'sort': sort
                    'deviceId': vm.deviceId
                }, (result)->
                    if SUCCESS == result.code
                        require ['logic/common/tips'], (tips) ->
                            tips.showTips('排序更新成功', 'success', {'autoHide': 2000})
                        vm.getResList()
                    else
                        require ['logic/common/tips'], (tips) ->
                            tips.showTips(result.msg, 'error')
                )

        init: (url) ->
            avalon.log('task home page load complete')
            vm.url = url
            # 创建成功
            if vm.url.create_set_success
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('影片集创建成功', 'success', {'autoHide': 2000})
                avalon.router.navigate('device:list?deviceId=' + vm.url.deviceId, {replace: true, options: true})

            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.searchQuery = if vm.url.query then vm.url.query else ''
            vm.deviceId = if vm.url.deviceId then vm.url.deviceId else _clientInfo['uid']
            vm.getDeviceList()
            vm.getResList()

    })

    return vm