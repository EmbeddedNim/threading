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

  test "basic multithread":
    var chan = newChan[string]()
    runMultithreadInOrderTest(chan)

  test "basic blocking multithread":
    var chan = newChan[string]()
    runMultithreadBockTest(chan)
