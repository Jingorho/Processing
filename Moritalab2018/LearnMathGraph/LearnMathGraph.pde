/*
 * Learn Math Graph
 * 2018.04.26
 *
 * ############### 概要 ################
 * 2次関数のグラフの係数を入力して，ターゲット（爆弾）を撃ち落とすクソゲー．
 * 参照元 : https://machidar.wordpress.com/2012/09/03/processing-%EF%BC%92%E6%AC%A1%E9%96%A2%E6%95%B0%E3%81%AE%E3%82%B0%E3%83%A9%E3%83%95%E3%82%92%E6%9B%B8%E3%81%8F%EF%BC%88%E5%89%8D%E7%B7%A8%EF%BC%89/
 *
 */
 
 
 
///////////////////////////////////////////////
// ライブラリのインポート
///////////////////////////////////////////////
import controlP5.*; //テキストフィールドを簡単に作るためのライブラリ．

///////////////////////////////////////////////
// このプログラム全体で使用する変数を宣言する部分
///////////////////////////////////////////////
ControlP5 cp5;     //テキストフィールドを簡単に作るためのライブラリを使う準備．
PFont pfont;       //画面に描画するフォント
ControlFont cfont; //テキストフィールド内に描画するフォント

float w,h;       //座標画面の半分
int margin = 10; //ウインドウの大きさから座標画面の隙間

float x, y;    //座標用のx, y
int xgap = 30; //座標軸の間隔
int ygap = 30; //座標軸の間隔

boolean hardMode;     //難しいモードか否かを設定する変数
boolean updateTarget; //グラフでターゲットを撃ったときに更新する
float targetX = 100;  //ターゲットのx座標
float targetY = 200;  //ターゲットのy座標

PImage img; //ターゲットの画像




///////////////////////////////////////////////
// SETUP : このプログラムの設定を書く部分
///////////////////////////////////////////////
void setup(){
  
  //画面の準備
  size(800, 500);
  background(33, 42, 55); //processingの紺色
  noStroke();             //画面の輪郭線なしの設定
  frameRate(30);          //フレームレート（1秒に何回draw()を実行するか）の設定
  
  w = (width-300)/2; //座標画面の半分(x軸描画に使う)
  h = height/2;      //座標画面の半分(y軸描画に使う)
  
  pfont = createFont("Hiragino", 24); //フォントの設定
  cfont = new ControlFont (pfont);    //フォントの設定(cp5用)
  
  img = loadImage("bomb.png"); //画像を読み込む
  
  hardMode = false;     //簡単モードで始める
  updateTarget = false; //ターゲットの更新
  
  cp5 = new ControlP5(this); //テキストフィールドの準備
  
  //テキストフィールドを設置
  cp5.addTextfield("input_a")
     .setPosition(margin*2 + w*2 + 30, margin*4 + 10)
     .setSize(60,60)
     .setFocus(true)
     .setColor(0).setColorBackground(color(255,255,255))
     .setLabel("")
     .setFont(cfont);
  cp5.addTextfield("input_b")
     .setPosition(margin*2 + w*2 + 80 + 30, margin*4 + 10)
     .setSize(60,60)
     .setFocus(true)
     .setColor(0).setColorBackground(color(255,255,255))
     .setLabel("")
     .setFont(cfont);
  cp5.addTextfield("input_c")
     .setPosition(margin*2 + w*2 + 160 + 30, margin*4 + 10)
     .setSize(60,60)
     .setFocus(true)
     .setColor(0).setColorBackground(color(255,255,255))
     .setLabel("")
     .setFont(cfont);
  x = 0;
  y = 0;
  
}//setup()終わり


///////////////////////////////////////////////
// DRAW : このプログラムでの具体的な処理を書く部分
///////////////////////////////////////////////
void draw(){
  //難易度モード設定
  if(keyPressed){
    if(key=='h'){
      hardMode = true;
    }else if(key=='e'){
      hardMode = false;
    }
  }
  
  //左側の座標画面で軸を描く関数を呼び出す
  drawAxis();
  
  //右側の式を書く関数を呼び出したり
  fill(color(255,255,255)); //描画色を白色に
  drawNums(hardMode);       //式を書く関数を呼び出す
  float a,b,c;              //入力された係数などの数値を入れるための変数
  
  //難易度モードにより処理を変える
  if(hardMode){
    //a,b,cにテキストフィールドで入力された値をそのまま代入（Stringからfloatに変換して）
    a = float( cp5.get(Textfield.class,"input_a").getText() );
    b = float( cp5.get(Textfield.class,"input_b").getText() );
    c = float( cp5.get(Textfield.class,"input_c").getText() );
  }else{
    //平方完成された後のテキストフィールドに入力された値を，a,b,cに計算してから代入
    a = float( cp5.get(Textfield.class,"input_a").getText() );
    float axis = float( cp5.get(Textfield.class,"input_b").getText() );
    float pnt = float( cp5.get(Textfield.class,"input_c").getText() );
    b = a * 2*axis;          //xの1次式の係数bは，平方完成の式を展開すると2a*軸なので
    c = a * axis*axis + pnt; //xの0次式の係数cは，平方完成の式を展開するとa*軸^2なので
  }
  
  //赤色でグラフ描画
  strokeWeight(2); //グラフの太さを2に設定
  stroke(255, 0, 0);//グラフの色を赤色に設定
  drawGraph(a, b, c);//グラフ描画
  
  //グラフでターゲットを撃ったら，ターゲットの位置を更新する
  if(updateTarget){
    //座標画面の左上から右下までの座標の中からランダムで数値を取得して座標に代入
    targetX = random(margin, w*2-margin);
    targetY = random(margin, h*2-margin);
    println("point: " + targetX + " " + targetY); //コンソールに表示
    updateTarget = false; //一回updateしたら次に更新されるまで更新オフにする
  }
  
  //ターゲット描画
  image(img, targetX, targetY);
  
}//draw()終わり



