package com.anshuman.spring.graalvm;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(proxyBeanMethods = false) // disable use of CGLIB proxies so that we can run the application with GraalVM
// As opposed to the GCLIB proxies , the usage of JDK proxies is supported by GraalVM. They just need to be registered at build time.
public class App {

	public static void main(String[] args) {
		SpringApplication.run(App.class, args);
	}

}
