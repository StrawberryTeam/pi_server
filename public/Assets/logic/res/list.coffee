'use strict'

define ['text!/Pages/res/list.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.res_list = pageMain;
    vm = avalon.define({
        $id: 'res_list'
        title: '视频集'
        mod: avalon.vmodels.dashboard.mod
        host: avalon.vmodels.dashboard.host
        uid: avalon.vmodels.dashboard.uid
        url: null
        isLoading: false
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'

        # 当前page
        currentPage: 1,
        # 分页 html
        pageHtml: '',
        # 每页显示数量
        count: 12,
        # 关键词
        searchQuery: ''
        # 排序方法
        order: 'allplaynum'
        # 排序规则
        direction: -1

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

        # 显示搜索结果
        show_query: false
        # 开始搜索
        search: () ->
            if '' != vm.searchQuery
                vm.show_query = true
                avalon.router.navigate('res:list?type=' + vm.type + '&platform=' + vm.platform + '&query=' + vm.searchQuery)
            else
                vm.show_query = false

        # 我的设备是否可用
        isInMyUid: (data) ->
            if !data
                return false
            if String(_clientInfo['uid']) in data
                return true
            else
                return false

        #平台
        platform: 0
        type: 'res'
        # 所有片子集
        cateList: []
        getCategory: () ->
            vm.cateList = []
            vm.pageHtml = ''
            vm.isLoading = true
            api.getApi('/videoset/get_resList', {
                'page': vm.currentPage
                'count': vm.count
                'query': vm.searchQuery
                'order': vm.order #按名称排序 不同平台的 名称类似
                'direction': vm.direction
                'type': vm.type
                'platform': vm.platform
            }, (result)->
                vm.isLoading = false
                if SUCCESS == result.code
                    avalon.log result.list.dled
                    vm.cateList = result.list
                    totalPage = Math.ceil(result.total / parseInt(vm.count))
                    vm.pageHtml = page.getPage(vm.currentPage, totalPage, vm.url, 'res:list')
                else if ISEMPTY == result.code
                    vm.cateList = false
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

        init: (url) ->
            avalon.log('task home page load complete')
            vm.url = url
            vm.currentPage = if vm.url.page then vm.url.page else 1
            if vm.url.query
                vm.searchQuery = vm.url.query
            else
                vm.searchQuery = ''
                vm.show_query = false
            vm.platform = if vm.url.platform then vm.url.platform else 0
            vm.type = if vm.url.type then vm.url.type else 'res'
            vm.getCategory()

    })

    return vm