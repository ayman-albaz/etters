import unittest

import data

suite "etters data":

  setup:
    var data = initDataObj(field1 = @[1.0, 2.0], field2 = "hey", field3 = true)

  test "getter":
    # field1(data) = @[3.0, 4.0]  # Should not compile, cannot be assigned to
    # field2(data) = "vet"  # Should not compile, cannot be assigned to
    # field3(data) = false  # Should not compile, undeclaired identifier
    check field1(data) == @[1.0, 2.0]
    check field2(data) == "hey"
    # check field3(data) == true  # # Should not compile, undeclaired identifier

  test "mgetter":
    mfield1(data) = @[3.0, 4.0] 
    # mfield2(data) = "vet"  # Should not compile, undeclaired identifier
    # mfield3(data) = false  # Should not compile, undeclaired identifier
    check field1(data) == @[3.0, 4.0]
    check mfield1(data) == @[3.0, 4.0]
    check field2(data) == "hey"
    # check mfield2(data) == "hey"  # Should not compile, undeclaired identifier
    # check field3(data) == true  # # Should not compile, undeclaired identifier
    # check mfield3(data) == true  #  # Should not compile, undeclaired identifier

  test "setter":
    `field1=`(data, @[3.0, 4.0])
    `field2=`(data, "vet")  
    # `field3=`(data, false)    # Should not compile, undeclaired identifier
    check field1(data) == @[3.0, 4.0]
    check field2(data) == "vet"
    # check field3(data) == true  # # Should not compile, undeclaired identifier


suite "etters DataRef":

  setup:
    var data = newDataRef(field1 = @[1.0, 2.0], field2 = "hey", field3 = true)

  test "getter":
    # field1(data) = @[3.0, 4.0]  # Should not compile, cannot be assigned to
    # field2(data) = "vet"  # Should not compile, cannot be assigned to
    # field3(data) = false  # Should not compile, undeclaired identifier
    check field1(data) == @[1.0, 2.0]
    check field2(data) == "hey"
    # check field3(data) == true  # # Should not compile, undeclaired identifier

  test "mgetter":
    mfield1(data) = @[3.0, 4.0] 
    # mfield2(data) = "vet"  # Should not compile, undeclaired identifier
    # mfield3(data) = false  # Should not compile, undeclaired identifier
    check field1(data) == @[3.0, 4.0]
    check mfield1(data) == @[3.0, 4.0]
    check field2(data) == "hey"
    # check mfield2(data) == "hey"  # Should not compile, undeclaired identifier
    # check field3(data) == true  # # Should not compile, undeclaired identifier
    # check mfield3(data) == true  #  # Should not compile, undeclaired identifier


suite "etters DataRefOf":

  setup:
    var data = newDataRefOf(field1 = @[1.0, 2.0], field2 = "hey", field3 = true)

  test "getter":
    # field1(data) = @[3.0, 4.0]  # Should not compile, cannot be assigned to
    # field2(data) = "vet"  # Should not compile, cannot be assigned to
    # field3(data) = false  # Should not compile, undeclaired identifier
    check field1(data) == @[1.0, 2.0]
    check field2(data) == "hey"
    # check field3(data) == true  # # Should not compile, undeclaired identifier

  test "mgetter":
    mfield1(data) = @[3.0, 4.0] 
    # mfield2(data) = "vet"  # Should not compile, undeclaired identifier
    # mfield3(data) = false  # Should not compile, undeclaired identifier
    check field1(data) == @[3.0, 4.0]
    check mfield1(data) == @[3.0, 4.0]
    check field2(data) == "hey"
    # check mfield2(data) == "hey"  # Should not compile, undeclaired identifier
    # check field3(data) == true  # # Should not compile, undeclaired identifier
    # check mfield3(data) == true  #  # Should not compile, undeclaired identifier

  test "setter":
    `field1=`(data, @[3.0, 4.0])
    `field2=`(data, "vet")  
    # `field3=`(data, false)    # Should not compile, undeclaired identifier
    check field1(data) == @[3.0, 4.0]
    check field2(data) == "vet"
    # check field3(data) == true  # # Should not compile, undeclaired identifier


  test "setter":
    `field1=`(data, @[3.0, 4.0])
    `field2=`(data, "vet")  
    # `field3=`(data, false)    # Should not compile, undeclaired identifier
    check field1(data) == @[3.0, 4.0]
    check field2(data) == "vet"
    # check field3(data) == true  # # Should not compile, undeclaired identifier

suite "etters Data2Ref":

  setup:
    var data = newData2Ref(field1 = @[1.0, 2.0], field2 = "hey", field3 = true)

  test "getter":
    # field1(data) = @[3.0, 4.0]  # Should not compile, cannot be assigned to
    # field2(data) = "vet"  # Should not compile, cannot be assigned to
    # field3(data) = false  # Should not compile, undeclaired identifier
    check field1(data) == @[1.0, 2.0]
    check field2(data) == "hey"
    # check field3(data) == true  # # Should not compile, undeclaired identifier

  test "mgetter":
    mfield1(data) = @[3.0, 4.0] 
    # mfield2(data) = "vet"  # Should not compile, undeclaired identifier
    # mfield3(data) = false  # Should not compile, undeclaired identifier
    check field1(data) == @[3.0, 4.0]
    check mfield1(data) == @[3.0, 4.0]
    check field2(data) == "hey"
    # check mfield2(data) == "hey"  # Should not compile, undeclaired identifier
    # check field3(data) == true  # # Should not compile, undeclaired identifier
    # check mfield3(data) == true  #  # Should not compile, undeclaired identifier

  test "setter":
    `field1=`(data, @[3.0, 4.0])
    `field2=`(data, "vet")  
    # `field3=`(data, false)    # Should not compile, undeclaired identifier
    check field1(data) == @[3.0, 4.0]
    check field2(data) == "vet"
    # check field3(data) == true  # # Should not compile, undeclaired identifier