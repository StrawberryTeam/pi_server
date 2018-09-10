<?php
namespace controllers;
use \strawframework\base\Controller;
/**
 * User: Zack Lee
 * Date: 2017/11/3
 * Time: 14:07
 */
class Videoset extends Controller{

    public function __construct(){
        //加载模板
        parent::__construct($isView=false);
    }

    //获取总分类
    public function get_category(){

        $page = $_REQUEST['page'] ?: 1;
        $keyword = $_REQUEST['query'] ?: '';
        $platform = $_REQUEST['platform'] ?: 0;
        $count = $_REQUEST['count'];

        //排序方法 默认按时间
        $order = trim($_REQUEST['order']) ?: '_id';
        //排序方向 默认按发布顺序
        $direction = in_array($_REQUEST['direction'], [1, -1]) ? intval($_REQUEST['direction']) : 1;

        $list = $this->videoSetModel->getList($page, $keyword, $platform, [$order => $direction, '_id' => 1], $count);

        if ($list['total'] == 0){
            $this->_error('', self::ISEMPTY);
        }else{
            $this->_success('', $list);
        }
    }

    //获取本部影片信息
    public function get_info(){

        $_id = $_REQUEST['_id'];

        if (!$_id)
            $this->_error('没有找到setId');

        $item = $this->videoSetModel->getInfo($_id);

        if ($item){
            $this->_success('', ['item' => $item]);
        }else{
            $this->_error('', self::ISEMPTY);
        }
    }

    // 获取所有本设备 未下载未在下载中的 剩余资源
    public function get_resList($guid = '', $type = '', $count = '', $order = '', $direction = ''){

        $uid = $_REQUEST['deviceId'];

        if (!$uid)
            $uid = $_REQUEST['uid'] ?: $guid;

        $page = $_REQUEST['page'] ?: 1;
        $keyword = $_REQUEST['query'] ?: '';
        $title_query = $_REQUEST['title_query'] ?: ''; //仅搜索标题
        $platform = $_REQUEST['platform'] ?: 0;
        if (!$count)
            $count = $_REQUEST['count'];

        if(!$type)
            $type = $_REQUEST['type'] ?: 'res';

        if (!$order)
            //排序方法 默认按时间
            $order = trim($_REQUEST['order']) ?: 'allplaynum';

        if (!$direction)
            //排序方向 默认按发布顺序
            $direction = in_array($_REQUEST['direction'], [1, -1]) ? intval($_REQUEST['direction']) : -1;

        $typeMap = [];
        $cached = false;
        switch ($type) {
            // 未下载 不在下载中的 资源
            case 'res':
                $typeMap = ['dl' => ['$ne' => $uid], 'dled' => ['$ne' => $uid], 'created_uid' => ['$ne' => $uid]];
                break;
            // 下载中资源
            case 'dl':
                $typeMap = ['dl' => $uid];
                break;
            // 已下载到本设备的
            case 'dled':
                $typeMap = ['dled' => $uid];
                break;
            // 正在下载 和 下载完成的
            case 'dledAndDl':
                $typeMap = ['$or' => [['dled' => $uid], ['dl' => $uid]]];
                $cached = true;
                break;
            // 至少下载了一集的 不显示隐藏项目
            case 'dledAndDlAtlastone':
                $typeMap = ['play_num.' . $uid => ['$exists' => true], 'hides' => ['$ne' => $uid]];
                $cached = true;
                break;
            // 下载中 或 至少下载一集的影片 包含自己创建的 (包含正在下载的，下载完成的，下载过几集又取消下载的)
            case 'dledAndDlOneAndCreate':
                $typeMap = ['$or' => [['play_num.' . $uid => ['$exists' => true]], ['dl' => $uid], ['created_uid' => $uid]]];
                $cached = true;
                break;
        }
        //只查找标题并 联合 typemap
        if ($title_query){
            $keyword = '';
            $typeMap['title'] = ['$like' => "^" . $title_query];
        }
        $list = $this->videoSetModel->getList($page, $keyword, $platform, [$order => $direction, '_id' => 1], $count, $typeMap, $cached);

        if ($guid){
            if (count($list['list']) <= 0){
                return [
                    'code' => self::ISEMPTY,
                    'msg'  => ''
                ];
            }else{
                return array_merge([
                                       'code' => self::SUCCESS,
                                       'msg'  => '',
                                       'ref'  => ''
                                   ], $list);
            }
        }else{
            if (count($list['list']) <= 0){
                $this->_error('', self::ISEMPTY);
            }else{
                $this->_success('', $list);
            }
        }
    }

