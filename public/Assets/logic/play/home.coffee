'use strict'

define ['text!/Pages/play/home.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.play_home = pageMain;
    vm = avalon.define({
        $id: 'home'
        mod: avalon.vmodels.play.mod
        host: avalon.vmodels.play.host
        service: avalon.vmodels.play.service
        uid: avalon.vmodels.play.uid
        url: null
#        userArr: avalon.vmodels.straw.userArr
        loading: '/Assets/logic/common/loading.html'

        # 当前page
        currentPage: 1,
        pageHtml: ''
        # 分页 html
        nextPage: () ->
            vm.currentPage++
            avalon.router.navigate('play:home?platform=' + vm.platform + '&query=' + vm.searchQuery + '&page=' + vm.currentPage)
        rePage: () ->
            vm.currentPage--
            avalon.router.navigate('play:home?platform=' + vm.platform + '&query=' + vm.searchQuery + '&page=' + vm.currentPage)

        total: 0
        # 关键词
        searchQuery: ''
        # 排序方法
        order: 'sorts.'
        # 排序规则
        direction: 'desc'
        # 只看一平台
        platform: 0

        # 背景色块
        bg_colors: ['#9f5f9f', '#a67d3d', '#42426f']

        # 随机出颜色
        rand_bg: (el) ->
# 已下载到本地
            if el['imgs'] and el['imgs'][vm.uid]
                limg = vm.host + el['imgs'][vm.uid]
            else
                # 平台1 爱奇艺 图片不能直接显示
                if el.platform in NOTSHOWIMG_PLATFORM
                    limg = '/images/default.png'
                else
    # 其他平台可以直接显示
                    limg = el['img']
            return 'url(' + limg + ')'

        rand_bgcolor: () ->
            index = parseInt(Math.random() * 3) + 1;
            return vm.bg_colors[index - 1]

        # 开始搜索
        submitSearch: (e) ->
            e.preventDefault()#阻止页面刷新
            query = $("input[name='query']").val()
            if query.trim()
                avalon.router.navigate('play:home?query=' + query)

        error: ''
        #  清空本页数据
        emptyList: (status = []) ->
            vm.error = status

        changePlatform: (platform) ->
            vm.platform = platform
            vm.currentPage = 1
            vm.getCategory()

        count: 12
        totalPage: 0
        # 显示 下一页
        showNextPage: false
        onLoading: false
        # 所有片子集
        cateList: []
        # 首次加载
        firstGet: true
        # 执行category 数据
        exeCategory: (result) ->
            if SUCCESS == result.code
#                    if result.list.length > 0
#                        vm.cateList = vm.cateList.concat(result.list)
                vm.emptyList()
                vm.cateList = result.list
                vm.total = result.total
                #                    pageRes = page.getSimplePage(vm.currentPage, vm.url, 'play:home')
                #                    vm.rePage = pageRes.repage
                #                    vm.nextPage = pageRes.nxpage

#                pageTotal = parseInt(vm.count * vm.currentPage)
                vm.totalPage = Math.ceil(result.total / parseInt(vm.count))
                vm.pageHtml = page.getPage(vm.currentPage, vm.totalPage, vm.url, 'play:home')
#                # 是否显示 下一页按钮
#                if pageTotal >= vm.total
#                    vm.showNextPage = false
#                else
#                    vm.showNextPage = true

                setTimeout(()->
                    # 选中第一个
                    $("#FocusMovie0").focus()
                , 200)
            else if ISEMPTY == result.code
                # 无数据了
                vm.emptyList(false)
            else
                require ['logic/common/tips'], (tips) ->
                    tips.showTips(result.msg, 'error')

        getCategory: () ->
#            if true == vm.firstGet
#                vm.firstGet = false
#                # 默认配置加载
#                if 1 == vm.currentPage and 0 == vm.platform and '' == vm.searchQuery
#                    return vm.exeCategory(firstData)
#            if true == vm.onLoading
#                return false
#            vm.onLoading = true
            vm.cateList = []
            vm.emptyList('loading')
#            vm.currentPage++
            api.getApi('/videoset/get_resList', {
                'page': vm.currentPage
                'count': vm.count
                'query': vm.searchQuery
                'order': vm.order + vm.uid #按名称排序 不同平台的 名称类似
                'direction': -1
#                'platform': vm.platform
                'type': 'dledAndDlAtlastone'
            }, (result)->
                vm.exeCategory(result)
            )
#            # 2秒后才允许操作
#            setTimeout(() ->
#                vm.onLoading = false
#            , 1000)

        init: (url) ->
            avalon.log('task home page load complete')
            vm.url = url
            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.platform = if vm.url.platform then vm.url.platform else 0
#            vm.platform = 0
#            vm.currentPage = 1
            vm.searchQuery = if vm.url.query then vm.url.query else ''
            vm.getCategory()

            avalon.vmodels.play.title = ''
            document.title = _siteName
#            $(document).ready(() ->
#                $('.focusBtn').focus(() ->
##                    $(this).click()
#                    href = $(this).attr('href').replace('#!/', '')
#                    avalon.router.navigate(href)
#                    avalon.log(href)
#                    return true
#                )
#            )


    })

#    window.onscroll = () ->
#        if ($(document).scrollTop() + $(window).height() > $(document).height() - 50)
#            vm.getCategory()



    return vm