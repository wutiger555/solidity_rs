pragma solidity ^0.4.23;
contract reMain{
    address buyer; // 買家初始化地址
    address gov_agent; // 政府（稅款）
    address bank_agent; // 銀行（貸款）
    bool HPV_collect;   // 房屋現值確認
    bool DT_cal_collect;// 契稅確認
    bool LVIT_cal_collect;// 土地增值稅確認
    bool loan_cal_collect;// 貸款確認
    string [13] data ;
    // 模擬合約狀態轉換
    // 表示合約目前執行至何階段 0: 買家填入資訊, 1: 銀行、政府審核, 2: Done
    enum Status {
        contractInit, agentsVerify, contractComplete
    }
    //將status物件new出來
    Status public status;
    event statusEvt(Status status);
    //確認使用者身分為買家
    modifier isBuyer{
        require(msg.sender == buyer);
        _;
    }
    //確認使用者身分為銀行部門
    modifier isBank{
        require(msg.sender == bank_agent);
        _;
    }
    //確認使用者身分為政府部門
    modifier isGov{
        require(msg.sender == gov_agent);
        _;
    }
    //確認合約狀態才可執行
    modifier inStatus(Status _status){
        require(status == _status);
        _;
    }    
    // 買方初始化填寫資料 填寫完畢Deployed後 則智能合約開始運行
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
    data[11]=LVIT_cal(data[10],data[9],area);//土地增值稅
    data[12]=loan_cal(data[6]);//貸款
    
    buyer = msg.sender; // 紀錄buyer address
    //emit表示觸發事件
    emit statusEvt(Status.agentsVerify); // 資料填寫完成 轉移到審核狀態
    }
    
    //--------------------------------智能合約在初始化時自動運算------------------------------------
    /**
     * fake data:
     * DT = 10000
     * loan = 5000000
     * LVIT = 要算
     * ALV = 278347
     * CLV = 1018182
     * HPV = 1000000
     */
    //===================== Deed Tax Calculate 契稅計算
    // input: 房屋現值, output: 契稅
    function DT_cal(string HPV_price) inStatus(Status.contractInit) returns(string){
        return "10000";
    }
    // Loan calculate 貸款計算
    //input: 房屋價格 output: 貸款金額
    function loan_cal(string bank_price)  inStatus(Status.contractInit) public returns(string){
        return "5000000";
    }
    //===================== Land Value Increment Tax Calculate 土地增值稅計算
    // (公告地價*面積)-(公告現值*面積)*10% = 土地增值稅
    // input: (公告地價, 公告現值, 面積), output: 土地增值稅
    function LVIT_cal(string ALV_price, string CLV_price, string area) inStatus(Status.contractInit) returns(string){
        uint _ALV_price = stringToUint(ALV_price);
        uint _CLV_price = stringToUint(CLV_price);
        uint _area = stringToUint(area);
        uint LVIT_price = (_ALV_price*_area)-(_CLV_price*_area)/10;
        return uintToString(LVIT_price);
    }
    //===================== Annoced Land Value&Current Land Value   土地公告現值＆公告地價獲取 從政府資料庫
    // input: 地址, output: 公告地價,土地公告現值
    function get_CLV_ALV(string addrss) inStatus(Status.contractInit) returns(string,string){
        uint ALV_price = 278347;  // fake 公告地價   data
        uint CLV_price = 1018182; // fake 土地公告現值data       
        return (uintToString(ALV_price),uintToString(CLV_price));
    }
    //===================== House Present Value Calculate 房屋現值獲取 從政府資料庫
    // input: 賣家姓名, output: 房屋現值
    function get_HPV(string name ) inStatus(Status.contractInit) returns(string){
        return "1000000";
    }

    //--------------------------------智能合約在初始化時自動運算 結束------------------------------------

    //--------------------------------比較資料------------------------------------

    function compareHPV_price(string gov_price) isGov inStatus(Status.agentsVerify) public returns(bool){
        if(keccak256(data[7])==keccak256(gov_price)){
            HPV_collect=true;
            check();
            return true;
        }
        else
            return false;
    }
    function compareDT_cal(string gov_price) isGov inStatus(Status.agentsVerify) public returns(bool){
        if(keccak256(data[8])==keccak256(gov_price)){
            DT_cal_collect=true;
            check();
            return true;
        }
        else
            return false;    
    }
    function compareLVIT_cal(string gov_price) isGov inStatus(Status.agentsVerify) public returns(bool) {
        if(keccak256(data[11])==keccak256(gov_price)){
            LVIT_cal_collect=true;
            check();
            return true;
        }
        else
            return false;
        
    }
    function compareloan_cal(string bank_price) isBank inStatus(Status.agentsVerify) public returns(bool){
        if(keccak256(data[12])==keccak256(bank_price)){
            loan_cal_collect=true;
            check();
            return true;
        }
        else
            return false;
    }
    
    //--------------------------------比較資料 結束------------------------------------
    
    //用於系統確認為銀行或是政府並將當前address記錄起來
    function settingRole (string role) public {
        if(keccak256(role)==keccak256("bank")){
            bank_agent = msg.sender;
        }
        if(keccak256(role)==keccak256("gov")){
            gov_agent = msg.sender;
        }
    }
    //確保所有資訊均為正確後，觸發最後事件contractComplete
    function check() public returns(bool){
        if(DT_cal_collect==true&&HPV_collect==true&&loan_cal_collect==true&&LVIT_cal_collect==true){
            emit statusEvt(Status.contractComplete);
            return true;
        }
        else
            return false;
    }
    
    
    
    //--------------------------------工具區-----------------------------------------------------------------------
    // ================= String Uint Convert Utils
    function stringToUint(string s) constant returns (uint) {
    bytes memory b = bytes(s);
    uint result = 0;
    for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
        if (b[i] >= 48 && b[i] <= 57) {
            result = result * 10 + (uint(b[i]) - 48); // bytes and int are not compatible with the operator -.
        }
    }
    return result; // this was missing
}

    function uintToString(uint v) constant returns (string) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i); // i + 1 is inefficient
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; // to avoid the off-by-one error
        }
        string memory str = string(s);  // memory isn't implicitly convertible to storage
        return str;
}
    //-------------------------------------------------------------------------提取資訊/測試
    function getData() view returns(string, string, string, string, string){
        return (data[7],data[8],data[9],data[10],data[11]);
    }
    function getLVIT() view returns(string){
        return (data[11]);
    }
    function getRoles() view returns(address, address, address){
        return (buyer, gov_agent, bank_agent);
    }
    
}