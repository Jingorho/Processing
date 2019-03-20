/*
参考 : http://yoppa.org/bma10/1250.html

メモ:
stroke({色}); <- 線の色(この後rect()とかellipse()とかで描画)
Stroke(); <- 線なし
strokeWeight(10);
fill({色}); <- 塗りつぶしの色  noFill(); <- 塗りつぶしなし

TODO
- 解析のうむ 正規化，加算，積分
- 色など調整 プロットの大きさ プロット点の色
- 縦軸調整機能

*/
import controlP5.*;

ControlP5 cp5;

Toggle[] isShowToggle;
Toggle isAnimationToggle;
boolean isAnimation = true;

Range range;
int viewMin;
int viewMax;

RadioButton radioButton;

int fps = 60;
int lastUpdate = 0;
float oneSecX = 0;

int filterRange = 100;
String filterType = "";

int displayWidth = 1200;
int displayHeight = 600;
int paddingX = displayWidth/10;
int paddingY = displayHeight/10 + 10;
//String csvDataName = "/Users/3824/Desktop/Data/180120_rel_orihime/180120_rel_orihime.csv";
//String csvDataName = "/Users/3824/Desktop/Data/171214_rel_class/171214_rel_class_hara_time_2.csv";
String csvDataName = "/Users/yukako/Desktop/Data/1801_rel_class/data/180123_rel_class_scr.csv";
String xLabel = "time [hh:mm:ss]";
String yLabel = "Skin Conductance Response [μSiemens]";

boolean _show[];
color _graphColor[];

int graphType = 0;

int fontSize = 12;

FloatCsv data; //FloatCsvクラスのインスタンス
ColorSet colorSet;

float dataMin, dataMax; //表示するデータの最大値と最小値
float plotX1, plotY1; //プロットする画面のX座標とY座標の最小値
float plotX2, plotY2; //プロットする画面のX座標とY座標の最大値
float lineX, lineY;

int axisXMin, axisXMax;  //データaxisX(横軸)の最小値と最大値
int[] axisX; //データaxisX(横軸)の配列
String[] axisXStr;

int movieTimeHH = 0;
int movieTimeMM = 0;
int movieTimeSS = 0;
int movieStartTimeIndex = 0;

int rowCount;
int columnCount;
int currentColumn = 0;
String[] colNames;

float axisXInterval; //横軸の目盛り間隔
float axisYInterval; //縦軸の目盛り間隔
float axisYIntervalMinor;

PFont plotFont; 


