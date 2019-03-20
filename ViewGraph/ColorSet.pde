//参考 : https://ironodata.info/

class ColorSet{
  color colors[];
  color grayColor[];
  
  ColorSet(){
    colors = new color[12]; //ひとまず12色決め打ち
    colors[0] = #C7000B;  //赤
    colors[1] = #F9C270;  //オレンジ
    colors[2] = #FFF67F;  //黄色
    colors[3] = #C1DB81;  //黄緑
    colors[4] = #69BD83;  //緑
    colors[5] = #61C1BE;  //ティファニーブルー
    colors[6] = #54C3F1;  //ターコイズ
    colors[7] = #6C9BD2;  //空色
    colors[8] = #796BAF;  //紫
    colors[9] = #BA79B1;  //うす紫
    colors[10] = #EE87B4;  //ピンク
    colors[11] = #EF858C;  //サーモンピンク
    
    grayColor = new color[2];
    grayColor[0] = #e0e0e0; //薄いグレー
    grayColor[1] = #808080; //濃いグレー
    
  }//ColorSet コンストラクタ
  
  ///////////////////////////////////////////////
  // getColors
  ///////////////////////////////////////////////
  color getColors(int colorId) {
    return colors[colorId];
  }
  
  
  ///////////////////////////////////////////////
  // getGray
  ///////////////////////////////////////////////
  color getGray(int colorId) {
    return grayColor[colorId];
  }
  
  
  
}//ColorSet CLASS