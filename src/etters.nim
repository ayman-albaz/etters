import macros

template getter*() {.pragma.}
template mgetter*() {.pragma.}
template setter*() {.pragma.}
template getterCustom*() {.pragma.}
template mgetterCustom*() {.pragma.}
template setterCustom*() {.pragma.}


func transformChildrenSymToIdent(nn: NimNode): NimNode = 
  # Transforms all children sym in node to ident
  result = nn
  for i, node in nn:
    if node.kind == nnkSym:
      result[i] = newIdentNode(node.repr())

func isObj(objectTypeNode: NimNode): bool =
  result = objectTypeNode.getImpl().findChild(it.kind == nnkObjectTy).kind != nnkNilLit

func isRefObj(objectTypeNode: NimNode): bool =
  result = objectTypeNode.getImpl().findChild(it.kind == nnkRefTy).kind != nnkNilLit

func genSelfNode1(objectTypeNode: NimNode): NimNode =
  # Generates T
  # Takes care of generics
  let genericParamsNode = objectTypeNode.getImpl().findChild(it.kind == nnkGenericParams)
  let transformedGenericParamsNode = transformChildrenSymToIdent(genericParamsNode)
  if genericParamsNode.kind == nnkNilLit:
    result = newIdentDefs(
      newIdentNode("self"),
      newIdentNode(objectTypeNode.repr())
    )
  else:
    var selfGenericParamsNode = nnkBracketExpr.newNimNode()
    selfGenericParamsNode.add(newIdentNode(objectTypeNode.repr()))
    transformedGenericParamsNode.copyChildrenTo(selfGenericParamsNode)
    result = newIdentDefs(
      newIdentNode("self"),
      selfGenericParamsNode
    )

func genSelfNode2(objectTypeNode: NimNode): NimNode =
  # Generates var T
  # Takes care of generics
  let genericParamsNode = objectTypeNode.getImpl().findChild(it.kind == nnkGenericParams)
  let transformedGenericParamsNode = transformChildrenSymToIdent(genericParamsNode)
  if transformedGenericParamsNode.kind == nnkNilLit:
    result = newIdentDefs(
      newIdentNode("self"),
      nnkVarTy.newTree(
        newIdentNode(objectTypeNode.repr())
      ),
    )
    # elif objectTypeNode.getImpl().findChild(it.kind == nnkRefTy).kind != nnkNilLit:
    #   result = newIdentDefs(
    #     newIdentNode("self"),
    #     newIdentNode(objectTypeNode.repr())
    #   )
  else:
    var selfGenericParamsNode = nnkBracketExpr.newNimNode()
    selfGenericParamsNode.add(newIdentNode(objectTypeNode.repr()))
    transformedGenericParamsNode.copyChildrenTo(selfGenericParamsNode)
    result = newIdentDefs(
      newIdentNode("self"),
      nnkVarTy.newTree(
        selfGenericParamsNode
      ),
    )

func genSelfNode3(objectTypeNode: NimNode): NimNode =
  # Generates ref T
  # Takes care of generics
  let genericParamsNode = objectTypeNode.getImpl().findChild(it.kind == nnkGenericParams)
  let transformedGenericParamsNode = transformChildrenSymToIdent(genericParamsNode)
  if transformedGenericParamsNode.kind == nnkNilLit:
    result = newIdentDefs(
      newIdentNode("self"),
      nnkRefTy.newTree(
        newIdentNode(objectTypeNode.repr())
      )
    )
  else:
    var selfGenericParamsNode = nnkBracketExpr.newNimNode()
    selfGenericParamsNode.add(newIdentNode(objectTypeNode.repr()))
    transformedGenericParamsNode.copyChildrenTo(selfGenericParamsNode)
    result = newIdentDefs(
      newIdentNode("self"),
      nnkRefTy.newTree(
        selfGenericParamsNode
      )
    )

func genGetterNewProcName(fieldNameNode: NimNode): NimNode =
  # Proc is public
  result = nnkPostFix.newTree(
    newIdentNode("*"),
    fieldNameNode
  )

