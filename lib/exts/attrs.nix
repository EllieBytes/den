final: prev:
let
  inherit (builtins)
    attrNames
    isString
    split
    filter
    isList
    typeOf
    head
    tail
    hasAttr
    isAttrs
    ;

  inherit (final) identity;

  inherit (prev) genAttrs mapAttrs;
in
rec {
  deferAttrPath =
    path:
    if isString path then
      filter isString (split "\\." path)
    else if isList path then
      path
    else
      throw ''
        Expected: string | list.
        Got: ${typeOf path}.
      '';

  lazySetAttrByPath =
    path: value: if path == [ ] then value else { ${head path} = lazySetAttrByPath (tail path) value; };

  lazyMerge =
    lhs: rhs:
    if isAttrs lhs && isAttrs rhs then
      let
        allKeys = genAttrs (attrNames lhs ++ attrNames rhs) identity;
      in
      mapAttrs (
        k: v:
        if hasAttr k lhs && hasAttr k rhs then
          lazyMerge lhs."${k}" rhs."${k}"
        else if hasAttr k lhs then
          lhs."${k}"
        else
          rhs."${k}"
      ) allKeys
    else
      rhs;
}
