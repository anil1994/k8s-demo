package com.mycompany.app;

/**
 * Hello world!
 */
public class App
{

    private final String message = "Hello World!";

    public App() {}

    public static void main(String[] args) {
        System.out.println(new App().getMessage());
      try
     {
           Thread.sleep(70000);
      }
      catch(Exception e)
      {
          System.out.println(e);
       }
      System.out.println("running properly.....");

    }

    private final String getMessage() {
        return message;
    }

}
