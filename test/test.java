package test;

class test {

static {
  System.loadLibrary("brotli_jni");
}

public static void main(String[] args) {
  try {
    
  var in = new java.io.ByteArrayInputStream(new byte[] { 1, 2, 3, 4, 5, 6, 7, 8 , 9, 10});

  var zin = new org.brotli.wrapper.dec.BrotliInputStream(in);

  System.err.println(String.format("%s, %s", in, zin));

  } catch (Exception e) { e.printStackTrace(); }
}

}
