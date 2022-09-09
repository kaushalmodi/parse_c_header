import npeg
import parse_c_header

var
  structs: seq[CStruct]

doAssert cStructsPat.match("""
struct foo_s
{
    bool     foo; // comment for foo
    uint32_t bar; /* comment for bar */
};
""", structs).ok

echo structs

doAssert structs == @[CStruct(typ: "foo_s",
                              elems: @[CStructElem(typ: "bool",
                                                   ident: "foo",
                                                   commentSingle: "comment for foo",
                                                   commentMulti: ""),
                                       CStructElem(typ: "uint32_t",
                                                   ident: "bar",
                                                   commentSingle: "",
                                                   commentMulti: "comment for bar")])]
