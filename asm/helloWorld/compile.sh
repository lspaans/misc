#!/bin/sh

# De '.s'-extensie is kennelijk nog om 'm gecompiled te krijgen. '.asm' werkt bijvoorbeeld NIET!

gcc -arch x86_64 -o helloWorld ./helloWorld.s
