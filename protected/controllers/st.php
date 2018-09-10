<?php
namespace controllers;
use \strawframework\base\Controller;
/**
 *  服务面板
 */
class St extends Controller{


    public function __construct(){

        //加载模板
        parent::__construct($isView=true);

        if (!$_SESSION['status_account'] && 'straw' != ACTION_NAME)
            redirect('/st/straw');
    }


    CONST SERVICES = ['mongod', 'mysql', 'nginx', 'php-fpm'];
    public function index(){
        echo '<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
';
        echo '<a href="/">[RETURN]</a>&nbsp;';
        echo '<a href="">[REFRESH STATUS]</a><br/><br/>';
        foreach (self::SERVICES as $service) {

            exec(sprintf('/usr/bin/sudo /usr/bin/service %s status', $service), $output);
            echo sprintf('%s status %s&nbsp;<a href="/st/re?n=%s">[RE]</a><br/><br/>', $service, json_encode($output, JSON_UNESCAPED_UNICODE), $service);
            unset($output);
        }
    }

    public function re(){
        $n = trim($_GET['n']);
        if (!$n || !in_array($n, self::SERVICES))
            redirect('/status', 2, '操作失败');

        exec(sprintf('/usr/bin/sudo /usr/bin/service %s restart', $n), $output);
        redirect('/status', 5, serialize($output) . ' 5秒后自动返回');
    }


    public function straw(){
        if (IS_POST){
           $account = $_POST['account'];
           if ($account && $account == 'drmfslxD'){
               $_SESSION['status_account'] = 1;
               redirect('/st');
           }else{
               $this->assign('error', 1);
           }
        }
        $this->display('dashboard/status_straw', false);
    }
}
