<?php

/**
 * ######## 开发环境配置 ########
 */

return [
    //数据库设置
    'db' => [
        //mongo example
        'mongo' => [
            'DB_TYPE' => 'mongodb',
            'DB_HOST' => '192.168.56.102',
            'DB_USER' => '',
            'DB_PWD'  => '',
            'WRITE_MASTER' => false, //读写分离
            'DB_PREFIX' => '',
            'DB_NAME' => 'pi_2017',
            'DB_PORT' => 27017
        ],
    ],

    //cache
    'cache' => [
        //测试使用本机
        'redis' => [
            'CACHE_TYPE' => 'redis',
            'CACHE_HOST' => '127.0.0.1',
            'CACHE_AUTH' => '',
            'CACHE_PORT' => 6379,
        ],
    ],

    //modules can read from json file
    //'config_path' => 'http://winterspring0.xwg.cc',
    'modules' => [
        'pi' => '//pi0.zlizhe.com'
    ],

    //pi 设置
    'pi_set' => [
        //图片存放位置
        'img_dir' => '/home/python/pi_robot/files/images/',
        //影片存放位置
        'video_dir' => '/home/python/pi_robot/files/',
    ],

    //常用设置
    'config' => [
        //winterspring
        // 'api_key' => '230d2f705f9281e82e6b6fad903835eb',
        'site_name' => '卡通世界',
        //网站主域名
        'site_domain' => 'zlizhe.com',
        //本应用 module
        'module_name' => 'pi',
        //路由方式
        // PATH_INFO 使用PATH格式Rewrite
        // default 兼容模式
        'router' => 'PATH_INFO',
        //default database
        'database' => 'mongo',
        //是否启用 cache  false or name
        'cache' => 'redis',
        //默认缓存时间 5min = 300
        'cache_expire' => 0,
    ],
];
