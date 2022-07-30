![Linux Build Status (Github Actions)](https://github.com/ayman-albaz/etters/actions/workflows/install_and_test.yml/badge.svg) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# Etters
Etters, a pragmatic Nim library combining move semantics and object oriented encapsulation.

## Installation
`nimble install https://github.com/ayman-albaz/etters`

I will add this to nimble there is a demand for it.

## Quick Start
```Nim
type
  DataObj* = object
    field1 {.getter, mgetter, setter.}: seq[float]
    field2 {.getter, setter.}: string
    field3: bool

genEtters(DataObj)
```
expands into
```Nim
type
  DataObj* = object
    field1: seq[float]
    field2: string
    field3: bool

proc field1*(self: DataObj): lent seq[float] =
  # getter
  result = self.field1

proc field1*(self: ref DataObj): lent seq[float] =
  # getter
  result = self.field1

proc mfield1*(self: var DataObj): var seq[float] =
  # mgetter
  result = self.field1

proc mfield1*(self: ref DataObj): var seq[float] =
  # mgetter
  result = self.field1

proc `field1=`*(self: var DataObj; field1: sink seq[float]) =
  # setter
  self.field1 = field1

proc `field1=`*(self: ref DataObj; field1: sink seq[float]) =
  # setter
  self.field1 = field1

proc field2*(self: DataObj): lent string =
  # getter
  result = self.field2

proc field2*(self: ref DataObj): lent string =
  # getter
  result = self.field2

proc `field2=`*(self: var DataObj; field2: sink string) =
  # setter
  self.field2 = field2

proc `field2=`*(self: ref DataObj; field2: sink string) =
  # setter
  self.field2 = field2
```

This now allows us to combine Nim style getters/setters with move semantics.
E.g.
```Nim
# In a different module...
var dataObj = DataObj()

# getter: Immutable view inside `field1`
echo dataObj.field1 

# mgetter: Mutable view inside `field1` (no move semantics here)
echo dataObj.mfield1
dataObj.mfield1 = @[0.0]

# setter: Move value to `field1`
dataObj.field1 = @[99.0]
```

## API
As of now, the library is composed of just 1 macro and 6 pragmas.

### `{.getter.}` 
Generates a proc that returns an immutable view to a field via `lent T`.
E.g. 
```Nim
proc field1*(self: DataObj): lent seq[float] =
  result = self.field1

proc field1*(self: ref DataObj): lent seq[float] =
  result = self.field1
```
When used on a `ref object` it would generate
```Nim
proc mfield1*(self: Data): var seq[float] =
  result = self.field1
```

### `{.mgetter.}`
Generates a proc that returns a mutable view to a field via `lent T`.
E.g. 
```Nim
proc mfield1*(self: var DataObj): var seq[float] =
  result = self.field1

proc mfield1*(self: ref DataObj): var seq[float] =
  result = self.field1
```
When used on a `ref object` it would generate
```Nim
proc mfield1*(self: Data): var seq[float] =
  result = self.field1
```

### `{.setter.}` 
Generates a proc that ***moves*** `T` to the corresponding object field via `sink`.
E.g. 
```Nim
proc `field1=`*(self: var DataObj; field1: sink seq[float]) =
  self.field1 = field1

proc `field1=`*(self: ref DataObj; field1: sink seq[float]) =
  self.field1 = field1
```
When used on a `ref object` it would generate
```Nim
proc `field1=`*(self: Data; field1: sink seq[float]) =
  self.field1 = field1
```

### `{.getterCustom.}`, `{.mgetterCustom.}`, `{.setterCustom.}` are placeholder pragmas.
They do absolutely nothing and should be used when you want to create your own custom getter/setter procs,
but convery within the object definition that you are using some sort of getter/setter procs.


### `genEtters` 
The macro that generates the code from any list of `Typedesc`.
E.g.
```Nim
type
  DataObj* = object
    field1 {.getter, mgetter, setter.}: seq[float]
  Data* = ref object
    field1 {.getter, mgetter, setter.}: seq[float]
genEtters(DataObj, Data)
```

## Rationale
***What if we turned OOP fun again?*** A once ridiculous idea I had, turned into a suprisingly cool solution thanks to Nim metaprogramming.

To get the idea behind this, it is good to understand the following concepts:
1. [Move semantics in Nim](https://nim-lang.org/docs/destructors.html)
2. [Method call syntax in Nim](https://nim-lang.org/docs/tut2.html#object-oriented-programming-properties)
3. [Introduction to macros in Nim](https://nim-lang.org/docs/tut3.html)

[Encapsulation](https://en.wikipedia.org/wiki/Encapsulation_(computer_programming)) is controversial. Some people think its the way to go when programming, while others think its just a cargo cult programming practice that needs to die (google "hackernews getters setters")

Both parties have some truth behind their claim. On one hand encapsulation can save a lot of headaches as the codebase grows. On the other hand encapsulation can take a lot of time and add noise to the code.

After writing my 50th getter/setter, I found that Nim is able to take encapsulation to the next level with the following. 
1. By using metaprogramming, we can ***save developers time and reduce code noise***.
2. By using pragmas, the getter/setter implementation is ***self documenting***. One only needs to look at the object definition to see exactly how the object can be accessed outside the module.
3. By using Nim's new move semantics capabilties, we can create a relatively ***efficient copy-free implementation***.

Consider the following implementation.
`server.nim`
```Nim
import etters

type
  Message = ref object
    datestamp {.getter, setterCustom.}: string
    id {.getter, setter.}: string
    payload {.getter.}: string

proc newMessage(...) = ...  # Your implementation

proc `datestamp=`(self: Message, datestamp: sink string) =
  # This is a custom setter
  assert datestamp != ""
  self.datestamp = datestamp

genEtters(Message)
```
Just by looking at the Message type, we are able to see all the different ways we can access the fields of mesasge.
- For `datestamp` we can get it and set it. The setter implementation is a custom user made one.
- For `id` we can get it and set it.
- For `payload` we can get it only.

In another module, `client.nim`, we decide to recieve a message and send it back to the server:
```nim
import strutils, times
import server

proc pong() =
  let message = client.recieve()  # Assume we have a client type that can listen
  message.datestamp = $now()  # setterCustom
  message.id = $(message.id.parseInt() + 1)  # getter and setter
  echo "PING-PONG: " & message.paylod  # getter
  # We cannot edit the message paylod because we have no need for it
  # We just want to bounce the message back
```
With the power of Nim's method call syntax, we can call on those generated procs as if we were accessing the objects fields! 

## Best practices
- Avoid making fields with etters pragmas public. If you do you will not be able to use the convinient method call syntax and will have to call the generated procs the verbose way.
- Compile your code using `nim --hint[Performance]:on --mm:orc c -r ...`. Compiling with `--hint[Performance]:on` will allow the compiler to hint at you when `sink` move semantics aren't working as intended.
- When using the `genEtters` command, it is best to use it at the bottom of the module to avoid confusion with direct field access. When used in the same module `genEtters` will not generate naming clashes with accessors.
  - When `genEtters` is used, access from the same module can be done by:
    - Getters: `field1(self)` as opposed to `self.field`
    - Mgetters: `mfield(self)` as opposed to `self.mfield`
    - Setters: \``field=`\``(self, fieldval)` as opposed to `self.field = fieldval`
  - access from a different module can be done by:
    - Getters: `field1(self)` and `self.field`
    - Mgetters: `mfield(self)` and `self.mfield`
    - Setters: \``field1=`\``(self, field1val)` and `self.field = fieldval`
- Start by keeping all your fields private. Only add etters pragmas when you find a need to add them in other modules.
- If you decide to use etters and decide to roll your own getter/setter implementation, please use the placeholder pragmas (e.g. `{.getterCustom.}`)

## Limitations
- You cannot use `{.mgetter.}` and have two fields that are the same name, but one starting with m (e.g. `x: int` and `mx: int`)
- Pragmas can only be used when there is one field per line
- Pragmas can only be used for objects that are of `object` and `ref object`
- Due to the current implementation, only the following forms of inheritance are supported
```Nim
type
  DataObj*[T: SomeFloat] = ref object of RootObj
    field1 {.getter, mgetter, setter.}: seq[T]
    field2 {.getter, setter.}: string
    field3: bool
  
  # Inheritance of etters methods works
  DataRef*[T: SomeFloat] = ref DataObj[T]

  # Inheritance of etters methods works
  DataRefOf*[T: SomeFloat] = ref object of DataObj[T]

# Generating for `DataObj` will make it work for all the examples above.
genEtters(DataObj)
```
  - Basically `ref T`, `object of T`, `ref object of T` are supported
  - To me this is less than ideal. I would prefer if the library would have more granular levels of control.
  - Ideally, an `{.inheritEtters.}` pragma should be used to generate etters implementations instead of generating them at the root. I have tried to approach this problem, but it is too dificult for now. PRs appreciated here.
  - The supported methods of inheritance are the ones the average nim user will most likely use.

## TODO
- Add `{.inheritEtters.}` to add more granularity and control for etters inheritance.
- While not library specific, it would be interesting to benchmark performance of move semantics and object oriented encapsulation against direct field access.
- There may be some corner cases with generic objects that I may not have covered yet. So use at your own discretion and please submit bug fixes.
- Finalize the API. I don't expect the API to be stable until 1.0.0. But at the same time, the concept behind this library is simple enough that it shouldn't change much anyways.

## Contact
I can be reached at aymanalbaz98@gmail.com
