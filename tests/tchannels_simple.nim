discard """
  matrix: "--threads:on --gc:orc; --threads:on --gc:arc"
  disabled: "freebsd"
"""

import threading/channels
import std/[os, logging, unittest]
import common


suite "testing Chan with overwrite mode":
  
  setup:
    discard "run before each test"

  test "basic init tests":
    block:
      let chan0 = newChan[int]()
      let chan1 = chan0
      block:
        let chan3 = chan0
        let chan4 = chan0

  test "simple send recv":
    var chan = newChan[string]()
    runBasicSendRecv(chan)

  test "simple send recvAll":
    var chan = newChan[string]()
    runBasicSendRecvAll(chan, 10)

  test "simple reset":
    var chan = newChan[string]()
    runBasicReset(chan, 10)

  test "basic multithread":
    var chan = newChan[string]()
    runMultithreadInOrderTest(chan)

  test "basic non-blocking multithread":
    var chan = newChan[string]()
    runMultithreadNonRecvBlockTest(chan)

  test "basic blocking multithread":
    var chan = newChan[string](overwrite=true)
    runMultithreadRecvBlockTest(chan)
