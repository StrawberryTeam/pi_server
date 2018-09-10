'use strict'

define ['text!/Pages/play/view.html', 'avalon', 'api', 'page', 'avalon.cookie', 'select2'], (pageMain, avalon, api, page) ->
    avalon.templateCache.play_view = pageMain;
    vm = avalon.define({
        $id: 'view'
        title: ''
        mod: avalon.vmodels.play.mod
        host: avalon.vmodels.play.host
        service: avalon.vmodels.play.service
        uid: avalon.vmodels.play.uid
        url: null
        loading: '/Assets/logic/common/loading.html'
        # 剧集开始于
        currentPage: 1
        # 每页30集显示
        count: 12
        setId: 0
        videoId: 0

        summaryShow: false
        doggleSummary: () ->
            vm.summaryShow = !vm.summaryShow


# 随机出颜色
        rand_bg: (el, platform) ->
            limg = vm.set_bg(el, platform)
            return 'url(' + limg + ')'

        set_bg: (el, platform) ->
# 已下载到本地
            if el['imgs'] and el['imgs'][vm.uid]
                return vm.host + el['imgs'][vm.uid]
            # 平台1 爱奇艺 图片不能直接显示
            if platform in NOTSHOWIMG_PLATFORM
                return '/images/default.png'
            else
# 其他平台可以直接显示
                return el['img']
        error: ''
        #  清空本页数据
        emptyList: (status = []) ->
            vm.error = status
            vm.videoList = []
            vm.setting = {}
            vm.total = 0
            vm.nextPageHtml = null
            vm.rePageHtml = null
            vm.currentVideoInfo = {}
            vm.currentVideoInfo.name_pyshow = []
            vm.nameList = []
            vm.ondl = null
#            avalon.vmodels.play.title = ''

        videoCss: 'video-min'
        # 开始播放
        play: (num = '') ->
            if '' != num
                videoInfo = vm.videoList[num]
                vm.setCurrentVideo(num)
            else
                videoInfo = vm.currentVideoInfo

            avalon.log videoInfo

            # http://qxt-pan.cdn.xwg.cc/o_1ccfpevebtgc1961snq3hh1bv48.mp4
            #android
            if PLATFORM_ANDROIDTV == _clientInfo['platform']

                #setId _id setInfo > json string
                android.videoPlay(videoInfo.setId.$oid, videoInfo._id, vm.getVideoNum(num))
                return false
            else
                # web && pywebview
                videoStream = vm.setting['host'] + videoInfo['plays'][_clientInfo['uid']]
                videoEle = document.getElementById("playMain")
                videoEle.src = videoStream
#                videoEle.src = 'http://qxt-pan.cdn.xwg.cc/o_1ccfpevebtgc1961snq3hh1bv48.mp4'

#                videoEle.pause()
#                require ['logic/common/tips'], (tips) ->
#                    tips.showTips('该影片无法播放，请切换其他影片或切换播放设备', 'error')
#                return false

                videoEle.play()
                # 播放结束
                $('#playMain').bind('ended', () ->
                    $('#playMain').unbind('ended')
                    videoEle.pause()
                    vm.playendCall(num)
                )

        # 一集播放结束
        playendCall: (newNum) ->
            if newNum
                newNum = parseInt(newNum) + 1
            else
                newNum = 1

            if vm.videoList.length <= 0
                return false

            try
                vm.videoList[newNum]
                # 播放下一集
                vm.play(newNum)
                $("#FocusMovie" + newNum).focus()
            catch
                # 下一页, 自动播下一页下一集
                vm.nextPage()


        # web 页面关闭播放
        close: () ->
            videoObj = $("#playMain")
            videoObj.removeAttr('controls')
            videoObj.removeAttr('src')

        # 将拼音中 英文/数字 转为 list 以对齐文字
        setPinyinEnToList: (list) ->
            # 还没有生成拼音 或不需要生成拼音的
            if !list || list.length <= 0
                return []
            notZh = /[A-Z|0-9]/
            pinyinList = []
            for pinyin in list
                if true == notZh.test(pinyin)
                    enList = pinyin.split('')
                    for en in enList
                        pinyinList.push(en)
                else
                    pinyinList.push(pinyin)
            return pinyinList

        # 合集信息
        setInfo: {}
        setNameList: []
        getInfo: () ->
            vm.setInfo = {}
            vm.setNameList = []
            api.getApi('/videoset/get_info', {
                '_id': vm.setId
            }, (result)->
                if SUCCESS == result.code
                    vm.setInfo = result.item
                    vm.setNameList = vm.setInfo['title'].split('')
                    vm.setInfo.title_pyshow = vm.setPinyinEnToList(result.item.title_pyshow)
                    # 重新设置 title
                    avalon.vmodels.play.title = vm.setInfo['title'] + ' (' +vm.setInfo['now_episode'] + ')'
                    document.title = avalon.vmodels.play.title
                    vm.getVideoList()
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )

        # 剧集的 集数值计算
        getVideoNum: (index) ->
            return (parseInt(index) + 1) + ((vm.currentPage * vm.count) - vm.count)

        # 下载影片集
        dl: (id) ->
            api.getApi('/videoset/set_todownload', {"id": id}, (result)->
                if SUCCESS == result.code
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips('已加入下载队列, 请稍后查看', 'success', {'autoHide': 2000})
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )


        # 本设备设置
        setting: {}
        total: 0
        totalPage: 0
        # 影片集
        videoList: []
        #rePage
        rePageHtml: null
        rePage: () ->
            vm.currentPage--
            vm.getVideoList()
        # 下一页
        nextPageHtml: null
        nextPage: () ->
            document.documentElement.scrollTop = document.body.scrollTop = 0
            avalon.log vm.totalPage
            avalon.log vm.currentPage
            vm.currentPage++
            if vm.currentPage <= vm.totalPage
                vm.getVideoList()
            else
                # 重新播放
                vm.currentPage = 0
                vm.nextPage()

                # 设置为 最后一集
                # 本剧集所有影片播放完成
                require ['logic/common/tips'], (tips) ->
                    tips.showTips(avalon.vmodels.play.title + ' 已全部播放完毕', 'error', {
                        'okVal': '',
                        'autoHide': 3000
                    })

        nameList : []
        ondl: null
        # 设置当前默认的视频
        setCurrentVideo: (index) ->
#            vm.currentVideoInfo['name_list'] = null
            # 默认给第一个
            if vm.videoList[index]
                vm.currentVideoInfo = vm.videoList[index]
            else
                # 一个都没下完的情况下
#                vm.currentVideoInfo = vm.setInfo
                vm.currentVideoInfo = {
                    "name": vm.setInfo['title']
                    "summary": vm.setInfo['summary']
                    "img": vm.setInfo['img']
                    "platform": vm.setInfo['platform']
                }
            if vm.setInfo['dl'] && "1" in vm.setInfo['dl']
                # 下载中 未下载完成
                vm.ondl = true
            else
                vm.ondl = false
#                avalon.log vm.currentVideoInfo

            avalon.log vm.currentVideoInfo
            vm.nameList = []
            vm.nameList = vm.currentVideoInfo['name'].split('')
            vm.currentVideoInfo.name_pyshow = vm.setPinyinEnToList(vm.currentVideoInfo.name_pyshow)
#            avalon.log vm.currentVideoInfo['name_list']
            # to top with phone
#            $(window).scrollTop(0);

        currentVideoInfo: {}
        getVideoList: () ->
            vm.emptyList('loading')
            api.getApi('/videolist/get_list', {
                'page': vm.currentPage
                'count': vm.count
                'setId': vm.setId
                'order': '_id' # 每个账户可以进行 order 的设定，@todo 根据影片有没有看过来执行不同的 order
                'direction': 1
                'type': 'dl' # 仅已下载的单集
            }, (result)->
#                result.code = ISEMPTY
                if SUCCESS == result.code
                    vm.emptyList()
                    vm.videoList = result.list
                    vm.setting = result.setting

                    vm.setCurrentVideo(0)
                    vm.total = result.total
                    vm.totalPage = Math.ceil(result.total / parseInt(vm.count))
                    # max
                    pageTotal = vm.count * vm.currentPage
                    pageMax = pageTotal + vm.count
                    if pageMax > vm.total
                        pageMax = vm.total
                    # 下一页按钮
                    if pageTotal >= vm.total
                        vm.nextPageHtml = null
                    else
                        vm.nextPageHtml = pageTotal + 1 + ' - ' + pageMax + '集'
                    # 上一页按钮
                    if vm.currentPage == 1
                        vm.rePageHtml = null
                    else
                        vm.rePageHtml = parseInt(pageTotal - vm.count - vm.count) + ' - ' + (pageTotal - vm.count) + '集'
                    setTimeout(()->
                        $(".FocusPlay").focus()
                        # web 版自动播放首先可用集
                        if PLATFORM_WEB == _clientInfo['platform']
                            vm.play('')
                    , 200)

                else if ISEMPTY == result.code
                    # 无数据了
                    vm.emptyList(false)
                    vm.setCurrentVideo(0)
                    setTimeout(()->
                        $(".FocusPlay").focus()
                    , 200)
#                    require ['logic/common/tips'], (tips) ->
#                        tips.showTips('当前剧集所有影片正在下载中, 请稍后查看', 'success', {'redirectUrl': '/'})
                else
                    require ['logic/common/tips'], (tips) ->
                        tips.showTips(result.msg, 'error')
            )


        init: (url) ->
            avalon.log('play view page load complete')
            vm.url = url
            vm.currentPage = 1
#            vm.currentPage = if vm.url.page then vm.url.page else 1
            vm.setId = vm.url.setid
            vm.videoId = vm.url.videoid
            vm.ondl = false
            vm.emptyList('loading')
            vm.getInfo()


    })

    return vm

