final: prev:
let
  matchesAny = regexes: string:
    builtins.elem true (map (r: builtins.match r string));
in{
  fs = rec {
    # nameToPath :: Path -> String -> Path
    # Converts a file name to an absolute path, relative to a base directory.
    nameToPath = base: name: base + "/${name}";

    # allNamesIn :: Path -> [String]
    # Lists all file/directory/symlink names in a directory.
    allNamesIn = dir: builtins.attrNames (builtins.readDir dir);

    # allPathsIn :: Path -> [Path]
    # Lists all file/directory/symlink paths in a directory.
    allPathsIn = dir: map (nameToPath dir) (allNamesIn dir);

    # allNamesInByPred :: (String -> String -> Bool) -> Path -> [String]
    # Lists all file/directory/symlink names in a directory which follow a predicate.
    allNamesInByPred = pred: dir:
      builtins.attrNames (prev.filterAttrs pred (builtins.readDir dir));

    # allPathsInByPred :: (String -> String -> Bool) -> Path -> [Path]
    # Lists all file/directory/symlink paths in a directory which follow a predicate.
    allPathsInByPred = pred: dir:
      map (nameToPath dir) (allNamesInByPred pred dir);

    # allNamesInMatching :: String -> Path -> [String]
    # Lists all file/directory/symlink names that match a regular expression.
    allNamesInMatching = regex: allNamesInByPred (name: _: builtins.match regex name);

    # allPathsInMatching :: String -> Path -> [Path]
    # Lists all file/directory/symlink names that match a regular expression.
    allPathsInMatching = regex: dir: map (nameToPath dir) (allNamesInMatching regex dir);

    # allNamesInByKind :: Enum [ "regular" "directory" "symlink" ] -> Path -> [String]
    # Lists all names of either regular files, directories, or symlinks within a directory.
    allNamesInByKind = kind: allNamesInByPred (_: kind': kind' == kind);

    # allPathsInByKind :: Enum [ "regular" "directory" "symlink" ] -> Path -> [Path]
    # Lists all paths of either regular files, directories, or symlinks within a directory.
    allPathsInByKind = kind: allPathsInByPred (_: kind': kind' == kind);

    allFileNamesInExcluding = exclude:
      allNamesInByPred (name: kind: (!builtins.elem name exclude) && (kind == "directory"));

    allFilePathsInExcluding = exclude: dir: map (nameToPath dir) (allFileNamesInExcluding exclude);

    isHidden = name: (builtins.match "^\\..*") name != null;

    # Aliases, I'm not going to bother annotating.
    allFileNamesIn = allNamesInByKind "regular"; # All regular file names
    allFilePathsIn = allPathsInByKind "regular"; # All regular file paths
    allDirectoryNamesIn = allNamesInByKind "directory"; # All directory names
    allDirectoryPathsIn = allPathsInByKind "directory"; # All directory paths
    subdirNames = allDirectoryNamesIn; # Alias for `allDirectoryNamesIn`
    subdirs = allDirectoryPathsIn; # Alias for `allDirectoryPathsIn`
  };
}
