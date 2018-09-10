<?php
namespace models;
use \strawframework\base\Logicmodel;

/**
 * 影片
 */
class VideoLogic extends Logicmodel {


    /**
     * 添加影片至新影片集中
     * @param $videos
     * @param $setId
     */
    public function addVideos2Set($videos, $setId, $deviceId){

        //复制影片
        $cpStatus = $this->videoListModel->cpVideos($videos, $setId);
        if (false == $cpStatus){
            ex("复制影片失败");
        }

        $playNum = $this->videoListModel->getPlayNumsViaIds($videos, $deviceId);
        //更新 set 状态
        $upsetStatus = $this->videoSetModel->updateVideoNum($setId, $cpStatus, $playNum, $deviceId);
        if (FALSE == $upsetStatus){
            ex("影片集数据更新失败", '', Controller::FAIL);
        }

        return true;
    }
}
