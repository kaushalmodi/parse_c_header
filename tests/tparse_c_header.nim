import std/[unittest]
import npeg
import parse_c_header

suite "parse structs":

  setup:
    var
      structs: seq[CStruct]

  test "basic":
    check cStructsPat.match("""
// foo
struct fooD
{
    bool        bar, foo;        // abc def
    uint32_t    aaa_bbb_Ccc;  // ghi jkl
    uint16_t    ddd;
};
// bar""", structs).ok
    when defined(debug):
      echo structs
    check structs == @[CStruct(typ: "fooD",
                               elems: @[CStructElem(typ: "bool",
                                                    ident: "bar, foo",
                                                    commentSingle: "abc def",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "aaa_bbb_Ccc",
                                                    commentSingle: "ghi jkl",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "ddd",
                                                    commentSingle: "",
                                                    commentMulti: "")])
    ]

  test "empty comment":
    check cStructsPat.match("""
struct fooD
{
    bool        bar;        //
    uint16_t    ddd;
};
""", structs).ok
    when defined(debug):
      echo structs
    check structs == @[CStruct(typ: "fooD",
                               elems: @[CStructElem(typ: "bool",
                                                    ident: "bar",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "ddd",
                                                    commentSingle: "",
                                                    commentMulti: "")])
    ]

  test "multi-line comment":
    check cStructsPat.match("""
struct fooD
{
    bool        bar;        /*
                             * comment for bar
                             */
    /*
     * comment for ddd
     */
    uint16_t    ddd;
};
""", structs).ok
    when defined(debug):
      echo structs
    check structs == @[CStruct(typ: "fooD",
                               elems: @[CStructElem(typ: "bool",
                                                    ident: "bar",
                                                    commentSingle: "",
                                                    commentMulti: """

                             * comment for bar
                             """),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "ddd",
                                                    commentSingle: "",
                                                    commentMulti: """

     * comment for ddd
     """)])
    ]

  test "structs with arrays":
    check cStructsPat.match("""
struct zoo_t
{
    uint16_t foo;                             // abc def.
    uint16_t b_a_r;                  //
    uint32_t zoo[LULU];         // ghi jkl.
    uint32_t eee;                        //
    double   fff_ggg [HHH_III]; // mno
};
""", structs).ok
    when defined(debug):
      echo structs
    check structs == @[CStruct(typ: "zoo_t",
                               elems: @[CStructElem(typ: "uint16_t",
                                                    ident: "foo",
                                                    commentSingle: "abc def.",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "b_a_r",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "zoo[LULU]",
                                                    commentSingle: "ghi jkl.",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "eee",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "double",
                                                    ident: "fff_ggg [HHH_III]",
                                                    commentSingle: "mno",
                                                    commentMulti: "")])
    ]

  test "structs with blank lines":
    check cStructsPat.match("""
struct fooBar
{

    uint32_t    a;

    uint32_t    b;
};
""", structs).ok
    when defined(debug):
      echo structs
    check structs == @[CStruct(typ: "fooBar",
                               elems: @[CStructElem(typ: "uint32_t",
                                                    ident: "a",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "b",
                                                    commentSingle: "",
                                                    commentMulti: "")])
    ]

  test "structs with comment lines":
    check cStructsPat.match("""
struct fooBar
{
    /* comment a */
    uint32_t    a;
    /* comment b */
    uint32_t    b;
};
""", structs).ok
    when defined(debug):
      echo structs
    check structs == @[CStruct(typ: "fooBar",
                               elems: @[CStructElem(typ: "uint32_t",
                                                    ident: "a",
                                                    commentSingle: "",
                                                    commentMulti: " comment a "),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "b",
                                                    commentSingle: "",
                                                    commentMulti: " comment b ")])
    ]

  test "multiple structs":
    check cStructsPat.match("""
struct zoo_t
{
    uint16_t foo;                             // abc def.
    uint16_t b_a_r;                  //
    uint32_t zoo[LULU];         // ghi jkl.
    uint32_t eee;                        //
    double   fff_ggg  [ABC_DEF]; //
    uint16_t h_i_j [K_L_M];
    uint16_t no[PQ];
};

struct fooBar
{
    /* comment a */
    uint32_t    a;
    /* comment b */
    uint32_t    b;
    uint32_t    c;

    /* comment d */
    uint32_t    d;
    /* comment e */
    uint32_t    e;
    /* comment f */
    uint32_t    f;
};

struct fooBarArr
{
    fooBar profiles[NO_OF_PROFILES];
};
""", structs).ok
    when defined(debug):
      echo structs
    check structs == @[CStruct(typ: "zoo_t",
                               elems: @[CStructElem(typ: "uint16_t",
                                                    ident: "foo",
                                                    commentSingle: "abc def.",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "b_a_r",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "zoo[LULU]",
                                                    commentSingle: "ghi jkl.",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "eee",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "double",
                                                    ident: "fff_ggg  [ABC_DEF]",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "h_i_j [K_L_M]",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "no[PQ]",
                                                    commentSingle: "",
                                                    commentMulti: "")]),
                       CStruct(typ: "fooBar",
                               elems: @[CStructElem(typ: "uint32_t",
                                                    ident: "a",
                                                    commentSingle: "",
                                                    commentMulti: " comment a "),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "b",
                                                    commentSingle: "",
                                                    commentMulti: " comment b "),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "c",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "d",
                                                    commentSingle: "",
                                                    commentMulti: " comment d "),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "e",
                                                    commentSingle: "",
                                                    commentMulti: " comment e "),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "f",
                                                    commentSingle: "",
                                                    commentMulti: " comment f ")]),
                       CStruct(typ: "fooBarArr",
                               elems: @[CStructElem(typ: "fooBar",
                                                    ident: "profiles[NO_OF_PROFILES]",
                                                    commentSingle: "",
                                                    commentMulti: "")])
    ]

  test "example header":
    check cStructsPat.match("""
/**
* Copyright 2022 Monsters Inc.
*/

#ifndef _FOO_H_
#define _FOO_H_

#include "bar.h"

struct fooD
{
    bool        bar;        // abc def
    uint32_t    aaa_bbb_Ccc;  // ghi jkl
    uint32_t    dd_ee; // mno pqr.
    uint32_t    ff_gg;   // stuvwxyz
    uint16_t    ddd;
    uint16_t    hhIIjj__kl;
    uint16_t    mno;
};

void zoo(fooD* d);
#endif
""", structs).ok
    when defined(debug):
      echo structs
    check structs == @[CStruct(typ: "fooD",
                               elems: @[CStructElem(typ: "bool",
                                                    ident: "bar",
                                                    commentSingle: "abc def",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "aaa_bbb_Ccc",
                                                    commentSingle: "ghi jkl",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "dd_ee",
                                                    commentSingle: "mno pqr.",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "ff_gg",
                                                    commentSingle: "stuvwxyz",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "ddd",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "hhIIjj__kl",
                                                    commentSingle: "",
                                                    commentMulti: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "mno",
                                                    commentSingle: "",
                                                    commentMulti: "")])
    ]

  test "enum block closing brace ignore":
    check cStructsPat.match("""
struct aBcD_t
{
	foo_t f;
};

enum FooBar_e
{
	ABC_DEF = 0,
};
""", structs).ok
