import etters

type
  DataObj*[T: SomeFloat] = object of RootObj
    field1 {.getter, mgetter, setter.}: seq[T]
    field2 {.getter, setter.}: string
    field3: bool
  DataRef*[T: SomeFloat] = ref DataObj[T]
  DataRefOf*[T: SomeFloat] = ref object of DataObj[T]
  Data2Ref*[T: SomeFloat] = ref object
    field1 {.getter, mgetter, setter.}: seq[T]
    field2 {.getter, setter.}: string
    field3: bool

func initDataObj*[T: SomeFloat](field1: seq[T], field2: string, field3: bool): DataObj[T] =
  result = DataObj[T](field1: field1, field2: field2, field3: field3)

func newDataRef*[T: SomeFloat](field1: seq[T], field2: string, field3: bool): DataRef[T] =
  result = DataRef[T](field1: field1, field2: field2, field3: field3)

func newDataRefOf*[T: SomeFloat](field1: seq[T], field2: string, field3: bool): DataRefOf[T] =
  result = DataRefOf[T](field1: field1, field2: field2, field3: field3)

func newData2Ref*[T: SomeFloat](field1: seq[T], field2: string, field3: bool): Data2Ref[T] =
  result = Data2Ref[T](field1: field1, field2: field2, field3: field3)

genEtters(DataObj, DataRef, Data2Ref)
