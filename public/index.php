<?php
//根据环境读取配置文件
// PRODUCTION 生产环境 DEVELOPMENT 开发环境 TEST 测试环境
define('APP_ENV', 'DEVELOPMENT'); //开发环境 打开此项
//define('APP_ENV', 'TEST'); //测试环境打开此项
//define('APP_ENV', 'PRODUCTION'); //生产环境打开此项

//生产环境 关闭 debug
if ('PRODUCTION' == strtoupper(APP_ENV)) {
    define('APP_DEBUG', FALSE);
} else {
    define('APP_DEBUG', TRUE);
}

define('SCRIPT_NAME', 'index');
define('DS', DIRECTORY_SEPARATOR);
define('ROOT_PATH', realpath(dirname(__FILE__) . DS . '..' . DS) . DS);
//fastcgi.conf  open_basedir remove on nginx conf
require(ROOT_PATH . 'strawframework' . DS . 'common' . DS . 'global.php');

(new \strawframework\Straw())->run();