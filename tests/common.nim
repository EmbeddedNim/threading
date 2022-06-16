import std/[os, logging, unittest, strutils, strformat]
export os, logging, unittest, strutils, strformat

import threading/channels

const
  testLogLevel {.strdefine.}: string = "lvlInfo"
  logLevel*: Level = parseEnum[Level](testLogLevel)

var logger* = newConsoleLogger(logLevel, verboseFmtStr)

template runBasicSendRecv*[T](chan: Chan[T], count: int = 100) =

  var dest = ""
  for i in 1..count:
    let msg = "Hello World! " & $i
    logger.log(lvlDebug, "[main] Send msg: " & $msg)
    chan.send(msg)

    chan.recv(dest)
    logger.log(lvlDebug, "[main] Received msg: " & $dest)
  
  doAssert dest == "Hello World! " & $count

template runBasicSendRecvAll*[T](chan: Chan[T], count: int) =

  for i in 1..count:
    let msg = "Hello World! " & $i
    logger.log(lvlDebug, "[main] Send msg: " & $msg)
    chan.send(msg)

  var dest: seq[string]
  chan.recvAll(dest)
  logger.log(lvlDebug, "[main] Received msg: " & $dest)
  
  doAssert dest[^1] == "Hello World! " & $count

template runBasicReset*[T](chan: Chan[T], count: int) =

  for i in 1..count:
    let msg = "Hello World! " & $i
    logger.log(lvlDebug, "[main] Send msg: " & $msg)
    chan.send(msg)

  check chan.peek() == count
  chan.clear()
  check chan.peek() == 0

template runMultithreadInOrderTest*[T](chan: Chan[T]) =
  var worker1: Thread[void]

  # Launch the first worker.
  createThread(worker1) do:
    var lg = newConsoleLogger(logLevel, verboseFmtStr)
    lg.log(lvlDebug, "[worker1] sending message... ")
    chan.send("Hello World!")

  # Wait for the thread to exit before moving on to the next example.
  worker1.joinThread()

  var dest = ""
  chan.recv(dest)
  logger.log(lvlDebug, "[main] Received msg: " & $dest)
  doAssert dest == "Hello World!"


template runMultithreadNonRecvBlockTest*[T](chan: Chan[T]) =
  var worker2: Thread[void]
  # Launch the other worker.
  createThread(worker2) do: 
    # This is another proc to run in a background thread. This proc takes a while
    # to send the message since it sleeps for 2 seconds (or 2000 milliseconds).
    var lg = newConsoleLogger(logLevel, verboseFmtStr)
    sleep(2000)
    lg.log(lvlDebug, "[worker2] sending message... ")
    chan.send("Another message")

  # This time, use a non-blocking approach with tryRecv.
  # Since the main thread is not blocked, it could be used to perform other
  # useful work while it waits for data to arrive on the channel.

  logger.log(lvlDebug, "[main] running non-blocking tryRecv")
  var messages: seq[string]
  var msg = ""
  while true:
    let tried = chan.tryRecv(msg)
    if tried:
      logger.log(lvlDebug, "[main] Receive msg: " & $msg)
      messages.add move(msg)
      break

    messages.add "Pretend I'm doing useful work..."
    logger.log(lvlDebug, "[main] add fakeMsg to messages (other work): " & $messages.len())
    sleep(400)

  # Wait for the second thread to exit before cleaning up the channel.
  worker2.joinThread()

  # Clean up the channel.
  check messages[^1] == "Another message"
  check messages.len >= 2

template runMultithreadRecvBlockTest*[T](chan: Chan[T]) =
  var worker2: Thread[void]
  # Launch the other worker.
  createThread(worker2) do: 
    # This is another proc to run in a background thread. This proc takes a while
    # to send the message since it sleeps for 2 seconds (or 2000 milliseconds).
    var lg = newConsoleLogger(logLevel, verboseFmtStr)
    sleep(2000)
    lg.log(lvlDebug, "[worker2] sending message... ")
    chan.send("Another message")

  # This time, use a non-blocking approach with tryRecv.
  # Since the main thread is not blocked, it could be used to perform other
  # useful work while it waits for data to arrive on the channel.

  logger.log(lvlDebug, "[main] running blocking recv")
  var messages: seq[string]
  var msg = ""

  chan.recv(msg)
  logger.log(lvlDebug, "[main] Receive msg: " & $msg)
  messages.add move(msg)

  messages.add "Pretend I'm doing useful work..."
  logger.log(lvlDebug, "[main] add fakeMsg to messages (other work): " & $messages.len())
  sleep(400)

  # Wait for the second thread to exit before cleaning up the channel.
  worker2.joinThread()

  # Clean up the channel.
  check messages[0] == "Another message"
  check messages.len >= 2
