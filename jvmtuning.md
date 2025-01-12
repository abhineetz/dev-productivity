## Java Performance analysis, tuning and optimization

### Command line tools and JMC gui 
jmc - java mission control gui

jcmd - command line version of jmc
jcmd <pid> help
jcmd <pid> VM.flags

#### Changing a flag at runtime - only do if the flag is marked manageable.
1. jcmd <pid> VM.set_flag CMSWaitDuration 1500

#### Thread states - Runnable, Blocked (lock), Waiting/Timed_Waiting
1. jcmd <pid> Thread.print | less

#### Memory
1. jcmd <pid> GC.heap_info
2. jcmd <pid> GC.class_histogram | less
3. jcmd <pid> GC.heap_dump 

#### Java flight recorder
1. jmcd <pid> JFR.start setting=default name=Recording maxage=4h

2. Start JFR recording based on a trigger like cpu usage, deadlock etc.
This can be achieved in JMC GUI -> MBean server -> Triggers -> set trigger

#### JMC GUI creates an automatic analysis report from JFR recording
1. Hot classes/ methods:- As the name suggests these are invoked very often.
2. Memory tab:- Shows object instances by decending order. Shows object allocation rates by time sample. Shows GC pause time.
3. GC tab:- New GC, Old GC times.
4. Threads:- Shows all application threads and their states.
5. Lock instances:- Shows blocked threads and for how long.

>#### Compilers and interpreters
>1. Compiled languages:- Transforms program code to machine instructions for specific CPU architecture and are optimized for that CPU.
>2. Interpreted languages:- Translates each line of code into machine instructions as the line is executed. Interpreted languages are portable across CPU architectures. But are not as fast as compiled languages.
>3. Intermediate languages:- Translates program code to intermediate bytecode, then a VM/JVM can interpret that bytecode. Benefits are that compiler can perform type checks and optimizations. Portability is also achieved. Performance of interpreted bytecode lags behind compiled code.
>To overcome this JIT compiler was introduced in 1999. JIT compiler identifies the hotspots in an application during runtime and compiles bytecode to machine instructions so that the hot methods/classes are available in machine instructions and execute pretty fast. 
>
>>JIT - has 2 compilation modes:-
>>1. C1 - client compiler:- Optimized for fast start up applications and optimizes the hotspot methods early on and compiles them to machine code.
>>2. C2 - server compiler:- Waits longer period of time for hotspot method optimizations. The longer wait means more accurate patterns can be applied to identify hot methods and optimizations can be more aggressive. Hence, methods compiled with C2 are faster than those compiled with C1.
>>
>>Application running with C1 will be faster early on. While C2 compiled applications will catch up later and overtake C1. Hence, C1 should be used for short lived applications and C2 for long lived apps.
>>
>>3. Tiered Compilation:- For long lived apps, tiered compilation approach could be used. The application first starts up and executes the bytecode in interpreted mode. After a few runs C1 compiler identifies and compiles hot methods. As the methods become more hotter, they can then be compied with C2 compiler. Java 8 by default uses tiered compilation.
>>>
>>>Tiered compiliation levels are:-
>>>1. Level 0 – interpreted code.
>>>2. Level 1 – C1 compiled code with no profiling
>>>3. Level 2 – C1 compiled code with light profiling
>>>4. Level 3 – C1 compiled code with full profiling
>>>5. Level 4 – C2 compiled code (uses profile data from the previous steps)

#### Hotspot method are identified using the algorithm based on below two parameters:-
1. Invocation counter:- number of times method has been invoked.
2. Backedge counter:- number of times any loops in a method have branched back. Branch back means either a loop completed execution or it was cut short using a continue statement.

#### JVM JIT compiler tuning flags
1. C1 compiler:- -XX:TieredStopAtLevel=1
2. C2 compiler:- -XX:-TieredCompilation
3. Tier 4 tuning flags:- -XX:Tier4InvocationThreshold=4000 -XX:Tier4CompilationThreshold=10000

>Code cache - An area of native memory where compiled code is stored for future executions. If the code cache is filled up no more JIT compilation is done and the hot methods would run in slower interpreted mode.
> In java 9, code cache is divided into three areas:
>1. JVM internal code
>2. Profiled (lightly optimized) code
>3. Non-profiled (fully optimized) code

#### JVM Code cache tuning flag:- 
-XX:ReservedCodeCacheSize=<N>

#### Garbage Collection
>Generational GC:- Based on young and old generation.
>1. Serial:- -XX:+UseSerialGC
>2. Parallel:- 
>3. CMS:-
>4. Garbage First (G1GC):-
>> Young generation is divided into Eden & Survivor space (S0, S1). Objects are created in Eden space, when eden fills up minor GC takes place and surviving objects are aged incremented and moved to the empty survivor space say S1. The other survior space S0 objects are also age incremented; if they cross threshold they are moved to Old generation; remaining objects from S0 are copied to S1. Now S0 and eden space memory is cleared. This process continues with each minor GC and objects are moved between survivor spaces and tenured objects are moved to old generation. Eventually the old generation will become full and need GC, called major or full GC. It takes more time as the old generation space is large and holds large number of objects.

Throughput definition w.r.t. GC:- The percentage of time spent in doing application work vs GC.

####Basic Collectors:- Parallel collector
* Stop all application threads
* Mark unreachable objects
* Free the memory
* Compact the heap
* Resume application threads.

####Advanced/Concurrent collectors/low pause collectors - CMS, G1GC
* Scan unreachable objects while the application is still running
* Only pause app threads to free the memory and compact the heap

####Choosing a GC
* Serial GC:- -XX:+UseSerialGC
1. Single CPU available
2. Multiple small jvms, more than the number of CPU's available
3. Small live data set up to 100MB

* Parallel GC:- -XX:+UseParallelGC
1. Uses multiple threads to process the heap
2. Fully stops all application threads which can result in **long pause times but provides higher throughput**.
3. Suitable for batch type applications where throughput is more important than low pause time.

* CMS collector:- Deprecated and replaced by G1GC
1. Traces reachable and unreachable objects while application threads are running.
2. Since GC threads are running concurrently with application threads, **they compete for CPU and could affect the throughput.**

* G1GC - CMS replacement, default for > java 9 -XX:+UseG1GC
1. Designed for multiprocessor machines with large heaps. Tries to achieve the best balance between throughput and latency.
2. Similar to CMS, it could affect throughput.
3. Suitable for interactive applications with low pause time requirement.

* Shenandoah collector-
1. Can mark unreachable objects and move unreachable objects concurrently while application threads are running.
2. Can produce 10x reduction in pause times with only 10% throughput decrease.

####GC logging flags:
1. -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:<file path>
2. -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=10M

####GC tuning
1. Adaptive sizing:- (-Xms and -Xmx flags) - When these flags are used JVM adapts the heap size based on size of live objects in the heap. So, the size will grow and shrink as the live objects increase and decrease.
2. Turn of adaptive sizing:- -XX:-UseAdaptiveSizePolicy and seting the min and max heap size same.
General recommendation : Heap should be 30% occupied after a full GC.
3. MaxGCPause:- -XX:MaxGCPauseMillis=350
G1GC has default value of 200ms for this flag.
4. Concurrent GC errors, when GC threads and application threads are running concurrently and application is producing objects at a rate faster than what GC could collect.
	1. Concurrent mode failure:-
	2. Promotion failure:-
	3. Evacuation failure:-

Solution is to reduce the threshold at which G1 cycle is triggered. 
-XX:InitiatingHeapOccupancyPercent=45 (Default)

Or Increase number of concurrent threads
-XX:ConcGCThreads=4

Or Increase Heap size.