func genMgetterNewProcName(fieldNameNode: NimNode): NimNode =
  # Proc is public
  result = nnkPostFix.newTree(
    newIdentNode("*"),
    newIdentNode("m" & fieldNameNode.repr())
  )

func genSetterNewProcName(fieldNameNode: NimNode): NimNode =
  # Proc is public
  result = nnkPostFix.newTree(
    newIdentNode("*"),
    nnkAccQuoted.newTree(
      fieldNameNode,
      newIdentNode("=")
    )
  )

func genGetterNewProcParams(objectTypeNode, fieldTypeNode: NimNode): array[2, NimNode] =
  result = [
    nnkCommand.newTree(
      newIdentNode("lent"),
      fieldTypeNode
    ),
    genSelfNode1(objectTypeNode)
  ]

# func genGetterNewProcParamsVar(objectTypeNode, fieldTypeNode: NimNode): array[2, NimNode] =
#   result = [
#     nnkCommand.newTree(
#       newIdentNode("lent"),
#       fieldTypeNode
#     ),
#     genSelfNode2(objectTypeNode)
#   ]

func genGetterNewProcParamsRef(objectTypeNode, fieldTypeNode: NimNode): array[2, NimNode] =
  result = [
    nnkCommand.newTree(
      newIdentNode("lent"),
      fieldTypeNode
    ),
    genSelfNode3(objectTypeNode)
  ]

func genMgetterNewProcParams(objectTypeNode, fieldTypeNode: NimNode): array[2, NimNode] =
  result = [
    nnkVarTy.newTree(
      fieldTypeNode
    ),
    genSelfNode1(objectTypeNode)
  ]

func genMgetterNewProcParamsVar(objectTypeNode, fieldTypeNode: NimNode): array[2, NimNode] =
  result = [
    nnkVarTy.newTree(
      fieldTypeNode
    ),
    genSelfNode2(objectTypeNode)
  ]

func genMgetterNewProcParamsRef(objectTypeNode, fieldTypeNode: NimNode): array[2, NimNode] =
  result = [
    nnkVarTy.newTree(
      fieldTypeNode
    ),
    genSelfNode3(objectTypeNode)
  ]

func genSetterNewProcParams(objectTypeNode, fieldNameNode, fieldTypeNode: NimNode): array[3, NimNode] =
  result = [
    newEmptyNode(),
    genSelfNode1(objectTypeNode),
    newIdentDefs(
      fieldNameNode,
      nnkCommand.newTree(
        newIdentNode("sink"),
        fieldTypeNode
      )
    ),
  ]

func genSetterNewProcParamsVar(objectTypeNode, fieldNameNode, fieldTypeNode: NimNode): array[3, NimNode] =
  result = [
    newEmptyNode(),
    genSelfNode2(objectTypeNode),
    newIdentDefs(
      fieldNameNode,
      nnkCommand.newTree(
        newIdentNode("sink"),
        fieldTypeNode
      )
    ),
  ]

func genSetterNewProcParamsRef(objectTypeNode, fieldNameNode, fieldTypeNode: NimNode): array[3, NimNode] =
  result = [
    newEmptyNode(),
    genSelfNode3(objectTypeNode),
    newIdentDefs(
      fieldNameNode,
      nnkCommand.newTree(
        newIdentNode("sink"),
        fieldTypeNode
      )
    ),
  ]

func genGetterNewProcStmtList(fieldNameNode: NimNode): NimNode =
  result = newStmtList(
    newAssignment(
      newIdentNode("result"),
      newDotExpr(
        newIdentNode("self"),
        fieldNameNode
      )
    )
  )

func genSetterNewProcStmtList(fieldNameNode: NimNode): NimNode =
  result = newStmtList(
    newAssignment(
      newDotExpr(
        newIdentNode("self"),
        fieldNameNode,
      ),
      fieldNameNode
    )
  )

