# Java mission control
jmc - java mission control gui


jcmd - command line version of jmc
jcmd <pid> help
jcmd <pid> VM.flags

#### Changing a flag at runtime - only do if the flag is marked manageable.
jcmd <pid> VM.set_flag CMSWaitDuration 1500

#### Thread - Runnable, Blocked (lock), Waiting/Timed_Waiting
jcmd <pid> Thread.print | less

#### Memory
jcmd <pid> GC.heap_info

jcmd <pid> GC.class_histogram | less

jcmd <pid> GC.heap_dump 

#### Java flight recorder
jmcd <pid> JFR.start setting=default name=Recording maxage=4h

Jump recording based on a trigger - cpu usage, deadlock etc
In JMC, MBean server > Triggers > set trigger

#### JMC creates an automatic analysis report from JFR recording
1. hot classes/ methods
2. Memory tab - shows which objects are most created. Shows allocation rates by time sample. Shows GC pause time.
3. GC tab - New GC, Old GC times.
4. Threads - 
5. Lock instances - blocked threads, how log, how much time etc

