<?php
namespace controllers;
use \strawframework\base\Controller;
/**
 *  web / Android tv / 手机版 首页
 */
class Index extends Controller{

    public function __construct(){
        //加载模板
        parent::__construct($isView=true);

        //uid default 0
        //获取 header 用户信息 与平台信息
        $getUid = conv2int($_GET['uid']);
        $cookieUid = conv2int($_COOKIE['uid']);

        if (!$_SESSION['clientInfo'])
            $clientInfo = $_SERVER['HTTP_CARTOON'] ? json_decode($_SERVER['HTTP_CARTOON'], true) : [];
        else
            $clientInfo = $_SESSION['clientInfo'];

        //无平台信息默认
        if (!$clientInfo)
            $clientInfo['platform'] = \models\Setting::PLATFORM_WEB;
        else
            $_SESSION['clientInfo'] = $clientInfo;

        //优先使用get
        if ($getUid){
            $clientInfo['uid'] = $getUid;
        }else if (!$clientInfo['uid']){
            //$clientInfo['uid'] = $cookieUid;
            if ($cookieUid)
                redirect('/?uid=' . $cookieUid);
        }else if ($clientInfo) {
            //使用 header
        }else{
            //未选择任何用户
            $clientInfo['uid'] = 0;
        }

        //var_dump($clientInfo);die;
        //$clientInfo['platform'] = SettingModel::PLATFORM_ANDROIDTV;
        $playSetting = [];
        if ($clientInfo['uid']){
            setcookie('uid', $clientInfo['uid'], time() + 60 * 60 * 24 * 30 , '/');
            //获取本播放设备信息
            $playSetting = $this->settingModel->getInfo($clientInfo['uid'], ['_id' => false, 'cycle', 'host', 'name']);
        }
        $this->assign('_playSetting', json_encode($playSetting));
        $this->assign('_clientInfo', json_encode($clientInfo));
        $this->assign('_siteName', parent::$config['config']['site_name']);
    }


    //play page
    public function index(){
        //$uid = $_COOKIE['uid'] ?: $_REQUEST['uid'];
        //$firstData = [
        //    'code' => self::ISEMPTY,
        //    'msg'  => ''
        //];
        //if ($uid){
        //    //加载首屏数据 提升首屏速度
        //    $videosetCls = new VideosetController();
        //    $firstData = $videosetCls->get_resList($uid, $type = 'dledAndDlAtlastone', $count = 12, $order = 'sorts.' . $uid, $direction = -1);
        //}
        //$this->assign('firstData', json_encode($firstData));
        $this->display('play/layout', false);
    }

    //部分显示
    public function part(){
        $this->display('play/part', false);
    }


    public function show_pic(){

        // $p = $_GET['p'];

        exit();
        $p = "images/default.png";
        if ($p){
            $content = getUrl($p);
            echo $content;
            exit();
        }
    }

    //检查当前 uid 所在 host 是否 ok
    public function check_device(){
        $uid = $_REQUEST['uid'];

        if (!$uid)
            $this->_error('未选择设备');

        $setting = $this->settingModel->getSetting($uid);

        $url = sprintf('%s/re.html', trim($setting['host']));
        $res = getUrl($url, $method = "GET", '', '', 3);

        if ('success' == trim($res)){
            $this->_success();
        }else{
            $this->_error();
        }
    }
}
