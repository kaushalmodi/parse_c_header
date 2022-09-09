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
                                                    comment: "abc def"),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "aaa_bbb_Ccc",
                                                    comment: "ghi jkl"),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "ddd",
                                                    comment: "")])
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
                                                    comment: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "ddd",
                                                    comment: "")])
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
                                                    comment: "abc def."),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "b_a_r",
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "zoo[LULU]",
                                                    comment: "ghi jkl."),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "eee",
                                                    comment: ""),
                                        CStructElem(typ: "double",
                                                    ident: "fff_ggg [HHH_III]",
                                                    comment: "mno")])
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
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "b",
                                                    comment: "")])
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
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "b",
                                                    comment: "")])
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
                                                    comment: "abc def."),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "b_a_r",
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "zoo[LULU]",
                                                    comment: "ghi jkl."),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "eee",
                                                    comment: ""),
                                        CStructElem(typ: "double",
                                                    ident: "fff_ggg  [ABC_DEF]",
                                                    comment: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "h_i_j [K_L_M]",
                                                    comment: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "no[PQ]",
                                                    comment: "")]),
                       CStruct(typ: "fooBar",
                               elems: @[CStructElem(typ: "uint32_t",
                                                    ident: "a",
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "b",
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "c",
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "d",
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "e",
                                                    comment: ""),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "f",
                                                    comment: "")]),
                       CStruct(typ: "fooBarArr",
                               elems: @[CStructElem(typ: "fooBar",
                                                    ident: "profiles[NO_OF_PROFILES]",
                                                    comment: "")])
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
                                                    comment: "abc def"),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "aaa_bbb_Ccc",
                                                    comment: "ghi jkl"),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "dd_ee",
                                                    comment: "mno pqr."),
                                        CStructElem(typ: "uint32_t",
                                                    ident: "ff_gg",
                                                    comment: "stuvwxyz"),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "ddd",
                                                    comment: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "hhIIjj__kl",
                                                    comment: ""),
                                        CStructElem(typ: "uint16_t",
                                                    ident: "mno",
                                                    comment: "")])
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
