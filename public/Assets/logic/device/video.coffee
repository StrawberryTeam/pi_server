'use strict'

define ['text!/Pages/device/video.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.device_video = pageMain;
    vm = avalon.define({
        $id: 'device_video'
        title: '影片列表'
        mod: avalon.vmodels.dashboard.mod
        host: avalon.vmodels.dashboard.host
        uid: avalon.vmodels.dashboard.uid
        url: null
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'
# 显示图片
        showImg: (el) ->
# 已下载到本地
            if el['imgs'] and el['imgs'][vm.uid]
                return vm.host + el['imgs'][vm.uid]
            # 平台1 爱奇艺 图片不能直接显示
            if vm.item['platform'] in NOTSHOWIMG_PLATFORM
                return '/images/default.png'
            else
# 其他平台可以直接显示
                return el['img']

        deviceId: null#avalon.vmodels.dashboard.uid
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
# 已选内容
        selectedVideo: []
        selectAll: false
# 全选勾选
        checkAll:  () ->
            if this.checked
                for c in vm.cateList
                    vm.selectedVideo.ensure(c._id)
            else
                vm.selectedVideo.clear();

        setId: null
        platform: null
        # 当前page
        currentPage: 1
        # 分页 html
        pageHtml: ''
        # 每页显示数量
        count: 30
        # 关键词
        searchQuery: ''
        # 排序方法
        order: '_id'
        # 排序规则
        direction: 1
        setting: {}

        search: () ->
            if '' != vm.searchQuery
                avalon.router.navigate('res:video?setid=' + vm.setId + '&query=' + vm.searchQuery)

        # 所有片子集
        cateList: []
        total: 0
        getList: () ->
            vm.cateList = []
            vm.setting = {}
            vm.pageHtml = ''
            vm.selectedVideo = []
            vm.selectAll = false
            api.getApi('/videolist/get_list', {
                'setId': vm.setId
                'page': vm.currentPage
                'count': vm.count
                'order': vm.order
                'direction': vm.direction
                'keyword': vm.searchQuery
                'deviceId': vm.deviceId
                'type': 'dl'
            }, (result)->
                if SUCCESS == result.code
                    vm.cateList = result.list
                    vm.total = result.total
                    vm.setting = result.setting
                    totalPage = Math.ceil(result.total / parseInt(vm.count))
                    vm.pageHtml = page.getPage(vm.currentPage, totalPage, vm.url, 'device:video')
                else if ISEMPTY == result.code
                    vm.cateList = false
#                    require ['logic/common/tips'], (tips) ->
#                        tips.showTips('没有任何单集', 'error')
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        item: {}
        getSetInfo: () ->
            api.getApi('/videoset/get_info', {
                '_id': vm.setId
            }, (result)->
                if SUCCESS == result.code
                    vm.item = result.item
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 复制至其他设备
        cp2other: (deviceId) ->
            if vm.selectedVideo.length <= 0
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('请选择一些项目', 'error')
            else if deviceId == vm.deviceId
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('不能复制至当前设备', 'error')
            else
                vm.doTask(deviceId, 'copy')

        zipFiles: () ->
            if vm.selectedVideo.length <= 0
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('请选择一些项目', 'error')
            else
                vm.doTask(0, 'zip')

        # 添加任务
        doTask: (toDevice, type)->
            # 添加复制至任务
            api.getApi('/task/create', {
                "videoIds": JSON.stringify(vm.selectedVideo)
                "set_id": vm.item._id
                "toDevice": toDevice
                "fromDevice": vm.deviceId
                "type": type
            }, (result)->
                if SUCCESS == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'success', {'autoHide': 2000})
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 添加至影片集
        addToSet: () ->
            if vm.selectedVideo.length <= 0
                require ['logic/common/tips'], (tips) ->
                    tips.showTips('请选择一些项目', 'error')
            else
                #load javascript
                require ['logic/device/select_set'], (detail) ->
                    detail.init(vm.url, 1, {'mod': 'logic/device/video', 'fun': 'getList'}, {"deviceId": vm.deviceId, 'selectedVideo': vm.selectedVideo})
                    require ['logic/common/window'], (window) ->
                        # 加载页面
                        window.showWindow('/Pages/device/select_set.html')

        init: (url) ->
            avalon.log('task home page load complete')
            vm.url = url
            vm.setId = vm.url.setid
            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.searchQuery = if vm.url.query then vm.url.query else ''
            vm.deviceId = if vm.url.deviceId then vm.url.deviceId else 1
            vm.getDeviceList()
            vm.getList()
            vm.getSetInfo()
            $('#opt').affix(
                offset: {
                    top: 10
                    bottom: () ->
                        return (this.bottom = $('.footer').outerHeight(true))
                }
            )


    })
    # 监听勾选列表，反向设置全选勾选框
    vm.$watch("selectedVideo.length", (after) ->
        vm.selectAll = after == vm.cateList.length
    )
    return vm