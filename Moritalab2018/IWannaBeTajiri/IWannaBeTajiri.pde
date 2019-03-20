/*
 * IWannaBeTajiri
 * 2018.04.26
 * 
 * ############### 概要 ################
 * 田尻さんになって世界を慈愛で包みたい全ての人へ．
 * 参照元：http://hro.hatenablog.jp/entry/2014/12/26/015612
 * 
 */

///////////////////////////////////////////////
// ライブラリのインポート
///////////////////////////////////////////////
import processing.video.*; //ライブラリ"video"をインポートしてください（補足資料）
import gab.opencv.*; //ライブラリ"opencv"をインポートしてください（補足資料）
import java.awt.Rectangle;
import java.io.File;

///////////////////////////////////////////////
// このプログラム全体で使用する変数を宣言する部分
///////////////////////////////////////////////
Capture video;
OpenCV opencv;
Rectangle[] faces;

PImage[] picArray;
PImage pic;

int imgNum = 0;

///////////////////////////////////////////////
// SETUP : このプログラムの設定を書く部分
///////////////////////////////////////////////
void setup() {
  size(640, 480);
  video = new Capture(this, 640, 480, 30);
  video.start();
  
  File directory = new File("/Users/yukako/WorkSpace/Processing/Moritalab2018/IWannaBeTajiri/data");
  String[] fileArray = directory.list();
  //println("fileArray: " + fileArray[0]);
  picArray = new PImage[fileArray.length];
  
  if (fileArray != null) {
    for(int i=0; i<fileArray.length; i++){ picArray[i] = null; }
    for(int i=0; i<fileArray.length; i++) {
      picArray[i] = loadImage("img" + i + ".png");
    }
  }else{
    println(directory.toString() + "　は存在しません" );
  }
  
  //デフォルトは田尻さん
  pic = picArray[imgNum];
  
}//setup()終わり


///////////////////////////////////////////////
// DRAW : このプログラムでの具体的な処理を書く部分
///////////////////////////////////////////////
void draw() {
  if (video.available()){
    video.read();
  }
  opencv = new OpenCV(this, video);
  
  pic = picArray[imgNum];
  
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  faces = opencv.detect();

  image(opencv.getInput(), 0, 0);
  
  if(pic != null){
    //画像表示
    for (int i = 0; i < faces.length; i++) {
      image(pic, faces[i].x-25, faces[i].y-25, faces[i].width*1.3, faces[i].width*1.3);
      //(貼り付ける画像、ｘ座標、ｙ座標、横の長さ、縦の長さ)
      //画像の表示位置は微調整してください
    }//for終わり
  }
  
}//draw()終わり


void keyPressed(){
  if(key == '1'){
    imgNum = 0;
  }else if(key == '2'){
    imgNum = 1;
  }else if(key == '3'){
    imgNum = 2;
  }else{
    imgNum = 0;
  }
}
