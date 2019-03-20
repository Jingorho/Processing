// first line of the file should be the column headers
// first column should be the row titles
// all other values are expected to be floats
// getFloat(0, 0) returns the first data value in the upper lefthand corner
// files should be saved as "text, tab-delimited"
// empty rows are ignored
// extra whitespace is ignored



///////////////////////////////////////////////
// FloatCsv CLASS
///////////////////////////////////////////////
class FloatCsv {
  int rowCount;
  int columnCount;
  float[][] data;
  String[] rowNames;
  String[] columnNames;
  String indexName;
  int[] indexRow;
  String[][] indexRows;
  String fname;
  
  
  ///////////////////////////////////////////////
  // FloatCsv コンストラクタ
  ///////////////////////////////////////////////
  FloatCsv(String filename) {
    fname = filename;
    String[] rows = loadStrings(filename);
    
    //String[] columns = split(rows[0], TAB);
    String[] columns = split(rows[0], ",");
    indexName = columns[0]; //下の行でsubsetされる0行目(colNames)の0列目は, indexになる
    columnNames = subset(columns, 1); // upper-left corner ignored
    scrubQuotes(columnNames);
    columnCount = columnNames.length;
    
    rowNames = new String[rows.length-1];
    data = new float[rows.length-1][];
    
    // start reading at row 1, because the first row was only the column headers
    for (int i = 1; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }

      // split the row on the tabs
      String[] pieces = split(rows[i], ",");
      if(i%100 == 0){
        //println("------\n");
        //for(int g=0; g<pieces.length; g++){
        //  println("pieces " + pieces[g]);
        //}
      }
      //String[] pieces = split(rows[i], TAB);
      scrubQuotes(pieces);
      if(i%100 == 0){
        //println("------\n");
        //for(int g=0; g<pieces.length; g++){
        //  println("pieces " + pieces[g]);
        //}
      }
      
      // copy row title
      rowNames[rowCount] = pieces[0];
      // copy data into the table starting at pieces[1]
      data[rowCount] = parseFloat(subset(pieces, 1));
      if(i%100 == 0){
        //println("------\n");
        //println(data[rowCount]);
        //for(int g=0; g<pieces.length; g++){
        //  println("pieces " + pieces[g]);
        //}
      }
      
      // increment the number of valid rows found so far
      rowCount++;      
    }
    // resize the 'data' array as necessary
    data = (float[][]) subset(data, 0, rowCount);
    println(data[0].length);
    for(int g=0; g<data[0].length; g++){
      println(g +  " " + data[0][g]);
    }
    indexRows = new String[rowNames.length][2];
    
  }//FloatCsvコンストラクタ
  
  
  
  ///////////////////////////////////////////////
  // scrubQuotes
  ///////////////////////////////////////////////
  void scrubQuotes(String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].length() > 2) {
        // remove quotes at start and end, if present
        if (array[i].startsWith("\"") && array[i].endsWith("\"")) {
          array[i] = array[i].substring(1, array[i].length() - 1);
        }
      }
      // make double quotes into single quotes
      array[i] = array[i].replaceAll("\"\"", "\"");
    }
  }//scrubQuotes
  
  
  
  ///////////////////////////////////////////////
  // getIndexName
  ///////////////////////////////////////////////
  String getIndexName() {
    return indexName;
  }
  
  
  
  
  ///////////////////////////////////////////////
  // getRowCount
  ///////////////////////////////////////////////
  int getRowCount() {
    return rowCount;
  }
  
  
  ///////////////////////////////////////////////
  // getRowName
  ///////////////////////////////////////////////
  String getRowName(int rowIndex) {
    return rowNames[rowIndex];
  }
  
  
  ///////////////////////////////////////////////
  // getRowNames
  ///////////////////////////////////////////////
  String[] getRowNames() {
    return rowNames;
  }
  
  
  ///////////////////////////////////////////////
  // getIndexRowString
  ///////////////////////////////////////////////
  // デフォルトではindexにするrowもStringで扱うみたいなので,
  // indexRowの種類(時刻, ...)に合わせて(予定)プロットできる
  // int(のStr)をくっつけた2次元配列を返す関数
  String[] getIndexRowString(){
    String[] indexRowString = new String[rowNames.length];
    
    for(int i=0; i<indexRowString.length; i++){
      indexRowString[i] = rowNames[i];
    }
    
    return indexRowString;
  }//getIndexRow
  
  
  
  ///////////////////////////////////////////////
  // getIndexRowInt
  ///////////////////////////////////////////////
  int[] getIndexRowInt(){
    int[] indexRowInt = new int[rowNames.length];
    for(int i=0; i<rowNames.length; i++){
      indexRowInt[i] = i;
    }
    return indexRowInt;
  }//getIndexRowInt
  
  
  
  
  
  ///////////////////////////////////////////////
  // getIndexRows
  ///////////////////////////////////////////////
  // デフォルトではindexにするrowもStringで扱うみたいなので,
  // indexRowの種類(時刻, ...)に合わせて(予定)プロットできる
  // int(のStr)をくっつけた2次元配列を返す関数
  String[][] getIndexRows(){
    for(int i=0; i<rowNames.length; i++){
      indexRows[i][0] = rowNames[i];
      indexRows[i][1] = str(i);
    }
    
    return indexRows;
  }//getIndexRow
  
  
  
  
  ///////////////////////////////////////////////
  // getIndexStringFromInt
  ///////////////////////////////////////////////
  String getIndexStringFromInt(int indexRowInt){
    String _indexRows[][] = getIndexRows();
    return _indexRows[indexRowInt][0];
  }//getIndexRow
  
  
  
  
  
  
  ///////////////////////////////////////////////
  // getRowIndex <rowをStringとして扱う時しか使わないかも>
  ///////////////////////////////////////////////
  // Find a row by its name, returns -1 if no row found. 
  // This will return the indexName of the first row with this name.
  // A more efficient version of this function would put row names
  // into a Hashtable (or HashMap) that would map to an integer for the row.
  int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (rowNames[i].equals(name)) {
        return i;
      }
    }
    //println("No row named '" + name + "' was found");
    return -1;
  }
  
  
  
  
  ///////////////////////////////////////////////
  // getColumnCount
  ///////////////////////////////////////////////
  // technically, this only returns the number of columns 
  // in the very first row (which will be most accurate)
  int getColumnCount() {
    return columnCount;
  }
  
  
  ///////////////////////////////////////////////
  // getColumnName
  ///////////////////////////////////////////////  
  String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }
  
  
  ///////////////////////////////////////////////
  // getColumnNames
  ///////////////////////////////////////////////
  String[] getColumnNames() {
    return columnNames;
  }


  ///////////////////////////////////////////////
  // getFloat
  ///////////////////////////////////////////////
  float getFloat(int rowIndex, int col) {
    // Remove the 'training wheels' section for greater efficiency
    // It's included here to provide more useful error messages
    
    // begin training wheels
    if ((rowIndex < 0) || (rowIndex >= data.length)) {
      throw new RuntimeException("There is no row " + rowIndex);
    }
    if ((col < 0) || (col >= data[rowIndex].length)) {
      throw new RuntimeException("Row " + rowIndex + " does not have a column " + col);
    }
    // end training wheels
    
    return data[rowIndex][col];
  }//getFloat
  
  
  
  ///////////////////////////////////////////////
  // getFilterdFloat
  ///////////////////////////////////////////////
  float getFilteredFloat(int rowIndex, int col, int filterRange, String filterType) {
    // Remove the 'training wheels' section for greater efficiency
    // It's included here to provide more useful error messages
    
    // begin training wheels
    if ((rowIndex < 0) || (rowIndex >= data.length)) {
      throw new RuntimeException("There is no row " + rowIndex);
    }
    if ((col < 0) || (col >= data[rowIndex].length)) {
      throw new RuntimeException("Row " + rowIndex + " does not have a column " + col);
    }
    // end training wheels
    
    
    //フィルタ処理
    float[] tempDt = new float[filterRange];
    //float[][] filteredData = data;
    float filteredData = 0;
    
    if((filterRange/2 >= rowIndex) || (filterRange/2 >= (rowCount - rowIndex))){
      //filterRange/2の範囲に収まってないときそのままrawデータ
      //filteredData[rowIndex][col] = data[rowIndex][col];
      filteredData = data[rowIndex][col];
      
    }else if((filterRange/2 <= rowIndex) && (filterRange/2 <= (rowCount-rowIndex))){
      //処理する分を格納
      for(int k=0; k<filterRange-1; k++){
        tempDt[k] = data[(rowIndex - filterRange/2) + k][col];
      }//for k
      
      //フィルタ種類によって処理
      if(filterType.equals("average")){
        int tempDtSum = 0;
        for(int n=0; n<filterRange-1; n++){ tempDtSum += tempDt[n]; }
        //filteredData[rowIndex][col] = tempDtSum / filterRange; //平均値を代入
        filteredData = tempDtSum / filterRange; //平均値を代入
        
      }else if(filterType.equals("median")){
        tempDt = sort(tempDt); //昇順に並べ替え
        //filteredData[rowIndex][col] = tempDt[2]; //中央の値[2]を代入
        filteredData = tempDt[2]; //中央の値[2]を代入
        
      }else if(filterType.equals("")){
        //filteredData[rowIndex][col] = data[rowIndex][col]; //フィルタがないときはrawそのまま
        filteredData = data[rowIndex][col]; //フィルタがないときはrawそのまま
        
      }
    }//if filterRange/2の範囲に収まってたら
    
    //return filteredData[rowIndex][col];
    return filteredData;
  }//getFilterdFloat
  
  
  
  ///////////////////////////////////////////////
  // isValid
  ///////////////////////////////////////////////
  boolean isValid(int row, int col) {
    if (row < 0) return false;
    if (row >= rowCount) return false;
    //if (col >= columnCount) return false;
    if (col >= data[row].length) return false;
    if (col < 0) return false;
    return !Float.isNaN(data[row][col]);
  }



  ///////////////////////////////////////////////
  // getColumnMin
  ///////////////////////////////////////////////
  float getColumnMin(int col) {
    float m = Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      if (isValid(row, col)) {
        if (data[row][col] < m) {
          m = data[row][col];
        }
      }//if(isValid)
    }//for
    return m;
  }//getColumnMin



  ///////////////////////////////////////////////
  // getColumnMax
  ///////////////////////////////////////////////
  float getColumnMax(int col) {
    float m = -Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      if (isValid(row, col)) {
        if (data[row][col] > m) {
          m = data[row][col];
        }
      }//if(isValid)
    }//for
    return m;
  }//getColumnMax



  ///////////////////////////////////////////////
  // getRowMin
  ///////////////////////////////////////////////
  float getRowMin(int row) {
    float m = Float.MAX_VALUE;
    for (int col = 0; col < columnCount; col++) {
      if (isValid(row, col)) {
        if (data[row][col] < m) {
          m = data[row][col];
        }
      }//if(isValid)
    }//for
    return m;
  }//getRowMin



  ///////////////////////////////////////////////
  // getRowMax
  ///////////////////////////////////////////////
  float getRowMax(int row) {
    float m = -Float.MAX_VALUE;
    for (int col = 0; col < columnCount; col++) {
      if (isValid(row, col)) {
        if (data[row][col] > m) {
          m = data[row][col];
        }
      }//if(isValid)
    }//for
    return m;
  }//getRowMax



  ///////////////////////////////////////////////
  // getCsvMin
  ///////////////////////////////////////////////
  float getCsvMin() {
    float m = Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < columnCount; col++) {
        if (isValid(row, col)) {
          if (data[row][col] < m) {
            m = data[row][col];
          }
        }//if(isValid)
      }//for
    }//for
    return m;
  }//getCsvMin



  ///////////////////////////////////////////////
  // getCsvMax
  ///////////////////////////////////////////////
  float getCsvMax() {
    float m = -Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < columnCount; col++) {
        if (isValid(row, col)) {
          if (data[row][col] > m) {
            m = data[row][col];
          }
        }//if(isValid)
      }//for
    }//for
    return m;
  }//getCsv
  
  
  
  
  ///////////////////////////////////////////////
  // printCsvStatus
  ///////////////////////////////////////////////
  void printCsvStatus(){
    println("The first lines of \'" + fname + "\' ...");
    
    //最初の3行だけ表示
    for(int i=0; i<4; i++){
      if(i == 0){
        print("<" + indexName + "> ");
      }else{
        print(rowNames[i] + " ");
      }
      
      for(int j=0; j<columnNames.length-1; j++){
        if(i == 0){
          print(columnNames[j] + " ");
        }else{
          print(data[i][j] + " ");
        }
      }//for 列
      println("");
    }//for 行
    
    println("[ " + rowNames.length + " x " + columnNames.length + " ]\n");
    println("indexName: " + indexName);
    
  }//printCsvStatus
  
  
  ///////////////////////////////////////////////
  // SignalProcessing
  ///////////////////////////////////////////////
  float[][] signalProcessingFilter(int filterRange, String filterType){
    float[] tempDt = {0.0, 0.0, 0.0, 0.0, 0.0};
    float[][] filteredData = data;
    
    for(int i=0; i<columnCount; i++){
      for(int j=0; j<rowCount; j++){
        for(int k=0; k<filterRange; k++){
          tempDt[k] = data[j+k][i];
        }//for k
        
        if(filterType.equals("average")){
          int tempDtSum = 0;
          for(int n=0; n<5; n++){ tempDtSum += tempDt[n]; }
          filteredData[j][i] = tempDtSum / 5; //平均値を代入
          
        }else if(filterType.equals("median")){
          tempDt = sort(tempDt); //昇順に並べ替え
          filteredData[j][i] = tempDt[2]; //中央の値[2]を代入
        }
        
      }//for j
    }//for i
    
    return filteredData;
  }


}//FloatCsv CLASS