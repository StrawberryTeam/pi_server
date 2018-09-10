<?php
namespace controllers;
use \strawframework\base\Controller;
/**
 * User: Zack Lee
 * Date: 2017/11/3
 * Time: 14:07
 */
class Search extends Controller{

    public function __construct(){
        //加载模板
        parent::__construct($isView=false);
    }

    //获取总分类
    public function get_list(){

        //$page = $_REQUEST['page'] ?: 1;
        $keyword = $_REQUEST['keyword'] ?: '';
        //$setId = $_REQUEST['setId'];
        $count = $_REQUEST['count'] ?: 30;

        $uid = $_REQUEST['uid'];

        $type = $_REQUEST['type'] ?: 'all';

        $keytype = $_REQUEST['keytype'] ?: 1;

        $typeMap = [];
        switch ($type) {
            // 未下载 不在下载中的 资源
            case 'all':
                break;
            // 已完成下载的
            case 'dl':
                $typeMap = [
                    '$or' => [
                        //video list
                        [('plays.' . $uid) => ['$exists' => True]],
                        //video set
                        [("play_num." . $uid) => ['$exists' => True]]
                        ]
                    ];
                break;
        }

        $results = $firstList1 = $listArr = [];
        //优先可取量 与 剩余量
        $firstCount = floor($count / 2);
        //@todo 等有播放量后调整
        //按播放量倒序，id正序
        $normalList1 = $this->videoSetModel->getList(1, strtolower($keyword), '', ['allplaynum' => -1, '_id' => 1], $count, $typeMap, true, null);
        $normalList2 = $this->videoListModel->getList(null, 1, strtolower($keyword), ['allplaynum' => -1, '_id' => 1], $count, $typeMap, true, null);
        //@todo 开始分词
        //优先取值 情况
        if (2 == $keytype || !preg_match("/^[a-zA-Z\s]+$/", $keyword)){
            //如果含有非英文的 只能直接查询
            $firstList1 = $normalList1['list'] ?: [];
            $k = 0;
            for ($i = 0; $i < $count; $i++) {
                //没值 或 大于 优先可取量
                if (!$firstList1[$k] || $k > $firstCount){
                    //换第二层级
                    $k = 0;
                    $firstCount = $count - (count($firstList1) > $firstCount ? $firstCount : count($firstList1)); //剩余可取量
                    $firstList1 = $normalList2['list'] ?: [];
                }
                if (!$firstList1[$k])
                    continue;
                $results[$i] = $firstList1[$k];
                $k++;
            }
        }else{
            $priority = $this->videoSetModel->isAllInitials($keyword);
            $spList1 = $this->videoSetModel->getList(1, strtolower($keyword), '', ['_id' => 1], $count, $typeMap, true, 'SP');
            $spList2 = $this->videoListModel->getList(null, 1, strtolower($keyword), ['_id' => 1], $count, $typeMap, true, 'SP');
            $pyList1 = $this->videoSetModel->getList(1, strtolower($keyword), '', ['_id' => 1], $count, $typeMap, true, 'PY');
            $pyList2 = $this->videoListModel->getList(null, 1, strtolower($keyword), ['_id' => 1], $count, $typeMap, true, 'PY');
            if (true == $priority) {
                //优先首拼
                $listArr[0] = $spList1['list'] ?: [];
                $listArr[1] = $spList2['list'] ?: [];
                $listArr[2] = $pyList1['list'] ?: [];
                $listArr[3] = $pyList2['list'] ?: [];
                $listArr[4] = $normalList1['list'] ?: [];
                $listArr[5] = $normalList2['list'] ?: [];
            }else{
                //优先全拼
                $listArr[0] = $pyList1['list'] ?: [];
                $listArr[1] = $pyList2['list'] ?: [];
                $listArr[2] = $spList1['list'] ?: [];
                $listArr[3] = $spList2['list'] ?: [];
                $listArr[4] = $normalList1['list'] ?: [];
                $listArr[5] = $normalList2['list'] ?: [];
            }

            $k = 0;
            $first1Count = floor($firstCount / 5) * 3; // 3/5 的结果显示 set 2/5 的结果显示 list
            $lastCount = $count - $firstCount; //非优先结果 剩余量
            $last1Count = floor($lastCount / 4); //非优先结果 每人可用量
            $level = 0; //层级
            $firstList1 = $listArr[$level];
            for ($i = 0; $i < $count; $i++) {
                //没值 或 大于 优先可取量
                if (!$firstList1[$k] || $k > $first1Count){
                    //换下层级
                    $level++;
                    $k = 0;
                    if (1 == $level){
                        $first1Count = $firstCount - (count($firstList1) > $first1Count ? $first1Count : count($firstList1)); //剩余可取量
                    }else if (5 == $level){
                        $first1Count = $count - count($results); //剩余可取量
                    }else{
                        $first1Count = $last1Count; //剩余可取量
                    }
                    unset($firstList1);
                    $firstList1 = $listArr[$level];
                }
                if (!$firstList1[$k])
                    continue;
                $results[$i] = $firstList1[$k];
                $k++;
            }
        }

        //最后看看不超过最大值
        $results = array_slice($results, 0, $count - 1);

        if (count($results) == 0){
            $this->_error('', self::ISEMPTY);
        }else{
            $this->_success('', ['list' => $results, 'total' => count($results)]);
        }
    }

}