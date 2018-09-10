<?php
namespace controllers;
use \strawframework\base\Controller;
/**
 *  后台统计面板
 */
class Dashboard extends Controller{


    public function __construct(){

        //加载模板
        parent::__construct($isView=true);


        // 检查 是否有密码
        if (!in_array(ACTION_NAME, ['straw', 'logout'])){
            if (!$_COOKIE['account']){
                redirect('/dashboard/straw');
            }
        }
        $getUid = $_COOKIE['uid'] ?: 0;
        $clientInfo = "{\"uid\": $getUid}";
        //获取本播放设备信息
        $playSetting = $this->settingModel->getInfo($getUid, ['_id' => false, 'cycle', 'host', 'name']);
        $this->assign('_playSetting', json_encode($playSetting));
        $this->assign('_clientInfo', $clientInfo);
    }


    public function index(){
        $this->display('dashboard/layout', false);
    }


    
    //dashboard
    public function straw(){

        if ($_POST){
            $account = $_POST['account'];
            if ('AeioU' !== $account){
                $this->assign('error', 1);
            }else{
                // 通过
                setcookie('account', 'ok', time() + 60 * 60 * 24 * 365, '/');
            }
        }
        if ($_COOKIE['account']){
            redirect('/dashboard');
        }
        $this->display('', false);
    }

    public function logout(){
        unset($_COOKIE['account']);
        redirect('/');
    }
}