    //设置为 需要下载的资源集
    public function set_todownload(){
        $uid = $_REQUEST['uid'];
        $_id = $_REQUEST['id'];

        if (!$uid || !$_id)
            $this->_error('参数不完整');

        $exists = $this->videoSetModel->getDlvideo($uid, $_id);

        if ($exists)
            $this->_error('该影片已位于本设备下载中列表');

        $this->videoSetModel->dlVideo($uid, $_id);

        $this->_success();
    }

    //移出下载中
    public function set_toundownload(){
        $uid = $_REQUEST['uid'];
        $_id = $_REQUEST['id'];

        if (!$uid || !$_id)
            $this->_error('参数不完整');

        $exists = $this->videoSetModel->getDlvideo($uid, $_id);

        if (!$exists)
            $this->_error('该影片不在本设备下载列表中');

        $this->videoSetModel->unDlVideo($uid, $_id);

        $this->_success();

    }

    //创建影片集
    public function create_set(){
        $deviceId = $_POST['deviceId'];
        $data = $_POST['data'];

        $img = $_FILES['img'];
        if (!$img)
            ex('必须上传一张封面图片');

        $avaiableType = ['image/jpeg', 'image/png', 'image/gif'];
        if (!in_array($img['type'], $avaiableType))
            ex('图片格式必须为 jpg/png/gif');

        $imgDir = parent::$config['pi_set']['img_dir'] . date('md');
        creatDir($imgDir);
        $imgurl = $imgDir . '/' . time() . '.jpg';
        //上传成功 保存图片
        if (move_uploaded_file($img['tmp_name'], $imgurl)) {
            $data['img'] = str_replace(parent::$config['pi_set']['img_dir'], 'images/', $imgurl);
        }else{
            ex(sprintf('图片上传失败请重试 %s', json_encode($img)));
        }


            //没有简介的内容
        if (!$data['summary'])
            $data['summary'] = $data['title'];

        if ($data['category']){
            $data['category'] = str_replace('，', ',', $data['category']);
            $data['category'] = explode(',', $data['category']);
        }else{
            unset($data['category']);
        }


        $this->videoSetModel->newSet($data, $deviceId);

        //成功
        redirect(sprintf('/dashboard#!/device:list?deviceId=%s&create_set_success', $deviceId));
        exit();
    }

    //向一个影片集添加 影片 (本设备中的)
    public function add_videos(){
        $videoIds = $_REQUEST['videoIds'];
        $toSetId = $_REQUEST['toSetId'];
        $deviceId = $_REQUEST['deviceId'];

        if (!$videoIds || !$toSetId || !$deviceId)
            $this->_error('参数错误');

        $videoIds = json_decode($videoIds, true);

        //复制影片至新的影片集
        $this->videoLogicModel->addVideos2Set($videoIds, $toSetId, $deviceId);

        $this->_success();
    }

    //变更设备排序
    public function change_sort(){
        $setId = $_REQUEST['setId'];
        $sort = $_REQUEST['sort'];
        $deviceId = $_REQUEST['deviceId'];

        if (!$setId || !is_numeric($sort) || !$deviceId)
            $this->_error('参数错误');

        $this->videoSetModel->updateSort($setId, $sort, $deviceId);

        $this->_success();
    }

    //更新影片集 隐藏状态
    public function change_hide(){

        $setId = $_REQUEST['setId'];
        $status = $_REQUEST['status'];
        $deviceId = $_REQUEST['deviceId'];

        if (!$setId || !$status || !$deviceId)
            $this->_error('参数错误');

        $this->videoSetModel->changeHide($setId, $status, $deviceId);

        $this->_success();
    }
}