import java.io.*;

import java.awt.*;
import javax.swing.*;

import org.rosuda.JRI.Rengine;
import org.rosuda.JRI.REXP;
import org.rosuda.JRI.RMainLoopCallbacks;
import org.rosuda.JRI.RConsoleOutputStream;

class TextConsole2 implements RMainLoopCallbacks
{
    JFrame f;
	
    public JTextArea textarea = new JTextArea();

    public TextConsole2() {
        f = new JFrame();
        f.getContentPane().add(new JScrollPane(textarea));
        f.setSize(new Dimension(800,600));
        f.show();
    }

    public void rWriteConsole(Rengine re, String text, int oType) {
        textarea.append(text);
    }
    
    public void rBusy(Rengine re, int which) {
        System.out.println("rBusy("+which+")");
    }
    
    public String rReadConsole(Rengine re, String prompt, int addToHistory) {
        System.out.print(prompt);
        try {
            BufferedReader br=new BufferedReader(new InputStreamReader(System.in));
            String s=br.readLine();
            return (s==null||s.length()==0)?s:s+"\n";
        } catch (Exception e) {
            System.out.println("jriReadConsole exception: "+e.getMessage());
        }
        return null;
    }
    
    public void rShowMessage(Rengine re, String message) {
        System.out.println("rShowMessage \""+message+"\"");
    }
    
    public String rChooseFile(Rengine re, int newFile) {
	FileDialog fd = new FileDialog(f, (newFile==0)?"Select a file":"Select a new file", (newFile==0)?FileDialog.LOAD:FileDialog.SAVE);
	fd.show();
	String res=null;
	if (fd.getDirectory()!=null) res=fd.getDirectory();
	if (fd.getFile()!=null) res=(res==null)?fd.getFile():(res+fd.getFile());
	return res;
    }
    
    public void   rFlushConsole (Rengine re) {
	}
    
    public void   rLoadHistory  (Rengine re, String filename) {
    }			
    
    public void   rSaveHistory  (Rengine re, String filename) {
    }			
}

public class rtest2 {
    public static void main(String[] args) {
        System.out.println("Press <Enter> to continue (time to attach the debugger if necessary)");
        try { System.in.read(); } catch(Exception e) {};
        System.out.println("Creating Rengine (with arguments)");
		Rengine re=new Rengine(args, true, new TextConsole2());
        System.out.println("Rengine created, waiting for R");
        if (!re.waitForR()) {
            System.out.println("Cannot load R");
            return;
        }
		System.out.println("re-routing stdout/err into R console");
		System.setOut(new PrintStream(new RConsoleOutputStream(re, 0)));
		System.setErr(new PrintStream(new RConsoleOutputStream(re, 1)));
		
		System.out.println("Letting go; use main loop from now on");
    }
}