///////////////////////////////////////////////
// drawAxis : x, y軸を描く
///////////////////////////////////////////////
void drawAxis(){
  strokeWeight(1);        //描画の太さを1pxに設定
  background(33, 42, 55); //背景色を紺色に設定
  fill(255);              //描画色を白色に設定
  rect(margin, margin, w*2-margin*2, h*2-margin*2); //座標ウインドウ
  
  stroke(44, 53, 65);                           //描画色を灰色に設定
  line(margin, h+margin, margin+w*2, h+margin); //x軸描画
  line(w+margin, margin, w+margin, margin+h*2); //y軸描画
  fill(44, 53, 65);                             //描画色を灰色に設定
  textSize(16);                                 //フォントのサイズを16pxに設定
  text("x", margin+w*2-40, margin+h-10);        //'x'という文字を描画
  text("y", margin+w+10, margin+10);            //'y'という文字を描画
  text("O", margin+w+10, margin+h-10);          //'O'という文字を描画
}//drawAxis()終わり


///////////////////////////////////////////////
// drawNums　: 式とか文字を書く．
///////////////////////////////////////////////
void drawNums(boolean _hardMode){
  textFont(pfont); //フォントを設定
  textSize(26);    //フォントのサイズを26pxに設定
  
  //難易度モードによって処理を変える
  if(_hardMode){
    //式や文字の描画．描画位置はぶっちゃけ実行しながら決めうちでテキトーに調整した
    text("(a, b, c)", margin*2+w*2, margin*4);
    text("=", margin*2+w*2, margin*4 + 30);
    
    text("y = ", margin*2+w*2, margin*4+120);
    text(cp5.get(Textfield.class,"input_a").getText(), margin*2+w*2 + 60, margin*4+120);
    text("x +", margin*2+w*2 + 90, margin*4+120);
    textSize(15); text("2", margin*2+w*2 + 107, margin*4+110); textSize(26); 
    text(cp5.get(Textfield.class,"input_b").getText(), margin*2+w*2 + 150, margin*4+120);
    text("x +", margin*2+w*2 + 180, margin*4+120);
    text(cp5.get(Textfield.class,"input_c").getText(), margin*2+w*2 + 240, margin*4+120);
  }else{
    //式や文字の描画．描画位置はぶっちゃけ実行しながら決めうちでテキトーに調整した
    text("(係数, 軸, 頂点)", margin*2+w*2, margin*4);
    text("=", margin*2+w*2, margin*4 + 30);
    
    text("y = ", margin*2+w*2, margin*4+120);
    text(cp5.get(Textfield.class,"input_a").getText(), margin*2+w*2 + 60, margin*4+120);
    text("(x +", margin*2+w*2 + 90, margin*4+120);
    text(cp5.get(Textfield.class,"input_b").getText(), margin*2+w*2 + 150, margin*4+120);
    text(")", margin*2+w*2 + 180, margin*4+120);
    textSize(15); text("2", margin*2+w*2 + 190, margin*4+110); textSize(26); 
    text(") + ", margin*2+w*2 + 180, margin*4+120);
    text(cp5.get(Textfield.class,"input_c").getText(), margin*2+w*2 + 230, margin*4+120);
    
  }//if
}//drawNums




///////////////////////////////////////////////
// drawGraph : グラフを描く．
///////////////////////////////////////////////
void drawGraph(float ad, float bd, float cd){
  
  int xprev = -1;
  int yprev = -1;
  
  //x座標0~ウインドウ幅までx座標をずらしながらグラフ描画
  for (int x=0; x<w*2; x++) {
    int xt = x - (int)w;                      //設定したx座標の間隔に合わせて座標を変換
    float xd = (float)xt/(float)xgap;         //設定したx座標の間隔に合わせて座標を変換
    float yd = ad * xd * xd + bd * xd + cd;   //y = ax^2+bx+c
    int y = (int)h - (int)(yd * (float)ygap); //設定したy座標の間隔に合わせて座標を変換
    
    if (xprev == 1) {
      //最初の一回は便宜的にpoint()で点を描画
      point(x + margin, y + margin);
    } else {
      //(x-1)とxとを結ぶ直線を描いて近似的に曲線に
      line(x + margin, y + margin, xprev + margin, yprev + margin);
    }
    //x,y座標を次に更新
    xprev = x;
    yprev = y;
    
    //描いているときにもし，ターゲットの+-20pxの位置にきたら，ターゲットの衝突判定を起こす
    if((targetX-20 <= x + margin)&&(x + margin <= targetX+20)
        &&
       (targetY-20 <= y + margin)&&(y + margin <= targetY+20) ){
      updateTarget = true;
      println("update target!!");
    }//if
    
  }//x座標0~ウインドウ幅までx座標をずらしながらグラフ描画
  
}//drawGraph
