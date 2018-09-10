<?php
namespace controllers;
use \strawframework\base\Controller;

/**
 * 任务
 * User: Zack Lee
 * Date: 2017/11/3
 * Time: 14:07
 */
class Task extends Controller {

    public function __construct() {
        //加载模板
        parent::__construct($isView = false);
    }


    # 添加新任务
    public function create() {

        $videoIds = $_REQUEST['videoIds'];
        $setId = $_REQUEST['set_id'];
        $fromDevice = $_REQUEST['fromDevice'];
        $toDevice = $_REQUEST['toDevice'];
        $type = $_REQUEST['type'];

        if (!$videoIds || !$setId || !$fromDevice || !$type) {
            $this->_error('参数错误');
        }

        $videoIds = json_decode($videoIds, true);

        $data = [
            'setId'      => $setId,
            'fromDevice' => $fromDevice,
            'toDevice'   => $toDevice,
            'type'       => $type,
            'videoIds'   => $videoIds,
        ];
        if (true == $this->taskModel->copyTaskExists($data)) {
            $this->_error('已有相同任务存在，请至任务菜单管理已添加任务');
        } else {

            $this->taskModel->newTask($data);
            $this->_success();
        }
    }

    //添加一个影片集
    public function add_set() {

        $platform = $_REQUEST['platform']; //哪个平台的url
        $link = $_REQUEST['link']; //影片合集的 url
        $deviceId = $_REQUEST['deviceId']; //直接标记这个平台下载中

        if (!$platform || !$link || !$deviceId) {
            $this->_error('参数错误');
        }

        if (true == $this->taskModel->addSetExists($link)) {
            $this->_error('已有相同任务存在，请至任务菜单管理已添加任务');
        } else {

            $this->taskModel->newTask([
                                          'toDevice' => $deviceId,
                                          'platform' => $platform,
                                          'link'     => $link,
                                          'type'     => 'addset'
                                      ]);
            $this->_success('影片集任务添加成功');
        }
    }

    //添加一个影片内容
    public function add_video() {

        $platform = $_REQUEST['platform']; //哪个平台的url
        $link = $_REQUEST['link']; //影片合集的 url
        $deviceId = $_REQUEST['deviceId']; //直接标记这个平台下载中
        $setId = $_REQUEST['setId']; //直接标记这个平台下载中

        if (!$platform || !$link || !$deviceId || !$setId) {
            $this->_error('参数错误');
        }

        if (true == $this->taskModel->addSetExists($link)) {
            $this->_error('已有相同任务存在，请至任务菜单管理已添加任务');
        } else {

            $this->taskModel->newTask([
                                          'setId'    => $setId,
                                          'toDevice' => $deviceId,
                                          'platform' => $platform,
                                          'link'     => $link,
                                          'type'     => 'addvideo'
                                      ]);
            $this->_success('影片集任务添加成功');
        }
    }
}