func genGenericParamsNode(objectTypeNode: NimNode): NimNode =
  let genericParamsNode = objectTypeNode.getImpl().findChild(it.kind == nnkGenericParams)
  let transformedGenericParamsNode = transformChildrenSymToIdent(genericParamsNode)
  if transformedGenericParamsNode.kind == nnkNilLit: result = newEmptyNode()
  else:
    var identDefsNode = nnkIdentDefs.newNimNode()
    transformedGenericParamsNode.copyChildrenTo(identDefsNode)
    identDefsNode.add(newEmptyNode(), newEmptyNode())
    result = nnkGenericParams.newTree(identDefsNode)

func genGetter(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newProc(
    genGetterNewProcName(fieldNameNode),
    genGetterNewProcParams(objectTypeNode, fieldTypeNode),
    genGetterNewProcStmtList(fieldNameNode)
  )
  result[2] = genGenericParamsNode(objectTypeNode)

# func genGetterVar(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
#   result = newProc(
#     genGetterNewProcName(fieldNameNode),
#     genGetterNewProcParamsVar(objectTypeNode, fieldTypeNode),
#     genGetterNewProcStmtList(fieldNameNode)
#   )
#   result[2] = genGenericParamsNode(objectTypeNode)

func genGetterRef(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newProc(
    genGetterNewProcName(fieldNameNode),
    genGetterNewProcParamsRef(objectTypeNode, fieldTypeNode),
    genGetterNewProcStmtList(fieldNameNode)
  )
  result[2] = genGenericParamsNode(objectTypeNode)

func genMgetter(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newProc(
    genMgetterNewProcName(fieldNameNode),
    genMgetterNewProcParams(objectTypeNode, fieldTypeNode),
    genGetterNewProcStmtList(fieldNameNode)
  )
  result[2] = genGenericParamsNode(objectTypeNode)

func genMgetterVar(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newProc(
    genMgetterNewProcName(fieldNameNode),
    genMgetterNewProcParamsVar(objectTypeNode, fieldTypeNode),
    genGetterNewProcStmtList(fieldNameNode)
  )
  result[2] = genGenericParamsNode(objectTypeNode)

func genMgetterRef(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newProc(
    genMgetterNewProcName(fieldNameNode),
    genMgetterNewProcParamsRef(objectTypeNode, fieldTypeNode),
    genGetterNewProcStmtList(fieldNameNode)
  )
  result[2] = genGenericParamsNode(objectTypeNode)

func genSetter(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newProc(
    genSetterNewProcName(fieldNameNode),
    genSetterNewProcParams(objectTypeNode, fieldNameNode, fieldTypeNode),
    genSetterNewProcStmtList(fieldNameNode)
  )
  result[2] = genGenericParamsNode(objectTypeNode)

func genSetterVar(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newProc(
    genSetterNewProcName(fieldNameNode),
    genSetterNewProcParamsVar(objectTypeNode, fieldNameNode, fieldTypeNode),
    genSetterNewProcStmtList(fieldNameNode)
  )
  result[2] = genGenericParamsNode(objectTypeNode)

func genSetterRef(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newProc(
    genSetterNewProcName(fieldNameNode),
    genSetterNewProcParamsRef(objectTypeNode, fieldNameNode, fieldTypeNode),
    genSetterNewProcStmtList(fieldNameNode)
  )
  result[2] = genGenericParamsNode(objectTypeNode)

func genGetterImpl(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newStmtList()
  if isObj(objectTypeNode):
    result.add genGetter(fieldNameNode, objectTypeNode, fieldTypeNode)
    result.add genGetterRef(fieldNameNode, objectTypeNode, fieldTypeNode)
  elif isRefObj(objectTypeNode):
    result.add genGetter(fieldNameNode, objectTypeNode, fieldTypeNode)

func genMgetterImpl(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newStmtList()
  if isObj(objectTypeNode):
    result.add genMgetterVar(fieldNameNode, objectTypeNode, fieldTypeNode)
    result.add genMgetterRef(fieldNameNode, objectTypeNode, fieldTypeNode)
  elif isRefObj(objectTypeNode):
    result.add genMgetter(fieldNameNode, objectTypeNode, fieldTypeNode)

func genSetterImpl(fieldNameNode, objectTypeNode, fieldTypeNode: NimNode): NimNode =
  result = newStmtList()
  if isObj(objectTypeNode):
    result.add genSetterVar(fieldNameNode, objectTypeNode, fieldTypeNode)
    result.add genSetterRef(fieldNameNode, objectTypeNode, fieldTypeNode)
  elif isRefObj(objectTypeNode):
    result.add genSetter(fieldNameNode, objectTypeNode, fieldTypeNode)

func genEttersField(objectTypeNode, fieldNode: NimNode): NimNode = 
  result = newStmtList()
  let pragmaExprNode = fieldNode.findChild(it.kind == nnkpragmaExpr)
  if pragmaExprNode.isNil() == false:
    let pragmaNodes = pragmaExprNode.findChild(it.kind == nnkPragma)
    for pragmaNode in pragmaNodes:
      let fieldNameNode = pragmaExprNode.findChild(it.kind == nnkIdent)
      let fieldTypeNode = fieldNode[1]
      if pragmaNode.repr == "getter":
        result.add genGetterImpl(fieldNameNode, objectTypeNode, fieldTypeNode)
      elif pragmaNode.repr == "mgetter":
        result.add genMgetterImpl(fieldNameNode, objectTypeNode, fieldTypeNode)
      elif pragmaNode.repr == "setter":
        result.add genSetterImpl(fieldNameNode, objectTypeNode, fieldTypeNode)

func getObjectFields(objectTypeNode: NimNode): NimNode =
  let objectNode = objectTypeNode.findChild(it.kind == nnkObjectTy) or objectTypeNode.findChild(it.kind == nnkRefTy).findChild(it.kind == nnkObjectTy)
  result = objectNode.findChild(it.kind == nnkRecList)

proc checkNodeIsTypedescNode(nn: NimNode) =
  if nn.kind != nnkSym:
    error("Input must only be Typedesc. Got " & nn.repr(), nn)
  if nn.symKind() != nskType:
    error("Input must only be Typedesc. Got " & $NimSymKind(nn.symKind()), nn)

func genEttersImpl(td: NimNode): NimNode =
  result = newStmtList()
  checkNodeIsTypedescNode(td)
  let objectTypeNode = td.getTypeInst()[1]
  let objectFieldNodes = objectTypeNode.getImpl().getObjectFields()
  # debugEcho objectTypeNode.getImpl().treeRepr()
  # debugEcho td.getType().treeRepr()
  for fieldNode in objectFieldNodes:
    let genEtterExpr = genEttersField(objectTypeNode, fieldNode)
    if genEtterExpr.kind != nnkNilLit:
      result.add(genEtterExpr)

# func getTypeRecursive(nn: NimNode): NimNode =
#   if nn.kind == nnkSym:
#     return nn
#   var nnNext = nn.findChild(it.kind == nnkBracketExpr)
#   if nnNext.kind == nnkNilLit:
#     nnNext = nn[1]
#   result = nnNext.getTypeRecursive()

# proc injectSym(nn, symNode: NimNode) =
#   nn[0] = symNode

macro genEtters*(tds: varargs[typed]): untyped =
  result = newStmtList()
  for td in tds:
    result.add(genEttersImpl(td))
  # echo result.treeRepr

# macro ettExperiment(tds: varargs[typed]): untyped =
#   for td in tds:
#     # let x = td.getType[1]
#     # echo x.getType.treeRepr()
#     echo td.getType().getTypeRecursive()
#     let oldTd = td.getType().getTypeRecursive()
#     let oldTdImpl = oldTd.getImpl()
#     oldTdImpl.injectSym(td)
#     echo oldTdImpl.treeRepr
#     echo td.getImpl.treeRepr

# type
#   DataObj*[T: SomeFloat] = ref object of RootObj
#     field1 {.getter, mgetter, setter.}: seq[T]
#     field2 {.getter, setter.}: string
#     field3: bool
#   DataRef*[T: SomeFloat] = ref object of DataObj[T]
#   Data2Ref*[T: SomeFloat] = ref object
#     field1 {.getter, mgetter, setter.}: seq[T]
#     field2 {.getter, setter.}: string
#     field3: bool

# genEtters(DataRef)
