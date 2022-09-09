import npeg

type
  CStructElem* = object
    typ*: string
    ident*: string
    comment*: string
  CStruct* = object
    typ*: string
    elems*: seq[CStructElem]

var
  structTyp: string
  commentVar: string
  elemsVar: seq[CStructElem]

let
  cStructsPat* = peg("structs", s: seq[CStruct]):
    # +(struct | nonEmptyLine | nl) : Matches 'struct' first. If that doesn't
    # matches, match the 'nonEmptyLine' pattern, and finally matches the
    # blank-line or 'nl' pattern.
    structs <- +(struct | nonEmptyLine | nl) * !1

    struct <- structStart * +((elemLine | nonEmptyLine | nl) - blockEnd) * blockEnd:
      s.add CStruct(typ: structTyp,
                    elems: elemsVar)
      structTyp.reset
      elemsVar.reset

    # '\n'         : Literally matches newline char
    # *            : pattern concatenation op
    # ?'\r'        : Matches zero or one occurrence of the '\r' character
    # '\n' * ?'\r' : Matches '\n' followed by occurrence of zero or one occurrence of the '\r' character
    nl <- '\n' * ?'\r'
    spOrNl <- Space # optional space, tab, newline, .. any "space"

    cIdentFirstChar <- {'A' .. 'Z', 'a' .. 'z', '_'}
    cIdentChars <- cIdentFirstChar | {'0' .. '9'}
    cArray <- '[' * *Blank * +cIdentChars * *Blank * ']'
    ident <- cIdentFirstChar * *cIdentChars * ?(*Blank * cArray)
    idents <- ident * *(*Blank * ',' * *Blank * ident)

    commentLine <- "//" * *Blank * >*(1 - nl):
      when defined(debug):
        echo "comment = ", $1
      commentVar = $1

    structStart <- *Blank * "struct" * +Blank * >ident * *spOrNl * '{' * ?nl:
      when defined(debug):
        echo "found structStart, struct typ = ", $1
      structTyp = $1

    blockEnd <- *Blank * "};" * ?nl:
      when defined(debug):
        echo "found blockEnd"

    elemLine <- *Blank * >ident * +Blank * >idents * *Blank * ';' * *Blank * ?commentLine * ?nl:
      when defined(debug):
        echo "elem type = ", $1
        echo "elem identifier = ", $2
      elemsVar.add CStructElem(typ: $1,
                               ident: $2,
                               comment: commentVar)
      commentVar.reset

    # 'nonEmptyLine' will not match a blank line.
    nonEmptyLine <- >+(1 - nl):
      when defined(debug):
        echo "random line = `", $1, "'"
