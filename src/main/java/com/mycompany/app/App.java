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
        TimeUnit.MINUTES.sleep(100);
    }

    private final String getMessage() {
        return message;
    }

}
