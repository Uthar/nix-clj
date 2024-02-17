
import java.io.File;
import java.io.FileReader;
import java.io.Reader;
import java.io.Writer;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.Properties;

class Envsubst {


public static void main (String[] args) {
  String confPath = args[0];
  String inPath = args[1];
  String outPath = args[2];

  Properties props = new Properties();
  try {
    props.load(new FileReader(confPath));
  } catch (Exception e) {
    System.err.println(e.getMessage());
    System.exit(1);
  }

  var dir = new File(outPath).getParentFile();
  if (dir != null) dir.mkdirs();

  try (
    Reader in = new InputStreamReader(new FileInputStream(inPath), "UTF-8");
    Writer out = new OutputStreamWriter(new FileOutputStream(outPath), "UTF-8");
  ){
    int ch = 0;
    var prop = new StringBuilder();
    while ((ch = in.read()) != -1) {
      if (ch != '$') {
        out.write(ch);
        continue;
      }
      if ((ch = in.read()) != '{') {
        out.write('$');
        out.write(ch);
        continue;
      }
      prop.setLength(0);
      // BUG can skip newlines.
      while ((ch = in.read()) != '}' && ch != '\r' && ch != '\n' && ch != -1)
        prop.append((char)ch);
      var subst = props.getProperty(prop.toString());
      if (subst != null) {
        System.err.println(String.format("%s -> %s", prop, subst));
        out.write(subst);
      }
      else {
        System.err.println(String.format("skip %s", prop));
        out.write(prop.toString());
      }
    }
  } catch (Exception e) {
    System.err.println(e.getMessage());
    System.exit(1);
  }
  
}


}
