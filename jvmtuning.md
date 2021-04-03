# Java mission control
jmc - java mission control gui


jcmd - command line version of jmc
jcmd <pid> help
jcmd <pid> VM.flags

# Changing a flag at runtime - only do if the flag is marked manageable.
jcmd <pid> VM.set_flag CMSWaitDuration 1500

# Thread - Runnable, Blocked (lock), Waiting/Timed_Waiting
jcmd <pid> Thread.print | less

# Memory
jcmd <pid> GC.heap_info

jcmd <pid> GC.class_histogram | less

jcmd <pid> GC.heap_dump 

