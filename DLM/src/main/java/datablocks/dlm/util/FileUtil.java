package datablocks.dlm.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.nio.charset.Charset;

public class FileUtil {
	
	public static File[] getFilelist(String path) {
		//File dir = new File("/home/mjs/test/test");
		File dir = new File(path);
		File files[] = dir.listFiles();

//		for (int i = 0; i < files.length; i++) {
//		    System.out.println("file: " + files[i]);
//		}
		
		return files;
	}
	public void readFile(String path) {//"d:\\file.txt"
		
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(path));
			String str;
			while ((str = reader.readLine()) != null) {
				System.out.println(str);
			}
			reader.close();
		} catch (Exception e) {
			System.out.println(path+" "+e.getMessage());
		}

	}
}
