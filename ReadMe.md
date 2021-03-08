# Spring Boot Reactive Web App Graal VM Demo

### What is GraalVM
GraalVM is a Java VM and JDK.

### Why / When to use GraalVM
In exchange for giving up dynamism, you gain startup performance and low memory usage.

**Use Cases**:
- serverless (you want things light weight and fast to warm up)
- Running applications with less RAM
- Running multiple java microservices on the same VM
- Running containerized apps (remove need of including a JVM per container)

### Major differentiators of GraalVM compared to the base JDK:
GraalVM is built on top of OpenJDK, and ships with all the components of it, but with the following differences:

- **GraalVM Compiler**: 
  - A JIT compiler for Java equivalent of C1/C2 of OpenJDK. 
    Compared to regular compilers, it is written in Java itself.  
- **GraalVM Native Image**: 
  - An ahead-of-time "closed world" compilation technology that produces executable binaries of class files.
  - Closed world means no dynamic loading of libraries, no dynamic proxies, no reflection etc.
  - It allows ahead-of-time compilation of Java (and other) applications similar to Rust and Go native applications. 
  - The executable file does not run on a JVM, and uses necessary runtime components as thread scheduling or GC from “Substrate VM”, which is a trivial version of a JVM.
- Some other stuff:
  - Truffle Language Implementation framework and the GraalVM SDK, to implement additional programming language runtimes
  - LLVM Runtime and JavaScript Runtime

### What does GraalVM do?
Graal compiler tries to know everything about your application ahead-of-time, and statically links all the parts.

In a traditional fat jar created using Maven/Gradle, your jar file is an archive that contains all the libraries that your Spring/Java application will use. 
So this is the same as running a Java application with a class path containing external library paths, but with the libraries present within the same location.

Graal, will instead 
- Remove the dynamically loading parts of your application, and make them statically linked.
- Combine only the parts of the libraries that are actually used, into a single place, and remove everything else. 
- Use a minimal variant of the JVM called the **Substrate VM** that is also merged into the application.

By doing this
- It removes dependence on external libraries, dynamic loading, or reliance on JVM.
- Having everything in one places makes it easy to convert the application to native/machine code. 
- A native application with no external dependence results in faster startup times and lower memory usage. 

### Difference between jar file running on JVM vs native application running on GraalVM:
- A static analysis of your application from the main entry point is performed at build time.
- The unused parts are removed at build time.
- Configuration is required for reflection, resources, and dynamic proxies.
- Classpath is fixed at build time.
- No class lazy loading: everything shipped in the executables will be loaded in memory on startup.
- Some code will run at build time.
- There are some [limitations](https://github.com/oracle/graal/blob/master/substratevm/Limitations.md) around some aspects of Java applications that are not fully supported.

### Some more Graal Stuff:

**feature** : You may need to teach Graal about the behaviour of the application, like what things are going to cause reflections, what will get dynamically instantiated etc.
To do this, you are either adding command line switches to the compiler, or dynamically providing this information to the native-image builder using a feature.

It has other things like polyglot language runtimes (for e.g. write Python, JS, R programs on the same application which can talk to each other on the same vm)

### Spring Native
Spring Native is a spring Graal feature. Spring Native provides support for compiling Spring applications to native executables using the GraalVM native-image compiler.
There are two main ways to build a Spring Boot native application:
- Using **Spring Boot Buildpacks** support to generate a lightweight container containing a native executable.
- Using the **GraalVM native image Maven plugin** support to generate a native executable.

This demo uses the latter.

---

### Project

This is a spring reactive demo application that is built into a native application using GraalVM. This project builds into a traditional fat jar as well as a native application.

Note: This project does not use JPA because building a native app containing JPA takes a long time for GraalVM.

**Setup:**
- Install [SDKMAN](https://sdkman.io/install)
- Use sdkman to install graalvm java `sdk install java 20.3.1.2.r11-grl`
- Use graalvm jdk as the jdk for this project `sdk use java 20.3.1.2.r11-grl` This will use sdkman to set graalvm jdk on the current terminal session.
- Install GraalVM Native Image: `gu install native-image`

**Project Dependencies and configurations:**
- See `pom.xml` for the dependencies and configurations used.
- See also main application where cglib proxies are disabled `@SpringBootApplication(proxyBeanMethods = false)`

**Build Steps:**
- using hand coding: execute build script `bash scripts/compile.sh`
- using spring native: `./mvnw -Pnative-image clean package`
- using docker: `docker build . --tag=graalvmdemo`

**Execution Steps:**
- execute native application built from build script: `./target/native-image/graalVM`
- execute native application built with spring-native: `./target/graalVM`
- execute native application on docker container: `docker run -e "PORT=8080" -p 8080:8080 graalvmdemo`

**Performance Comparison:**

(Intel® Core™ i7-10510U CPU @ 1.80GHz × 8 cores with 16GB Ram running Ubuntu 20.04 with heavy background activity)

|               | Jar                            | Native App                                    |
|---------------|--------------------------------|-----------------------------------------------|
| execution:    | jar file running on system JVM | Native application with embedded Substrate VM |
| mem usage:    | 495MB                          | 31MB                                          |
| startup time: | 2.9s                           | 0.045s                                        |
| file size:    | 20MB                           | 57MB                                          |
| build time:   | 8s                             | 8m 09s                                        |


### References
- [Introduction to GraalVM](https://www.graalvm.org/docs/introduction/)
- [Spring Native](https://docs.spring.io/spring-native/docs/current/reference/htmlsingle/#_overview)
- [Project Reference](https://blog.codecentric.de/en/2020/05/spring-boot-graalvm/)