///////////////////////////////////////////////
// SETUP
///////////////////////////////////////////////
void setup() { 
  size(displayWidth, displayHeight);
  surface.setResizable(true);
  frameRate(fps);

  //読み込むデータファイルを指定して、FloatCsvクラスをインスタンス化
  data = new FloatCsv(csvDataName);
  colorSet = new ColorSet();
  cp5 = new ControlP5(this);
  
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();//axisX手動で取り除く. あとでできたら変数化しておいて
  //columnCount = data.getColumnCount() - 1;//axisX手動で取り除く. あとでできたら変数化しておいて
  colNames = data.getColumnNames(); //colNamesはaxisXの<time>勝手に取り除かれてるので-1しなくていい
  viewMin = 0;
  viewMax = rowCount;
  
  //列の名前を配列axisXsに読み込む
  //axisXs = int(data.getRowNames());
  axisX = data.getIndexRowInt();
  axisXStr = data.getIndexRowString();
  
  //最小は、axisX配列の先頭
  axisXMin = axisX[0];
  //最大は、axisX配列の最後
  axisXMax = axisX[axisX.length - 1]; 

  //全ての数値から最小値を求める
  dataMin = data.getCsvMin(); //4桁.4桁で統一
  //全ての数値から最大値を求める
  dataMax = data.getCsvMax(); //4桁.4桁で統一
  
  axisXInterval = (axisXMax - axisXMin)/10;
  //axisYInterval = 0.5;
  //axisYIntervalMinor = 0.2;
  //axisYInterval = (dataMax - dataMin)/25;
  //axisYIntervalMinor = axisYInterval/10;
  axisYInterval = 10;
  axisYIntervalMinor = 50;
  println("axisYIntervalMinor: " + axisYIntervalMinor);
  
  //プロットする画面の座標の最大値(右端, 上端)と最小値(左端, 下端)を設定
  plotX1 = paddingX; 
  plotX2 = width - plotX1; 
  plotY1 = paddingY;
  plotY2 = height - plotY1;
  lineX = plotX1;
  oneSecX = (plotX2 - plotX1) / (axisXMax - axisXMin); //使うデータ数に応じた1秒間の座標の長さ(drawでも更新)
  
  
  //axisX列を除いたサンプル列数だけ設定
  _show = new boolean[columnCount];
  _graphColor = new color[columnCount];
  isShowToggle = new Toggle[columnCount];
  for(int i=0; i<columnCount; i++){
    _show[i] = true; //デフォルトで全サンプル表示
    _graphColor[i] = colorSet.getColors(i); //サンプルごとに色変える
    
    // create a toggle
    // addToggleで渡す引数をユニークにしないとpositionもユニークに生成されないらしい,
    isShowToggle[i] = cp5.addToggle(colNames[i], true)
                         .setPosition(plotX2+10, paddingY+10 + i*20)
                         //.setPosition(displayWidth-paddingX+10, paddingY + i*20)
                         .setLabel("")
                         .setSize(15,15)
                         .setColorActive(_graphColor[i]);
    //ラベルはdraw()で
  }//axisX列を除いたサンプル列数だけ設定
  
  
  //時系列ラインの再生ボタン
  isAnimationToggle = cp5.addToggle("isAnimation")
                         .setPosition(plotX2 + paddingX/2-15, paddingY/2-15)
                         .setLabel("is Animation")
                         .setSize(30,30)
                         .setColorLabel(0);
  
  range = cp5.addRange("rangeController")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(paddingX, paddingY-(40+fontSize*2))
             .setSize((int)rowCount/30, 30) //グラフ幅の1/10
             .setHandleSize(20)
             .setRange(0, (int)rowCount)
             .setRangeValues(0,(int)rowCount)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(#0080FF))
             .setColorBackground(colorSet.getGray(0));
             
  //映像時刻同期用設定input
  cp5.addTextfield("movieTimeHH")
     .setPosition((int)range.getPosition()[0] + (int)range.getWidth() + 20,
                  paddingY-(40+fontSize*2))
     .setSize(20,30)
     .setColorValue(color(0))
     .setColorBackground(colorSet.getGray(0))
     .setAutoClear(false);
   cp5.addTextfield("movieTimeMM")
     .setPosition((int)range.getPosition()[0] + (int)range.getWidth() + 25 + 20,
                  paddingY-(40+fontSize*2))
     .setSize(20,30)
     .setColorValue(color(0))
     .setColorBackground(colorSet.getGray(0))
     .setAutoClear(false);
   cp5.addTextfield("movieTimeSS")
     .setPosition((int)range.getPosition()[0] + (int)range.getWidth() + 50 + 20,
                 paddingY-(40+fontSize*2))
     .setSize(20,30)
     .setColorValue(color(0))
     .setColorBackground(colorSet.getGray(0))
     .setAutoClear(false);
       
  cp5.addBang("setMovieStartTime")
     .setPosition((int)range.getPosition()[0] + (int)range.getWidth() + 95,
                  paddingY-(40+fontSize*2))
     .setSize(90,30)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  
  
  cp5.addTextfield("filterRange")
     .setPosition((int)cp5.getController("setMovieStartTime").getPosition()[0]
                  + (int)cp5.getController("setMovieStartTime").getWidth() + 20,
                  paddingY-(40+fontSize*2))
     .setSize(20,30)
     .setColorValue(color(0))
     .setColorBackground(colorSet.getGray(0))
     .setAutoClear(true);
  cp5.addBang("setFilterRange")
     .setPosition((int)cp5.getController("setMovieStartTime").getPosition()[0]
                  + (int)cp5.getController("setMovieStartTime").getWidth() + 45,
                  paddingY-(40+fontSize*2))
     .setSize(90,30)
     .setColorBackground(colorSet.getGray(0))
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  
  radioButton = cp5.addRadioButton("radioButton")
     .setPosition(plotX2+10, isShowToggle[columnCount-1].getPosition()[1] + 40)
     .setSize(20,20)
     .setColorForeground(#0080FF)
     .setColorActive(#0080FF)
     .setColorLabel(color(0))
     //.setItemsPerRow(5)
     .setSpacingColumn(10)
     .addItem("Average", 2)
     .addItem("Median", 3)
     .addItem("RESET", 1);
  
  //cp5のcaption設定
  range.setCaptionLabel("");
  cp5.getController("movieTimeHH").setCaptionLabel("");
  cp5.getController("movieTimeMM").setCaptionLabel("");
  cp5.getController("movieTimeSS").setCaptionLabel("");
  cp5.getController("setMovieStartTime").setCaptionLabel("Set MovieStart Time");
  cp5.getController("setFilterRange").setCaptionLabel("Set Filter Range");
  //cp5.getController("rangeController").setCaptionLabel("");
  
  plotFont = createFont("SansSerif", fontSize);
  textFont(plotFont);
  smooth(); 
  
  data.printCsvStatus();
  
}//SETUP




///////////////////////////////////////////////
// DRAW
///////////////////////////////////////////////
void draw() { 
  //画面サイズを指定
  background(255);//白色
  
  //プロットするエリアを灰色の四角形で表示
  stroke(colorSet.getGray(0));
  strokeWeight(2);
  rectMode(CORNERS); 
  noFill(); 
  rect(plotX1, plotY1, plotX2, plotY2);
  
  //タイトルを表示
  drawTitle();
  //それぞれの軸ラベル(消費量/年)を表示
  drawAxisLabels();
  //横軸の値を表示
  drawAxisXLabels();
  //縦軸の値を表示
  drawAxisYLabels();
  //凡例を表示
  drawLegend();
  
  
  //データをプロット
  strokeWeight(1);
  noFill();
  for(int i=0; i<columnCount; i++){
    if(isShowToggle[i].getBooleanValue()){
      stroke(_graphColor[i]);
      drawGraph(i);
    }
  }
  
  //時系列を追うラインを描画
  drawLine();
  
  
}//DRAW












///////////////////////////////////////////////
// drawLine
///////////////////////////////////////////////
void drawLine(){
  if(lineX > plotX2){
    lineX = plotX1;
  }
  
  //マウスライン
  strokeWeight(0.5);
  stroke(colorSet.getGray(0)); //silver
  
  if((plotX1 <= mouseX && mouseX <= plotX2) 
  && (plotY1 <= mouseY && mouseY <= plotY2)){
    line(mouseX, plotY1, mouseX, plotY2);
    int mouseXPos = (int)map(mouseX, plotX1, plotX2, axisXMin, axisXMax);
    String mouseXPosTime = data.getIndexStringFromInt(mouseXPos);
    fill(colorSet.getGray(1));
    textAlign(LEFT);
    textSize(fontSize*1.3);
    text(mouseXPosTime + " (" + calcHHMMSS(mouseXPos - movieStartTimeIndex) + ")", 
         paddingX,
         plotY2 + 55+3);
  }
  
  
  
  
  //時系列ライン
  strokeWeight(1);
  stroke(#b22222); //firebrik
  line(lineX, plotY1, lineX, plotY2);
  
  //時系列ラインがいる場所の時刻を表示
  int axisXPos = (int)map(lineX, plotX1, plotX2, axisXMin, axisXMax);
  String axisXPosTime = data.getIndexStringFromInt(axisXPos);
  fill(colorSet.getGray(1));
  textAlign(LEFT);
  textSize(fontSize*1.3);
  text(axisXPosTime + " (" + calcHHMMSS(axisXPos - movieStartTimeIndex) + ")", 
       paddingX,
       plotY2 + 40);
       
  if( lastUpdate+1000 < millis()){
    if(isAnimation){
      //lineX++;
      lineX = lineX + oneSecX;
    }
    lastUpdate = millis();
  }
  
  //println("lastUpdate " + lastUpdate + " millis " + millis() + " sec ");
  
}//drawLine

///////////////////////////////////////////////
// calcHHMMSS
///////////////////////////////////////////////
String calcHHMMSS(float x){
  int secFromPlotX1 = int(x);
  int hh = 0;
  int mm = 0;
  int ss = 0;
  
  //60分以上
  if(3600 <= abs(secFromPlotX1)){
    hh = secFromPlotX1 / 3600;
    mm = (secFromPlotX1 % 3600) / 60;
    ss = (secFromPlotX1 % 3600) % 60;
  //1分以上60分未満
  }else if( 60 <= abs(secFromPlotX1) && abs(secFromPlotX1) < 3600){
    mm = secFromPlotX1 / 60;
    ss = secFromPlotX1 % 60;
  //1分未満0秒以上
  }else if( 0 <= abs(secFromPlotX1) && abs(secFromPlotX1) < 60){
    ss = secFromPlotX1;
  }
  
  return (nf(hh, 2) + ":" + nf(mm, 2) + ":" + nf(ss, 2));
}




///////////////////////////////////////////////
// setMovieStartTime
///////////////////////////////////////////////
public void setMovieStartTime() {
  int hh = int(cp5.get(Textfield.class,"movieTimeHH").getText());
  int mm = int(cp5.get(Textfield.class,"movieTimeMM").getText());
  int ss = int(cp5.get(Textfield.class,"movieTimeSS").getText());
  int movieTimeTotalSec = hh*3600 + mm*60 + ss;
  if(isAnimation){
    isAnimation = false;
  }
  movieStartTimeIndex = (int)map(lineX, plotX1, plotX2, axisXMin, axisXMax) - movieTimeTotalSec;
  
}//setMovieStartTime


///////////////////////////////////////////////
// setFilterRange
///////////////////////////////////////////////
public void setFilterRange() {
  filterRange = int(cp5.get(Textfield.class,"filterRange").getText());
}//setFilterRange



///////////////////////////////////////////////
// controlEvent
///////////////////////////////////////////////
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }else if(theEvent.isFrom("rangeController")) {
    viewMin = int(theEvent.getController().getArrayValue(0));
    viewMax = int(theEvent.getController().getArrayValue(1));
    axisXMin = viewMin;
    axisXMax = viewMax - 1;
    oneSecX = (plotX2 - plotX1) / (axisXMax - axisXMin); //使うデータ数に応じた1秒間の座標の長さ(drawでも更新)
    println("Min " + viewMin + ", Max " + viewMax + ", oneSecX " + oneSecX);
  }else if(theEvent.isFrom(radioButton)) {
    int filterTypeId = (int)theEvent.getValue();
    if(filterTypeId == 1){
      filterType = "";
    }else if(filterTypeId == 2){
      filterType = "average";
    }else if(filterTypeId == 3){
      filterType = "median";
    }
  }
}//controlEvent



///////////////////////////////////////////////
// drawTitle
///////////////////////////////////////////////
//タイトルを表示
void drawTitle() {
  fill(0);
  textSize(fontSize*1.3);
  textAlign(LEFT);
  //String title = data.getColumnName(currentColumn);
  String title = csvDataName;
  text(title, plotX1, plotY1 - 10);
}//drawTitle


///////////////////////////////////////////////
// drawAxisLabels
///////////////////////////////////////////////
//それぞれの軸のラベルを表示
void drawAxisLabels() {
  fill(0);
  textSize(13);
  textLeading(15);
  
  //横軸
  textAlign(CENTER, CENTER);
  text(xLabel, displayWidth/2, displayHeight-paddingY/2);
  
  //縦軸
  pushMatrix();//元の座標(原点(0,0))をスタックに入れて保存しておく
  translate(-displayHeight/2+paddingY/2, displayWidth/2-paddingX*1.5);
  rotate(-PI/2);
  textAlign(CENTER, CENTER);
  text(yLabel, paddingX/2, displayHeight/2);
  popMatrix();//保存しておいた座標を取り出して設定を元に戻す
  
}//drawAxisLabels
 
 
 
 
///////////////////////////////////////////////
// drawAxisXLabels
///////////////////////////////////////////////
//横軸の値を表示
void drawAxisXLabels() {
  fill(colorSet.getGray(1));
  textSize(10);
  textAlign(CENTER);
  
  // Use thin, gray lines to draw the grid
  stroke(colorSet.getGray(1));
  strokeWeight(1);
  
  axisXInterval = (axisXMax - axisXMin)/10;
  
  for (int row = viewMin; row < viewMax; row++) {
    if (axisX[row] % axisXInterval == 0) {
      float x = map(axisX[row], axisXMin, axisXMax, plotX1, plotX2);
      //ここで初めてaxisXStr使う. Stringなのでね
      text(axisXStr[row], x, plotY2 + textAscent() + 10);
      stroke(colorSet.getGray(0));
      line(x, plotY1, x, plotY2);
    }
  }
}//drawaxisXLabels


///////////////////////////////////////////////
// drawAxisYLabels
///////////////////////////////////////////////
//縦軸の値を表示
void drawAxisYLabels() {
  textSize(10);
  strokeWeight(1);
  //int vPow = 0; //少数に対応するため条件分岐部分だけ*10^4
  //int powIndex = 4;
  //int axisYIntervalMinorPow = round(axisYIntervalMinor * pow(10,powIndex)) * (int)pow(10, 2);//少数に対応するため条件分岐部分だけ*10^powIndex
  //int axisYIntervalPow = round(axisYInterval*pow(10,powIndex)) * (int)pow(10, 2);//少数に対応するため条件分岐部分だけ*10^powIndex
    
  //for (float v=dataMin; v<=dataMax; v+=axisYIntervalMinor) {
  //  //println("dataMin: " + dataMin + " dataMax: " + dataMax + " v: " + v + " axisYIntervalMinor: " + axisYIntervalMinor);
  //  vPow = round(v*pow(10,powIndex)) * (int)pow(10, 2); //少数に対応するため条件分岐部分だけ*10^4
  //  println("vPow " + vPow + " axisYIntervalMinorpow: " + axisYIntervalMinorPow + " axisYIntervalPow " + axisYIntervalPow);
  //  if (vPow % axisYIntervalMinorPow == 0) {
  //    println(vPow + " axisYIntervalMinorPow==0");
  //    float y = map(v, dataMin, dataMax, plotY2, plotY1);  
  //    if (vPow % axisYIntervalPow == 0) {
  //      println(vPow + " axisYIntervalPow==0");
  //      if (vPow == dataMin*pow(10,powIndex)) {
  //        textAlign(RIGHT);
  //      } else if (vPow == dataMax*pow(10,powIndex)) {
  //        textAlign(RIGHT, TOP);
  //      } else {
  //        textAlign(RIGHT, CENTER);
  //      }
  //      fill(colorSet.getGray(1));
  //      text(floor(v), plotX1 - 10, y);
  //      stroke(colorSet.getGray(1));
  //      line(plotX1 - 4, y, plotX1, y);
  //      println("v: " + v);
        
  //    } else {
  //      //line(plotX1 - 2, y, plotX1, y);
      
  //    }//if(v % volumeInterval == 0)
  //  }//if(v % volumeIntervalMinor == 0)
  //}//for
  
  dataMin = 0; //元データだとdataMin=1で割り切れなくて軸表示されないから
  
  //縦軸の値(消費量)を表示
  println("dataMin: " + dataMin + " dataMax: " + dataMax);
  for (float v=dataMin; v<=dataMax; v+=axisYIntervalMinor) {
    if (v%axisYIntervalMinor == 0) {
      float y = map(v, dataMin, dataMax, plotY2, plotY1);  
      if (v%axisYInterval == 0) {
        if (v == dataMin) {
          textAlign(RIGHT);
        } else if (v == dataMax) {
          textAlign(RIGHT, TOP);
        } else {
          textAlign(RIGHT, CENTER);
        }
        text(floor(v), plotX1 - 10, y);
        line(plotX1 - 4, y, plotX1, y);
      } else {
      //line(plotX1 - 2, y, plotX1, y);
      }//if(v % volumeInterval == 0)
    }//if(v % volumeIntervalMinor == 0)
  }//for
  
}//drawVolumeLabels




///////////////////////////////////////////////
// drawDataPoints
///////////////////////////////////////////////
//点の並びでデータを表示する関数
//引数には表示したいデータの列を入れる
void drawDataPoints(int col) { 
  //行の数(=データの数)を数える
  //int rowCount = data.getRowCount(); 
  //データの数だけくりかえし
  for (int row = viewMin; row < viewMax; row++) { 
    //もし正しい数値だったら(データの範囲が正しければ)
    if (data.isValid(row, col)) { 
      
      filterRange = int(cp5.get(Textfield.class,"filterRange").getText());
      //行と列を指定して、データの数値をとりだす
      float value = data.getFilteredFloat(row, col, filterRange, filterType);
      
      //プロットする画面の幅(x座標)にちょうど納まるように、値を変換
      float x = map(axisX[row], axisXMin, axisXMax, plotX1, plotX2); 
      //プロットする画面の高さ(y座標)にちょうど納まるように、値を変換
      float y = map(value, dataMin, dataMax, plotY2, plotY1); 
      //変換した値を座標にして、点を描画
      //strokeWeight(3);
      point(x, y); 
    }else{
      println("Data is invalid (" + row + "," + col + ")");
    }//if (data.isValid(row, col))
  }//for
}//drawDataPoints



///////////////////////////////////////////////
// drawDataLine
///////////////////////////////////////////////
//線でデータを結ぶ
void drawDataLine(int col) {  
  beginShape();
  for (int row = viewMin; row < viewMax; row++) {
    if (data.isValid(row, col)) {
      
      float value = data.getFilteredFloat(row, col, filterRange, filterType);
      
      float x = map(axisX[row], axisXMin, axisXMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);      
      vertex(x, y);
    }
  }
  endShape();
}//drawDataLine



///////////////////////////////////////////////
// drawGraph
///////////////////////////////////////////////
void drawGraph(int col){
  switch(graphType){
    case 0:
      drawDataLine(col);
      break;
    case 1:
      drawDataPoints(col);
      break;
  }
}//drawGraph


///////////////////////////////////////////////
// drawLegend
///////////////////////////////////////////////
void drawLegend(){
  for(int i=0; i<columnCount; i++){
    fill(0);
    textAlign(LEFT);
    textSize(fontSize);
    text(colNames[i], plotX2+10+15+5, paddingY+20 + i*20);
  }
}//drawLegend




///////////////////////////////////////////////
// KEYPRESSED
///////////////////////////////////////////////
//キー入力で表示する列を切り替える
void keyPressed() {
  if(key == '['){
    currentColumn--;
    if (currentColumn < 0) {
      currentColumn = columnCount - 1;
    }
  }else if(key == ']'){
    currentColumn++;
    if (currentColumn == columnCount) {
      currentColumn = 0;
    }
  }//if key
}//KEYPRESSED





///////////////////////////////////////////////
// MOUSEPRESSED
///////////////////////////////////////////////
void mousePressed(){
  if((plotX1 <= mouseX && mouseX <= plotX2) 
  && (plotY1 <= mouseY && mouseY <= plotY2)){
    lineX = mouseX;
  }
}//MOUSEPRESSED
