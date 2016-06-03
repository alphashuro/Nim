discard """
  file: "tasyncall.nim"
  exitcode: 0
"""
import times, sequtils
import asyncdispatch

const
  taskCount = 10
  sleepDuration = 500

proc futureWithValue(x: int): Future[int] {.async.} =
  await sleepAsync(sleepDuration)
  return x

proc futureWithoutValue() {.async.} =
  await sleepAsync(1000)

proc testFuturesWithValue(x: int): seq[int] =
  var tasks = newSeq[Future[int]](taskCount)

  for i in 0..<taskCount:
    tasks[i] = futureWithValue(x)

  result = waitFor all(tasks)

proc testFuturesWithoutValues() =
  var tasks = newSeq[Future[void]](taskCount)

  for i in 0..<taskCount:
    tasks[i] = futureWithoutValue()

  waitFor all(tasks)

block:
  let
    startTime = cpuTime()
    results = testFuturesWithValue(42)
    expected = repeat(42, taskCount)
    execTime = cpuTime() - startTime

  doAssert execTime * 1000 < taskCount * sleepDuration
  doAssert results == expected

block:
  let startTime = cpuTime()
  testFuturesWithoutValues()
  let execTime = cpuTime() - startTime

  doAssert execTime * 1000 < taskCount * sleepDuration
