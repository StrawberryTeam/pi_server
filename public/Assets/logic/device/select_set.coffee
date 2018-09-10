'use strict'

define ['avalon', 'api', 'page', 'utils'], (avalon, api, page, utils) ->
    select_set = avalon.define({
        $id: 'select_set'
        title: '选择影片集'
        url: null
        list: []
        error: ''
        loading: '/Assets/logic/common/loading.html',
        # 当前page
        currentPage: 1,
        # 分页 html
        pageHtml: '',
        # 每页显示数量
        count: 18,
        # 关键词
        searchQuery: ''
        ac: 0
        mod: avalon.vmodels.dashboard.mod
        host: avalon.vmodels.dashboard.host
        uid: avalon.vmodels.dashboard.uid
        # 取消
        cancel: ()->
            select_set.parentRefresh()

        # 搜索内容
        search: (clear = false) ->
            if true == clear
                select_set.searchQuery = ''
            select_set.getList('re', select_set.searchQuery)

        showImg: (el) ->
# 已下载到本地
            if el['imgs'] and el['imgs'][select_set.uid]
                return select_set.host + el['imgs'][select_set.uid]
            # 平台1 爱奇艺 图片不能直接显示
            if el.platform in NOTSHOWIMG_PLATFORM
                return '/images/default.png'
            else
# 其他平台可以直接显示
                return el['img']

        getList: (ac = '', searchQuery = '') ->
            select_set.emptyList('loading')
            # 重新获取
            if 're' == ac
                select_set.currentPage = 1
                select_set.list = []
                select_set.searchQuery = searchQuery
            else
                select_set.currentPage++
            api.getApi('/videoset/get_resList', {
                'page': select_set.currentPage
                'count': select_set.count
                'order': 'allplaynum'
                'direction': -1
                'type': 'dledAndDlOneAndCreate'
                'title_query': select_set.searchQuery
                'deviceId': select_set.args.deviceId
            }, (result)->
                if SUCCESS == result.code
                    if result.list.length > 0
                        select_set.list = select_set.list.concat(result.list)
                    select_set.emptyList()
                else
                    # 空
                    select_set.emptyList(false)
            )

        #  清空本页数据
        emptyList: (status = []) ->
            select_set.error = status

        # 添加至本影片集
        addTo: (toSetId)->
            api.getApi('/videoset/add_videos', {
                "videoIds": JSON.stringify(select_set.args.selectedVideo)
                "deviceId": select_set.args.deviceId
                "toSetId": toSetId
            }, (result)->
                if SUCCESS == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'success', {'autoHide': 2000})
                    select_set.parentRefresh()
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 外部列表刷新
        parentRefresh: () ->
            if (select_set.refreshModule)
                require [select_set.refreshModule['mod']], (refresh) ->
                    refresh[select_set.refreshModule['fun']]()

        # module refresh fun
        refreshModule: {}
        args: {}
        init: (url, ac = 0, refreshModule = {}, args = {}) ->
            avalon.log('select_set page load complete')
            select_set.url = url
            select_set.refreshModule = refreshModule
            select_set.args = args
            select_set.ac = ac

            select_set.currentPage = 0
            select_set.list = []
            select_set.searchQuery = ''

            select_set.getList()
    })

    return select_set