discard """
  matrix: "--threads:on --gc:orc; --threads:on --gc:arc"
  disabled: "freebsd"
"""

import threading/channels
import std/[os, logging, unittest]
import common


suite "testing ints":
  test "int send recv":
    var chan = newChan[int]()
    let count = 100
    var dest = 0
    for i in 1..count:
      let msg = i
      logger.log(lvlDebug, "[main] Send msg: " & $msg)
      chan.send(msg)
      chan.recv(dest)
    logger.log(lvlDebug, "[main] Received msg: " & $dest)
    doAssert dest == count

  test "int send recvAll":
    var chan = newChan[int]()
    let count = 10
    for i in 1..count:
      let msg = i
      logger.log(lvlDebug, "[main] Send msg: " & $msg)
      chan.send(msg)

    var dest: seq[int]
    chan.recvAll(dest)
    logger.log(lvlDebug, "[main] Received msg: " & $dest)
    doAssert dest.len() == count
    doAssert dest[^1] == count
    doAssert dest.len() == count

  test "int reset":
    var chan = newChan[int]()
    let count = 10
    for i in 1..count:
      let msg = i
      logger.log(lvlDebug, "[main] Send msg: " & $msg)
      chan.send(msg)

    check chan.peek() == count
    chan.clear()
    check chan.peek() == 0

suite "testing seq":
  
  setup:
    discard "run before each test"

  test "basic init tests":
    block:
      let chan0 = newChan[seq[int]]()
      let chan1 = chan0
      block:
        let chan3 = chan0
        let chan4 = chan0

  test "seq[int] send recv":
    var chan = newChan[seq[int]]()
    let count = 100
    var dest: seq[int]
    for i in 1..count:
      let msg = @[i, i, i]
      logger.log(lvlDebug, "[main] Send msg: " & $msg)
      chan.send(msg)

      chan.recv(dest)
      logger.log(lvlDebug, "[main] Received msg: " & $dest)

    doAssert dest.len() == 3
    doAssert dest[0] == count

  test "seq[int] send recvAll":
    var chan = newChan[seq[int]]()
    let count = 10
    for i in 1..count:
      let msg = @[i, i, i]
      logger.log(lvlDebug, "[main] Send msg: " & $msg)
      chan.send(msg)

    var dest: seq[seq[int]]
    chan.recvAll(dest)
    logger.log(lvlDebug, "[main] Received msg: " & $dest)
    doAssert dest.len() == count
    doAssert dest[^1].len() == 3
    doAssert dest[^1][0] == count

  test "seq[int] reset":
    var chan = newChan[seq[int]]()
    let count = 10
    for i in 1..count:
      let msg = @[i, i, i]
      logger.log(lvlDebug, "[main] Send msg: " & $msg)
      chan.send(msg)

    check chan.peek() == count
    chan.clear()
    check chan.peek() == 0

suite "testing ref obj":

  type TestObj = ref object
    field: int
  
  setup:
    discard "run before each test"

  test "ref obj send recv":
    var chan = newChan[TestObj]()
    let count = 100
    var dest: TestObj
    for i in 1..count:
      let msg = TestObj(field: i)
      logger.log(lvlDebug, "[main] Send msg: " & repr msg)
      chan.send(msg)
      chan.recv(dest)
    logger.log(lvlDebug, "[main] Received msg: " & repr dest)
    doAssert dest.field == count

  test "ref obj send recvAll":
    var chan = newChan[TestObj]()
    let count = 10
    for i in 1..count:
      let msg = TestObj(field: i)
      logger.log(lvlDebug, "[main] Send msg: " & repr msg)
      chan.send(msg)

    var dest: seq[TestObj]
    chan.recvAll(dest)
    logger.log(lvlDebug, "[main] Received msg: " & repr dest)
    doAssert dest.len() == count
    doAssert dest[^1].field == count
    doAssert dest.len() == count

  test "ref obj reset":
    var chan = newChan[TestObj]()
    let count = 10
    for i in 1..count:
      let msg = TestObj(field: i)
      logger.log(lvlDebug, "[main] Send msg: " & repr msg)
      chan.send(msg)

    check chan.peek() == count
    chan.clear()
    check chan.peek() == 0
