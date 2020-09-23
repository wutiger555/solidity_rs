pragma solidity ^0.4.23;
contract reMain{
    address buyer; // 買家初始化地址
    address gov_agent; // 政府（稅款）
    address bank_agent; // 銀行（貸款）111
    
    string [12] data ;
    
    // 0: 買家填入資訊, 1: 銀行、政府審核, 2: Done
    enum Status {
        contractInit, agentsVerify, contractComplete
    }
    Status public status;
    event statusEvt(Status status);
    
    modifier isBuyer{
        require(msg.sender == buyer);
        _;
    }
    
    modifier isBank{
        require(msg.sender == bank_agent);
        _;
    }

    modifier isGov{
        require(msg.sender == gov_agent);
        _;
    }
    //確認合約狀態才可執行
    modifier inStatus(Status _status){
        require(status == _status);
        _;
    }
    
    // 買方填寫
    // 買方姓名,賣家姓名,面積,建物現況格局,聯絡電話,建物門牌,交易總價
    
    constructor(string buyerName,string sellerName,string area,string buildPattern,string phone,string houseNumber,string totalPrice){    
    data[0]=buyerName; // 買家姓名
    data[1]=sellerName; // 賣家姓名
    data[2]=area; // 面積
    data[3]=buildPattern; // 建物現況格局
    data[4]=phone; //聯絡電話
    data[5]=houseNumber; //建物門牌
    data[6]=totalPrice; //交易總價
    data[7]=get_HPV(sellerName); // 房屋現值
    data[8]=DT_cal(data[7]); // 契稅
    (data[9], data[10])=get_CLV_ALV(houseNumber); // 公告地價, 土地公告現值
    data[11]=LVIT_cal(data[10],data[9],area);
    
    buyer = msg.sender; // 設定buyer address
    emit statusEvt(Status.agentsVerify); // 資料填寫完成 轉移到審核狀態
    }
    
    /**
     * 智能合約在初始化時自動運算 - Start
     */
    // House Present Value Calculate 房屋現值獲取 從政府資料庫
    // input: 賣家姓名, output: 房屋現值
    function get_HPV(string name) returns(string){
        return "1000000";
    }
    // Deed Tax Calculate 契稅計算
    // input: 房屋現值, output: 契稅
    function DT_cal(string HPV_price) returns(string){
        return "10000";
    }
    // Annoced Land Value&Current Land Value   土地公告現值＆公告地價獲取 從政府資料庫
    // input: 地址, output: 公告地價,土地公告現值
    function get_CLV_ALV(string addrss) returns(string,string){
        // uint ALV_price = 278347;  // fake 公告地價   data
        // uint CLV_price = 1018182; // fake 土地公告現值data
         
        return ("278347","1018182");
    }
    // (公告地價*面積)-(公告現值*面積)*10%
    // Land Value Increment Tax 土地增值稅計算
    // input: (公告地價, 公告現值, 面積), output: 土地增值稅
    function LVIT_cal(string ALV_price, string CLV_price, string area) returns(string){
        // uint LVIT_price = (ALV_price*area)-(CLV_price*area)/10;
        uint LVIT_price = 1234567;
        return uintToString(LVIT_price);
    }
    function uintToString(uint v) constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }
    function getData() view returns(string, string, string, string, string){
        return (data[7],data[8],data[9],data[10],data[11]);
    }
    /**
     * 智能合約在初始化時自動運算 - End
     */
}