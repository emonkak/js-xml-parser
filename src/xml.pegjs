{
  var ENTITY_REFERENCES = {
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&quot;': "'"
  };
}

// [1] document ::= prolog element Misc* - Char* RestrictedChar Char*
document
  = !(Char* RestrictedChar Char*) xml:prolog root:element Misc* {
    return { xml: xml, root: root };
  }

// [2] Char ::= [#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF] /* any Unicode character, excluding the surrogate blocks, FFFE, and FFFF. */
Char "Char"
  = [\u0001-\uD7FF\uE000-\uFFFD]
  / ([\uD800-\uDBFF][\uDC00-\uDFFF])

// [2a] RestrictedChar ::= [#x1-#x8] | [#xB-#xC] | [#xE-#x1F] | [#x7F-#x84] | [#x86-#x9F]
RestrictedChar "RestrictedChar"
  = [\u0001-\u0008\u000B-\u000C\u000E-\u001F\u007F-\u0084\u0086-\u009F]

// [3] S ::= (#x20 | #x9 | #xD | #xA)+
S "S"
  = ([\u0020\u0009\u000D\u000A])+

// [4] NameStartChar ::= ":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
NameStartChar "NameStartChar"
  = [:A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD]
  / ([\uD800-\uDBFF][\uDC00-\uDFFF])

// [4a] NameChar ::= NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
NameChar "NameChar"
  = NameStartChar
  / [-.0-9\u00B7\u0300-\u036F\u203F-\u2040]

// [5] Name ::= NameStartChar (NameChar)*
Name
  = $(NameStartChar NameChar*)

// [7] Nmtoken ::= (NameChar)+
Nmtoken
  = $NameChar+

