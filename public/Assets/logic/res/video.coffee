'use strict'

define ['text!/Pages/res/video.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.res_video = pageMain;
    vm = avalon.define({
        $id: 'res_video'
        title: '影片列表'
        mod: avalon.vmodels.dashboard.mod
        host: avalon.vmodels.dashboard.host
        uid: avalon.vmodels.dashboard.uid
        url: null
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'

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

        search: () ->
            if '' != vm.searchQuery
                avalon.router.navigate('res:video?setid=' + vm.setId + '&query=' + vm.searchQuery)

        setting: {}
        # 所有片子集
        cateList: []
        getList: () ->
            vm.cateList = []
            vm.pageHtml = ''
            api.getApi('/videolist/get_list', {
                'setId': vm.setId
                'page': vm.currentPage
                'count': vm.count
                'order': vm.order
                'direction': vm.direction
                'keyword': vm.searchQuery
            }, (result)->
                if SUCCESS == result.code
                    vm.setting = result.setting
                    vm.cateList = result.list
                    totalPage = Math.ceil(result.total / parseInt(vm.count))
                    vm.pageHtml = page.getPage(vm.currentPage, totalPage, vm.url, 'res:video')
                else if ISEMPTY == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips('没有任何单集', 'error')
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


        init: (url) ->
            avalon.log('task home page load complete')
            vm.url = url
            vm.setId = vm.url.setid
            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.searchQuery = if vm.url.query then vm.url.query else ''
            vm.getList()
            vm.getSetInfo()

    })

    return vm