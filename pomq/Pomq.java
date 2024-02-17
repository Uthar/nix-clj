
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;

class Pomq {

public static void main (String[] args) {
  try {
  String pom = args[0];
  DocumentBuilderFactory factory = DocumentBuilderFactory.newDefaultInstance();
  DocumentBuilder db = factory.newDocumentBuilder();
  Document doc = db.parse(new java.io.File(pom));
  String version = null;
  Node parent = doc.getElementsByTagName("project").item(0);
  Node n;
  if (parent != null) {
    NodeList sub = parent.getChildNodes();
    for (int i = 0; (n = sub.item(i)) != null; i++) {
      if ("groupId".equals(n.getNodeName())) {
        version = n.getTextContent();
        break;
      }
    }
  }
  if (version == null) {
    Node project = doc.getElementsByTagName("parent").item(0);
    if (project != null) {
      NodeList sub = project.getChildNodes();
      for (int i = 0; (n = sub.item(i)) != null; i++) {
        if ("groupId".equals(n.getNodeName())) {
          version = n.getTextContent();
          break;
        }
      }
    }
  }
  System.out.print(version);
  } catch (Exception e) { System.err.println(e.getMessage()); }
}

}