// [9] EntityValue ::= '"' ([^%&"] | PEReference | Reference)* '"' | "'" ([^%&'] | PEReference | Reference)* "'"
EntityValue
  = '"' ([^%&"] / PEReference / Reference)* '"'
  / "'" ([^%&'] / PEReference / Reference)* "'"

// [10] AttValue ::= '"' ([^<&"] | Reference)* '"' | "'" ([^<&'] | Reference)* "'"
AttValue
  = '"' string:([^<&"] / Reference)* '"' {
    return string.join('');
  }
  / "'" string:([^<&'] / Reference)* "'" {
    return string.join('');
  }

// [11] SystemLiteral ::= ('"' [^"]* '"') | ("'" [^']* "'")
SystemLiteral
  = ('"' [^"]* '"') / ("'" [^']* "'")

// [12] PubidLiteral ::= '"' PubidChar* '"' | "'" (PubidChar - "'")* "'"
PubidLiteral
  = '"' PubidChar* '"' / "'" (!"'" PubidChar)* "'"

// [13] PubidChar ::= #x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
PubidChar "PubidChar"
  = [\u0020\u000D\u000Aa-zA-Z0-9\-()+,./:=?;!*#@$_%]

// [14] CharData ::= [^<&]* - ([^<&]* ']]>' [^<&]*)
CharData "CharData"
  = chars:(!']]>' char:([^<&] / Reference) { return char; })+ {
    return chars.join('');
  }

// [15] Comment ::= '<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'
Comment
  = '<!--' ((!'-' Char) / ('-' (!'-' Char)))* '-->'

// [16] PI ::= '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
PI
  = '<?' PITarget (S (!'?>' Char)*)? '?>'

// [17] PITarget ::= Name - (('X' | 'x') ('M' | 'm') ('L' | 'l'))
PITarget
  = !([Xx] [Mm] [Ll]) Name

// [18] CDSect ::= CDStart CData CDEnd
CDSect
  = CDStart data:CData CDEnd {
    return data;
  }

// [19] CDStart ::= '<![CDATA['
CDStart
  = '<![CDATA['

// [20] CData ::= (Char* - (Char* ']]>' Char*))
CData
  = $(!']]>' char:Char { return char })*

// [21] CDEnd ::= ']]>'
CDEnd
  = ']]>'

// [22] prolog ::= XMLDecl Misc* (doctypedecl Misc*)?
prolog
  = xml:XMLDecl Misc* (doctypedecl Misc*)? {
    // ignore doctype
    return xml;
  }

// [23] XMLDecl ::= '<?xml' VersionInfo EncodingDecl? SDDecl? S?'?>'
XMLDecl
  = '<?xml' version:VersionInfo
            encoding:EncodingDecl?
            standalone:SDDecl?
            S? '?>' {
    return Object.assign({}, version, encoding, standalone);
  }

// [24] VersionInfo ::= S 'version' Eq ("'" VersionNum "'" | '"' VersionNum '"')
VersionInfo
  = S 'version' Eq version:("'" version:VersionNum "'" { return version } /
                            '"' version:VersionNum '"' { return version }) {
    return { version: version };
  }

// [25] Eq ::= S? '=' S?
Eq
  = S? '=' S?

// [26] VersionNum ::= '1.1'
VersionNum
  = '1.0' / '1.1'

// [27] Misc ::= Comment | PI | S
Misc
  = Comment / PI / S

// [28] doctypedecl ::= '<!DOCTYPE' S Name (S ExternalID)? S? ('[' intSubset ']' S?)? '>'
doctypedecl
  = '<!DOCTYPE' S Name (S ExternalID)? S? ('[' intSubset ']' S?)? '>'

// [28a] DeclSep ::= PEReference | S
DeclSep
  = PEReference / S

// [28b] intSubset ::= (markupdecl | DeclSep)*
intSubset
  = (markupdecl / DeclSep)*

// [29] markupdecl ::= elementdecl | AttlistDecl | EntityDecl | NotationDecl | PI | Comment
markupdecl
  = elementdecl / AttlistDecl / EntityDecl / NotationDecl / PI / Comment

// [32] SDDecl ::= #x20+ 'standalone' Eq (("'" ('yes' | 'no') "'") | ('"' ('yes' | 'no') '"'))
SDDecl
  = ' '+ 'standalone' Eq standalone:("'" value:('yes' / 'no') "'" { return value; } /
                                     '"' value:('yes' / 'no') '"' { return value; }) {
    return { standalone: standalone };
  }

// [39] element ::= EmptyElemTag
element
  = tag:EmptyElemTag
  / tag:STag content:content ETag {
    return [
      tag[0],
      tag[1],
      content
    ];
  }

// [40] STag ::= '<' Name (S Attribute)* S? '>'
STag
  = '<' name:Name attrs:(S Attribute)* S? '>' {
    return [
      name,
      attrs.reduce(function(acc, attr) {
        return Object.assign(acc, attr[1]);
      }, {})
    ];
  }

// [41] Attribute ::= Name Eq AttValue
Attribute
  = name:Name Eq value:AttValue{
    var attr = {};
    attr[name] = value;
    return attr;
  }

// [42] ETag ::= '</' Name S? '>'
ETag
  = '</' Name S? '>'

// [43] content ::= CharData? ((element | Reference | CDSect | PI | Comment) CharData?)*
content
  = head:CharData?
    tail:((element /
           CDSect /
           PI { return null; } /
           Comment { return null; }) CharData?)* {
      var nodes = [];
      if (head != null) {
        nodes.push(head);
      }
      tail.forEach(function(node) {
        if (node[0] != null) {
          nodes.push(node[0]);
        }
        if (node[1] != null) {
          nodes.push(node[1]);
        }
      });
      return nodes;
  }

EmptyElemTag
  = '<' name:Name attrs:(S Attribute)* S? '/>' {
    return [
      name,
      attrs.reduce(function(acc, attr) {
        return Object.assign(acc, attr[1])
      }, {}),
      []
    ];
  }

// [45] elementdecl ::= '<!ELEMENT' S Name S contentspec S? '>'
elementdecl
  = '<!ELEMENT' S Name S contentspec S? '>'

// [46] contentspec ::= 'EMPTY' | 'ANY' | Mixed | children
contentspec
  = 'EMPTY' / 'ANY' / Mixed / children

// [47] children ::= (choice | seq) ('?' | '*' | '+')?
children
  = (choice / seq) ('?' / '*' / '+')?

// [48] cp ::= (Name | choice | seq) ('?' | '*' | '+')?
cp
  = (Name / choice / seq) ('?' / '*' / '+')?

// [49] choice ::= '(' S? cp ( S? '|' S? cp )+ S? ')'
choice
  = '(' S? cp ( S? '|' S? cp )+ S? ')'

// [50] seq ::= '(' S? cp ( S? ',' S? cp )* S? ')'
seq
  = '(' S? cp ( S? ',' S? cp )* S? ')'

// [51] Mixed ::= '(' S? '#PCDATA' (S? '|' S? Name)* S? ')*' | '(' S? '#PCDATA' S? ')'
Mixed
  = '(' S? '#PCDATA' (S? '|' S? Name)* S? ')*' / '(' S? '#PCDATA' S? ')'

// [52] AttlistDecl ::= '<!ATTLIST' S Name AttDef* S? '>'
AttlistDecl
  = '<!ATTLIST' S Name AttDef* S? '>'

// [53] AttDef ::= S Name S AttType S DefaultDecl
AttDef
  = S Name S AttType S DefaultDecl

// [54] AttType ::= StringType | TokenizedType | EnumeratedType
AttType
  = StringType / TokenizedType / EnumeratedType

// [55] StringType ::= 'CDATA'
StringType
  = 'CDATA'

// [56] TokenizedType ::= 'ID' | 'IDREF' | 'IDREFS' | 'ENTITY' | 'ENTITIES' | 'NMTOKEN' | 'NMTOKENS'
TokenizedType
  = 'ID' / 'IDREF' / 'IDREFS' / 'ENTITY' / 'ENTITIES' / 'NMTOKEN' / 'NMTOKENS'

// [57] EnumeratedType ::= NotationType | Enumeration
EnumeratedType
  = NotationType / Enumeration

// [58] NotationType ::= 'NOTATION' S '(' S? Name (S? '|' S? Name)* S? ')'
NotationType
  = 'NOTATION' S '(' S? Name (S? '|' S? Name)* S? ')'

// [59] Enumeration ::= '(' S? Nmtoken (S? '|' S? Nmtoken)* S? ')'
Enumeration
  = '(' S? Nmtoken (S? '|' S? Nmtoken)* S? ')'

// [60] DefaultDecl ::= '#REQUIRED' | '#IMPLIED' | (('#FIXED' S)? AttValue)
DefaultDecl
  = '#REQUIRED' / '#IMPLIED' / (('#FIXED' S)? AttValue)

// [66] CharRef ::= '&#' [0-9]+ ';' | '&#x' [0-9a-fA-F]+ ';'
CharRef
  = '&#' code:$[0-9]+ ';' {
    return String.fromCodePoint(parseInt(code, 10));
  }
  / '&#x' code:$[0-9a-fA-F]+ ';' {
    return String.fromCodePoint(parseInt(code, 16));
  }

// [67] Reference ::= EntityRef | CharRef
Reference
  = EntityRef / CharRef

// [68] EntityRef ::= '&' Name ';'
EntityRef
  = name:$('&' Name ';') {
    return ENTITY_REFERENCES[name] || name;
  }

// [69] PEReference ::= '%' Name ';'
PEReference
  = '%' Name ';'

// [70] EntityDecl ::= GEDecl | PEDecl
EntityDecl
  = GEDecl / PEDecl

// [71] GEDecl ::= '<!ENTITY' S Name S EntityDef S? '>'
GEDecl
  = '<!ENTITY' S Name S EntityDef S? '>'

// [72] PEDecl ::= '<!ENTITY' S '%' S Name S PEDef S? '>'
PEDecl
  = '<!ENTITY' S '%' S Name S PEDef S? '>'

// [73] EntityDef ::= EntityValue| (ExternalID NDataDecl?)
EntityDef
  = EntityValue / (ExternalID NDataDecl?)

// [74] PEDef ::= EntityValue | ExternalID
PEDef
  = EntityValue / ExternalID

// [75] ExternalID ::= 'SYSTEM' S SystemLiteral | 'PUBLIC' S PubidLiteral S SystemLiteral
ExternalID
  = 'SYSTEM' S SystemLiteral / 'PUBLIC' S PubidLiteral S SystemLiteral

// [76] NDataDecl ::= S 'NDATA' S Name
NDataDecl
  = S 'NDATA' S Name

// [80] EncodingDecl ::= S 'encoding' Eq ('"' EncName '"' | "'" EncName "'" )
EncodingDecl
  = S 'encoding' Eq encoding:('"' name:EncName '"' { return name } /
                              "'" name:EncName "'" { return name } ) {
    return { encoding: encoding };
  }

// [81] EncName ::= [A-Za-z] ([A-Za-z0-9._] | '-')*
EncName "EncName"
  = $([A-Za-z] ([A-Za-z0-9._] / '-')*)

// [82] NotationDecl ::= '<!NOTATION' S Name S (ExternalID | PublicID) S? '>'
NotationDecl
  = '<!NOTATION' S Name S (ExternalID / PublicID) S? '>'

// [83] PublicID ::= 'PUBLIC' S PubidLiteral
PublicID
  = 'PUBLIC' S PubidLiteral
